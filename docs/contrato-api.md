# Contrato de API

Contrato entre la aplicación móvil (Flutter) y el backend (FastAPI) de hogar-app. Cubre los requerimientos RF01–RF18 y los requerimientos no funcionales que afectan a la interfaz (RNF03, RNF04, RNF05, RNF08, RNF09, RNF10).

Este documento es la fuente de verdad para el frontend y el backend. Si una implementación no coincide con él, se corrige la implementación o se propone un cambio al contrato mediante pull request (ver [Cambios al contrato](#cambios-al-contrato)).

## Índice

1. [Convenciones generales](#1-convenciones-generales)
2. [Autenticación y sesión](#2-autenticación-y-sesión)
3. [Autorización](#3-autorización)
4. [Cabeceras](#4-cabeceras)
5. [Errores](#5-errores)
6. [Paginación](#6-paginación)
7. [Concurrencia e idempotencia](#7-concurrencia-e-idempotencia)
8. [Límites de peticiones](#8-límites-de-peticiones)
9. [Tipos comunes](#9-tipos-comunes)
10. [Módulos y responsables](#10-módulos-y-responsables)
11. [Endpoints](#11-endpoints)
12. [Modelos](#12-modelos)
13. [Mapa de pantallas](#13-mapa-de-pantallas)
14. [Decisiones sobre puntos pendientes del SRS](#14-decisiones-sobre-puntos-pendientes-del-srs)
15. [Cambios al contrato](#cambios-al-contrato)

---

## 1. Convenciones generales

| Aspecto | Regla |
| --- | --- |
| URL base | `{API_BASE_URL}/api/v1`. En desarrollo con emulador Android: `http://10.0.2.2:8000/api/v1`. |
| Transporte | HTTPS con TLS 1.2 o superior en producción (RNF04). |
| Versionado | Versión mayor en la ruta (`/api/v1`). Cambios incompatibles solo en `/api/v2`. |
| Formato | JSON UTF-8 (`Content-Type: application/json`), salvo subida de fotos (`multipart/form-data`). |
| Nombres de campos | `snake_case`, en inglés. |
| Identificadores | UUID v4 en texto. |
| Fechas y horas | `Timestamp`: ISO 8601 en UTC (`2026-10-04T15:30:00Z`). `LocalDate`: `YYYY-MM-DD`. `LocalTime`: `HH:MM` en la zona horaria del hogar. |
| Zona horaria | Cada hogar tiene una zona IANA (por defecto `America/Santiago`). Plazos, rutinas, semanas y meses se calculan en esa zona. |
| Semana | De lunes a domingo, en la zona del hogar. |
| Nulos | Los campos opcionales se envían siempre en las respuestas, con `null` cuando no tienen valor. |
| Enumeraciones | Valores en `snake_case` y en inglés. La app los traduce para mostrarlos. |
| Textos | Se recortan los espacios de los extremos antes de validar. |
| Idioma de mensajes | `error.message` va en inglés y es técnico. La app nunca lo muestra: traduce a partir de `error.code`. |
| Documentación viva | El backend publica el OpenAPI generado en `/api/v1/openapi.json` y la interfaz interactiva en `/docs` (solo fuera de producción). Debe coincidir con este documento (RNF09). |

## 2. Autenticación y sesión

El acceso se hace con número de teléfono y contraseña. El número se verifica por SMS al registrarse y al recuperar la contraseña.

### Tokens

| Token | Formato | Vigencia | Uso |
| --- | --- | --- | --- |
| `access_token` | JWT firmado con HS256 | 15 minutos | Cabecera `Authorization: Bearer <access_token>` en cada petición protegida. |
| `refresh_token` | Cadena opaca aleatoria (se guarda solo su hash en el servidor) | 30 días | Solo en `POST /auth/refresh` y `POST /auth/logout`. |
| `verification_token` | JWT de un solo uso | 15 minutos | Demuestra que se validó el código SMS. Solo en `POST /auth/register` y `POST /auth/password-reset`. |

Claims del `access_token`: `sub` (id del usuario), `sid` (id de la sesión), `type` (`access`), `iat`, `exp`, `jti`. El token no lleva datos personales ni roles: los permisos se resuelven en el servidor en cada petición (RNF03).

### Rotación del refresh token

- Cada `POST /auth/refresh` entrega un par nuevo e invalida el refresh token usado.
- Si llega un refresh token ya rotado, se asume robo: se revoca toda la sesión y se responde `INVALID_REFRESH_TOKEN`.
- Cambiar la contraseña revoca todas las sesiones del usuario.

### Comportamiento esperado de la app

1. Guarda los tokens en almacenamiento seguro (Android Keystore mediante `flutter_secure_storage`). Nunca en `SharedPreferences` ni en logs.
2. Ante un `401` con `UNAUTHENTICATED`, llama una sola vez a `/auth/refresh` (aunque haya varias peticiones en curso) y reintenta la petición original.
3. Si el refresh responde `INVALID_REFRESH_TOKEN`, borra la sesión y vuelve a la bienvenida (S1).

### Reglas de verificación por SMS

| Regla | Valor |
| --- | --- |
| Código | 6 dígitos, generado por el backend y guardado como hash. |
| Envío | Twilio Programmable Messaging. Texto: `Tu código de equilibrio es 482 715`. |
| Vigencia del código | 10 minutos. |
| Intentos por código | 5. Al agotarlos hay que pedir otro código. |
| Espera para reenviar | 60 segundos. |
| Bloqueo de inicio de sesión | 5 intentos fallidos seguidos bloquean la cuenta 15 minutos. |

### Contraseñas

- Entre 8 y 128 caracteres, con al menos una letra mayúscula y al menos un número o un símbolo (lista de S4).
- Se guardan con Argon2id (hash adaptativo con sal, RNF04). Nunca se registran en logs.

## 3. Autorización

- Todos los endpoints requieren `access_token`, salvo los marcados como **Público**.
- Los permisos se evalúan por hogar (RF01). Roles: `admin` y `member`. Un hogar puede tener varios administradores.
- Si el usuario no pertenece al hogar de la ruta, la respuesta es `404 HOUSEHOLD_NOT_FOUND`, igual que si el hogar no existiera. Así no se revela qué hogares existen (aislamiento entre hogares, RNF03).
- Si pertenece pero no tiene el rol necesario: `403 ADMIN_REQUIRED`.
- Las restricciones de tareas o categorías (RF10, RF14) se aplican también a los administradores.

| Acción | Integrante | Administrador |
| --- | :---: | :---: |
| Crear hogar, unirse con código, abandonar | Sí | Sí (si no es el último administrador) |
| Editar datos del hogar, ver o regenerar invitación | No | Sí |
| Retirar integrantes, cambiar roles | No | Sí |
| Editar un perfil | Solo el suyo | Solo el suyo |
| Aprobar reparto de capacidad | No | Sí |
| Aplicar plantillas | No | Sí, una vez, al crear el hogar |
| Crear, editar y eliminar tareas | Sí | Sí |
| Asignar una tarea a otra persona | No | Sí |
| Tomar una tarea libre, liberar la propia | Sí | Sí |
| Confirmar una participación | Solo la suya | Solo la suya |
| Configurar rotaciones de rutinas | No | Sí |
| Proponer y aceptar intercambios | Sí | Sí |
| Moderar comentarios | No | Sí |
| Aprobar sugerencias de redistribución | No | Sí |

## 4. Cabeceras

| Cabecera | Dirección | Descripción |
| --- | --- | --- |
| `Authorization` | Petición | `Bearer <access_token>`. |
| `X-Request-ID` | Petición y respuesta | Identificador para rastrear la petición en los logs (RNF10). La app genera un UUID por petición; si no lo envía, el servidor crea uno. Siempre vuelve en la respuesta. |
| `Idempotency-Key` | Petición | UUID por intención de acción en los endpoints marcados como **Idempotente**. Ver [sección 7](#7-concurrencia-e-idempotencia). |
| `X-RateLimit-Limit` | Respuesta | Peticiones permitidas en la ventana. |
| `X-RateLimit-Remaining` | Respuesta | Peticiones restantes en la ventana. |
| `X-RateLimit-Reset` | Respuesta | Segundos hasta que se reinicia la ventana. |
| `Retry-After` | Respuesta | En `429` y `423`: segundos que hay que esperar. |

## 5. Errores

### Formato

Toda respuesta con estado distinto de 2xx tiene este cuerpo:

```json
{
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Phone number or password is incorrect.",
    "details": { "remaining_attempts": 4 },
    "request_id": "6f1c3a52-0d7e-4c55-9a43-2f8a1b7c9e01"
  }
}
```

| Campo | Descripción |
| --- | --- |
| `code` | Código estable en `UPPER_SNAKE_CASE`. Es lo único que la app usa para decidir qué mostrar. |
| `message` | Texto técnico en inglés. No se muestra al usuario. |
| `details` | Objeto con datos adicionales; vacío (`{}`) si no hay. |
| `request_id` | Igual a la cabecera `X-Request-ID`. |

Los errores nunca incluyen trazas, consultas SQL, tokens ni datos personales (RNF04).

### Errores de validación

`422 VALIDATION_ERROR` incluye la lista de campos inválidos:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed.",
    "details": {
      "fields": [
        { "field": "body.password", "code": "password_missing_uppercase", "message": "Password must contain an uppercase letter." }
      ]
    },
    "request_id": "6f1c3a52-0d7e-4c55-9a43-2f8a1b7c9e01"
  }
}
```

`field` es la ruta con puntos (`body.<campo>`, `query.<parámetro>`, `path.<parámetro>`). Códigos de campo frecuentes:

| Código de campo | Significado |
| --- | --- |
| `required` | Falta el campo. |
| `invalid_type` | Tipo incorrecto. |
| `too_short` / `too_long` | Longitud fuera de rango. |
| `out_of_range` | Número o fecha fuera de rango. |
| `invalid_format` | Formato incorrecto (teléfono, fecha, UUID, etc.). |
| `invalid_choice` | Valor fuera de la enumeración. |
| `unknown_key` | Clave de catálogo inexistente. |
| `password_too_short` | Contraseña con menos de 8 caracteres. |
| `password_missing_uppercase` | Contraseña sin mayúscula. |
| `password_missing_digit_or_symbol` | Contraseña sin número ni símbolo. |
| `duplicated` | Valor repetido en una lista que no admite repetidos. |
| `conflicting_values` | Combinación de campos incompatible. |

### Catálogo de códigos

| HTTP | `code` | Cuándo | `details` |
| --- | --- | --- | --- |
| 400 | `VERIFICATION_CODE_INVALID` | Código SMS incorrecto. | `remaining_attempts` |
| 401 | `UNAUTHENTICATED` | Falta el access token, o es inválido o expiró. | — |
| 401 | `INVALID_CREDENTIALS` | Teléfono o contraseña incorrectos. | `remaining_attempts` |
| 401 | `INVALID_REFRESH_TOKEN` | Refresh token inválido, expirado, revocado o reutilizado. | — |
| 401 | `INVALID_VERIFICATION_TOKEN` | Verification token inválido, expirado o ya usado. | — |
| 403 | `FORBIDDEN` | No tiene permiso sobre el recurso. | — |
| 403 | `ADMIN_REQUIRED` | La acción requiere ser administrador del hogar. | — |
| 403 | `PARTICIPATION_NOT_OWNED` | Intenta confirmar o liberar una participación ajena. | — |
| 404 | `NOT_FOUND` | Recurso inexistente (genérico). | — |
| 404 | `HOUSEHOLD_NOT_FOUND` | Hogar inexistente o al que no pertenece. | — |
| 404 | `MEMBER_NOT_FOUND` | El usuario no es integrante activo del hogar. | — |
| 404 | `VERIFICATION_NOT_FOUND` | Verificación SMS inexistente. | — |
| 404 | `INVITATION_NOT_FOUND` | Código de invitación inexistente o revocado. | — |
| 404 | `TASK_NOT_FOUND` | Tarea inexistente o eliminada. | — |
| 404 | `ROUTINE_NOT_FOUND` | Rutina inexistente. | — |
| 404 | `SWAP_REQUEST_NOT_FOUND` | Solicitud de intercambio inexistente. | — |
| 404 | `COMMENT_NOT_FOUND` | Comentario inexistente. | — |
| 404 | `SUGGESTION_NOT_FOUND` | Sugerencia inexistente. | — |
| 409 | `PHONE_ALREADY_REGISTERED` | El número ya tiene una cuenta. | — |
| 409 | `ALREADY_MEMBER` | Ya pertenece al hogar del código. | `household_id` |
| 409 | `LAST_ADMIN_MUST_TRANSFER` | El último administrador intenta salir o quitarse el rol. | — |
| 409 | `TEMPLATES_ALREADY_APPLIED` | El hogar ya decidió sus plantillas. | — |
| 409 | `TASK_COMPLETED_LOCKED` | Intenta editar una tarea completada. | — |
| 409 | `PARTICIPATION_NOT_AVAILABLE` | La participación ya no está libre o ya está completada. | — |
| 409 | `ASSIGNEE_RESTRICTED` | La persona tiene una restricción vigente sobre la categoría o actividad. | `user_id`, `restriction_id` |
| 409 | `SIMILAR_TASKS_FOUND` | Imprevisto parecido a tareas existentes. | `similar_tasks` (lista de `SimilarTask`) |
| 409 | `SWAP_REQUEST_NOT_PENDING` | La solicitud ya fue resuelta o cancelada. | `status` |
| 409 | `SUGGESTION_NOT_PENDING` | La sugerencia ya fue resuelta o quedó obsoleta. | `status` |
| 409 | `CAPACITY_NOT_CONFIGURED` | Falta un reparto de capacidad válido o un umbral. | — |
| 409 | `IDEMPOTENCY_KEY_REUSED` | Misma `Idempotency-Key` con un cuerpo distinto. | — |
| 409 | `CONFLICT` | Otro conflicto con el estado actual. | — |
| 410 | `VERIFICATION_EXPIRED` | El código SMS expiró. | — |
| 410 | `INVITATION_EXPIRED` | El código de invitación expiró. | — |
| 412 | `VERSION_CONFLICT` | La `version` enviada no es la actual. | `current_version` |
| 413 | `ATTACHMENT_TOO_LARGE` | Foto de más de 5 MB. | `max_bytes` |
| 415 | `UNSUPPORTED_MEDIA_TYPE` | Foto en un formato no admitido. | `allowed` |
| 422 | `VALIDATION_ERROR` | Datos inválidos. | `fields` |
| 422 | `CAPACITY_SUM_INVALID` | El reparto de capacidad no suma 100 o no incluye a todos. | `sum` |
| 422 | `UNPLANNED_TASK_OUT_OF_RANGE` | Imprevisto con fecha futura o de hace más de 7 días. | `min_date`, `max_date` |
| 423 | `ACCOUNT_LOCKED` | Cuenta bloqueada por intentos fallidos. | `retry_after_seconds` |
| 429 | `RATE_LIMITED` | Límite de peticiones superado. | `retry_after_seconds` |
| 429 | `VERIFICATION_ATTEMPTS_EXCEEDED` | Se agotaron los intentos del código SMS. | — |
| 429 | `VERIFICATION_RESEND_TOO_SOON` | Reenvío antes de los 60 segundos. | `retry_after_seconds` |
| 500 | `INTERNAL_ERROR` | Error inesperado. | — |
| 502 | `SMS_DELIVERY_FAILED` | El proveedor de SMS falló. | — |
| 503 | `SERVICE_UNAVAILABLE` | Servicio o base de datos no disponible. | — |

Ante errores de red, `5xx` o tiempo agotado, la app informa del problema y ofrece reintentar. Nunca muestra un cambio como guardado si el servidor no lo confirmó (RNF08).

## 6. Paginación

Las listas que pueden crecer usan paginación por cursor:

- Parámetros: `cursor` (opcional) y `limit` (1–100, por defecto 20).
- Respuesta:

```json
{ "items": [ ], "next_cursor": "eyJpZCI6IjNmNmMuLi4ifQ" }
```

- `next_cursor` es opaco: la app no lo interpreta. Es `null` cuando no hay más páginas.
- El orden de cada lista se indica en su endpoint.

Las listas cortas (catálogo, integrantes, mis hogares) se devuelven completas, como un arreglo JSON.

## 7. Concurrencia e idempotencia

### Versión de recursos (RNF05)

Los recursos editables (`Household`, `Task`, `Routine`) tienen un campo `version` entero. Al editar se envía la `version` leída. Si otra persona cambió el recurso entretanto, la respuesta es `412 VERSION_CONFLICT` con `details.current_version`: la app recarga y muestra el estado actual en vez de sobrescribirlo en silencio.

### Idempotencia (RNF05)

Los endpoints marcados como **Idempotente** exigen la cabecera `Idempotency-Key` (UUID):

- La app genera una clave nueva por cada intención del usuario (por ejemplo, al tocar «Completar») y la reutiliza en los reintentos de esa misma acción.
- Si llega una clave ya procesada con el mismo cuerpo, el servidor devuelve la respuesta original sin repetir el efecto.
- Si llega con un cuerpo distinto: `409 IDEMPOTENCY_KEY_REUSED`.
- Las claves se conservan 24 horas por usuario.

### Atomicidad

Las operaciones que modifican varias entidades (intercambios, aplicación de plantillas, aprobación de sugerencias, salida de un integrante) se ejecutan en una única transacción: o se aplican completas o no se aplica nada.

## 8. Límites de peticiones

Al superar un límite, la respuesta es `429` con `Retry-After`. Los límites por número de teléfono se aplican además de los límites por IP.

| Endpoint | Límite |
| --- | --- |
| `POST /auth/phone-verifications` | 5 por número cada hora; 20 por IP cada hora. |
| `POST /auth/phone-verifications/{id}/resend` | 1 cada 60 s por verificación; 5 por número cada hora. |
| `POST /auth/phone-verifications/{id}/confirm` | 5 intentos por código; 30 por IP cada hora. |
| `POST /auth/login` | 10 por IP cada minuto, más el bloqueo de cuenta tras 5 fallos. |
| `POST /auth/register`, `POST /auth/password-reset` | 10 por IP cada hora. |
| `POST /auth/refresh` | 30 por IP cada minuto. |
| `GET /invitations/{code}`, `POST /invitations/{code}/accept` | 10 por usuario cada minuto. |
| `POST .../comments` | 30 por usuario cada minuto. |
| Resto de endpoints autenticados | 120 por usuario cada minuto. |
| Resto de endpoints públicos | 60 por IP cada minuto. |

## 9. Tipos comunes

| Tipo | Definición |
| --- | --- |
| `Uuid` | Texto UUID. |
| `Timestamp` | Texto ISO 8601 en UTC. |
| `LocalDate` | `YYYY-MM-DD`. |
| `LocalTime` | `HH:MM`, 24 horas. |
| `PhoneNumber` | E.164: `^\+[1-9]\d{7,14}$`. La app propone `+56`. Ejemplo: `+56987654321`. |
| `Role` | `admin` \| `member`. |
| `Avatar` | `indigo` \| `green` \| `peach` \| `yellow` \| `sky` \| `pink`, los seis personajes de S6. |
| `Weekday` | Entero 0–6: 0 = lunes … 6 = domingo. |
| `DayPeriod` | `morning` (07–13) \| `afternoon` (13–20) \| `evening` (20–23), en la hora del hogar. |
| `Priority` | `low` \| `medium` \| `high`. Por defecto `medium`. Expresa urgencia y no multiplica la carga (RF03, RF13). |
| `Scale1To5` | Entero 1–5: 1 = muy bajo, 5 = muy alto. Se usa en esfuerzo y carga mental. |
| `DurationMinutes` | Entero 1–1440. |
| `Percent` | Entero 0–100. |
| `PeriodGranularity` | `week` \| `month`. |
| `UserReference` | `{ "user_id", "display_name", "avatar", "is_active" }`. `display_name` es el apodo en el hogar o, si no hay, el nombre de la cuenta. `is_active = false` identifica a antiguos integrantes (RF16). |

## 10. Módulos y responsables

| Módulo | Requerimientos | Flujo Figma | Diseño | Implementación | Hito |
| --- | --- | --- | --- | --- | --- |
| Salud | RNF07 | — | — | @MartinZuniga-Nane | P1 |
| Autenticación y usuarios | Registro e inicio de sesión | N1 | @MartinZuniga-Nane | @MartinZuniga-Nane | P1 |
| Hogares e invitaciones | RF01 | N2, N6 | @MartinZuniga-Nane, @DaniAuditore | @MartinZuniga-Nane | P1 |
| Perfiles | RF02, RF10, RF14 | N2, N6 | @MartinZuniga-Nane | @MartinZuniga-Nane | P1–P2 |
| Catálogo | RF03, RF14, RF17 | N2, N4 | — | @MartinZuniga-Nane | P1 |
| Plantillas | RF17 | N2 | @MartinZuniga-Nane | @MartinZuniga-Nane | P3 |
| Tareas | RF03, RF05 | N4 | @emassa05 | Por asignar | P1 |
| Rutinas | RF04 | N4 | @emassa05 | Por asignar | P2 |
| Imprevistos | RF12 | N4 | @emassa05 | Por asignar | P2 |
| Comentarios | RF15 | N4 | @emassa05 | Por asignar | P2 |
| Intercambios | RF11 | N4 | @emassa05 | Por asignar | P3 |
| Notificaciones | RF07 | N3 | @Shtolaa | Por asignar | P2 |
| Panel | RF09 | N3 | @Shtolaa | Por asignar | P2 |
| Carga | RF06, RF13 | N5 | @Shtolaa | Por asignar | P2 |
| Capacidad | RF18 | N5, N6 | @Shtolaa | Por asignar | P2 |
| Sugerencias | RF08 | N5 | @Shtolaa | Por asignar | P3 |
| Estadísticas e historial | RF16 | N5 | @Shtolaa | Por asignar | P3 |

---

## 11. Endpoints

Notación usada en cada endpoint:

- **Público**: no requiere `access_token`.
- **Admin**: requiere ser administrador del hogar de la ruta.
- **Idempotente**: requiere `Idempotency-Key`.
- Las respuestas `401 UNAUTHENTICATED`, `404 HOUSEHOLD_NOT_FOUND`, `422 VALIDATION_ERROR`, `429 RATE_LIMITED` y `500 INTERNAL_ERROR` pueden aparecer en cualquier endpoint que aplique y no se repiten en cada tabla.

### Resumen

| Método | Ruta | Descripción |
| --- | --- | --- |
| GET | `/health/live` | Proceso vivo |
| GET | `/health/ready` | Listo para atender |
| POST | `/auth/phone-verifications` | Enviar código SMS |
| POST | `/auth/phone-verifications/{verification_id}/resend` | Reenviar código SMS |
| POST | `/auth/phone-verifications/{verification_id}/confirm` | Validar código SMS |
| POST | `/auth/register` | Crear cuenta |
| POST | `/auth/login` | Iniciar sesión |
| POST | `/auth/refresh` | Renovar tokens |
| POST | `/auth/logout` | Cerrar sesión |
| POST | `/auth/password-reset` | Restablecer contraseña |
| GET | `/users/me` | Mi cuenta |
| PATCH | `/users/me` | Editar mi cuenta |
| POST | `/users/me/devices` | Registrar dispositivo push |
| DELETE | `/users/me/devices/{device_id}` | Eliminar dispositivo push |
| GET | `/users/me/notification-settings` | Mis ajustes de avisos |
| PUT | `/users/me/notification-settings` | Guardar ajustes de avisos |
| GET | `/households` | Mis hogares |
| POST | `/households` | Crear hogar |
| GET | `/households/{household_id}` | Detalle del hogar |
| PATCH | `/households/{household_id}` | Editar hogar |
| GET | `/households/{household_id}/invitation` | Código de invitación vigente |
| POST | `/households/{household_id}/invitation/regenerate` | Regenerar código |
| GET | `/invitations/{code}` | Ver hogar de un código |
| POST | `/invitations/{code}/accept` | Unirse al hogar |
| PATCH | `/households/{household_id}/members/{user_id}` | Cambiar rol |
| DELETE | `/households/{household_id}/members/{user_id}` | Retirar integrante |
| POST | `/households/{household_id}/leave` | Abandonar hogar |
| GET | `/households/{household_id}/members/{user_id}/profile` | Perfil doméstico |
| PATCH | `/households/{household_id}/members/me/profile` | Editar mi perfil |
| PUT | `/households/{household_id}/members/me/availability` | Guardar mi disponibilidad |
| POST | `/households/{household_id}/members/me/restrictions` | Añadir restricción |
| PUT | `/households/{household_id}/members/me/restrictions/{restriction_id}` | Editar restricción |
| DELETE | `/households/{household_id}/members/me/restrictions/{restriction_id}` | Eliminar restricción |
| PUT | `/households/{household_id}/members/me/preferences` | Guardar preferencias |
| GET | `/households/{household_id}/capacity` | Capacidad vigente y propuestas |
| POST | `/households/{household_id}/capacity/distributions` | Aprobar reparto de capacidad |
| GET | `/households/{household_id}/capacity/distributions` | Historial de repartos |
| GET | `/catalog/task-categories` | Categorías |
| GET | `/catalog/activities` | Actividades |
| GET | `/household-templates` | Plantillas |
| GET | `/household-templates/{template_key}` | Detalle de plantilla |
| GET | `/households/{household_id}/template-application` | Plantillas aplicadas |
| POST | `/households/{household_id}/template-application` | Aplicar plantillas |
| GET | `/households/{household_id}/tasks` | Listar tareas |
| POST | `/households/{household_id}/tasks` | Crear tarea |
| GET | `/households/{household_id}/tasks/{task_id}` | Detalle de tarea |
| PATCH | `/households/{household_id}/tasks/{task_id}` | Editar tarea |
| DELETE | `/households/{household_id}/tasks/{task_id}` | Eliminar tarea |
| POST | `/households/{household_id}/tasks/{task_id}/participations/{participation_id}/take` | Tomar participación libre |
| POST | `/households/{household_id}/tasks/{task_id}/participations/{participation_id}/release` | Liberar mi participación |
| PUT | `/households/{household_id}/tasks/{task_id}/participations/{participation_id}/assignee` | Asignar participación |
| POST | `/households/{household_id}/tasks/{task_id}/participations/{participation_id}/completion` | Confirmar mi parte |
| GET | `/households/{household_id}/tasks/{task_id}/events` | Historial de la tarea |
| GET | `/households/{household_id}/routines` | Listar rutinas |
| POST | `/households/{household_id}/routines` | Crear rutina |
| GET | `/households/{household_id}/routines/{routine_id}` | Detalle de rutina |
| PUT | `/households/{household_id}/routines/{routine_id}` | Editar rutina |
| DELETE | `/households/{household_id}/routines/{routine_id}` | Terminar rutina |
| POST | `/households/{household_id}/unplanned-tasks` | Registrar imprevisto |
| GET | `/households/{household_id}/tasks/{task_id}/comments` | Listar comentarios |
| POST | `/households/{household_id}/tasks/{task_id}/comments` | Comentar |
| PATCH | `/households/{household_id}/tasks/{task_id}/comments/{comment_id}` | Editar mi comentario |
| DELETE | `/households/{household_id}/tasks/{task_id}/comments/{comment_id}` | Eliminar mi comentario |
| POST | `/households/{household_id}/tasks/{task_id}/comments/{comment_id}/moderation` | Moderar comentario |
| GET | `/households/{household_id}/swap-requests` | Listar intercambios |
| POST | `/households/{household_id}/swap-requests` | Proponer intercambio o cesión |
| GET | `/households/{household_id}/swap-requests/{swap_request_id}` | Detalle de intercambio |
| POST | `/households/{household_id}/swap-requests/{swap_request_id}/accept` | Aceptar |
| POST | `/households/{household_id}/swap-requests/{swap_request_id}/decline` | Rechazar |
| POST | `/households/{household_id}/swap-requests/{swap_request_id}/cancel` | Cancelar |
| GET | `/notifications` | Bandeja de avisos |
| POST | `/notifications/{notification_id}/read` | Marcar aviso como leído |
| POST | `/notifications/read-all` | Marcar todos como leídos |
| GET | `/households/{household_id}/dashboard` | Panel personal |
| GET | `/households/{household_id}/load` | Distribución de carga |
| GET | `/households/{household_id}/load/members/{user_id}` | Detalle de carga de un integrante |
| GET | `/households/{household_id}/suggestions` | Sugerencias de redistribución |
| GET | `/households/{household_id}/suggestions/{suggestion_id}` | Detalle de sugerencia |
| POST | `/households/{household_id}/suggestions/{suggestion_id}/agreement` | Responder sugerencia |
| POST | `/households/{household_id}/suggestions/{suggestion_id}/approval` | Aprobar sugerencia |
| POST | `/households/{household_id}/suggestions/{suggestion_id}/dismissal` | Descartar sugerencia |
| GET | `/households/{household_id}/statistics` | Estadísticas |
| GET | `/households/{household_id}/history` | Historial del hogar |

---

### 11.1 Salud

#### `GET /health/live` — Público

Responde mientras el proceso esté vivo.

`200`: `{ "status": "ok" }`

#### `GET /health/ready` — Público

Comprueba la conexión con la base de datos.

`200`: `{ "status": "ok" }`. `503 SERVICE_UNAVAILABLE` si una dependencia no responde.

---

### 11.2 Autenticación (N1)

#### `POST /auth/phone-verifications` — Público

Envía un código SMS (S2, S11).

```json
{ "phone": "+56987654321", "purpose": "registration" }
```

| Campo | Tipo | Reglas |
| --- | --- | --- |
| `phone` | `PhoneNumber` | Obligatorio. |
| `purpose` | `registration` \| `password_reset` | Obligatorio. |

`202` → `PhoneVerification`

```json
{
  "verification_id": "0b7c1d2e-3f40-4a51-8b62-7c83d94ea5f6",
  "phone": "+56987654321",
  "purpose": "registration",
  "expires_at": "2026-10-04T15:40:00Z",
  "resend_available_at": "2026-10-04T15:31:00Z"
}
```

| Error | Cuándo |
| --- | --- |
| `409 PHONE_ALREADY_REGISTERED` | `registration` con un número que ya tiene cuenta. |
| `502 SMS_DELIVERY_FAILED` | Twilio rechazó el envío. |

Con `password_reset` y un número sin cuenta, la respuesta es igualmente `202`, pero no se envía SMS. Así no se revela qué números están registrados.

#### `POST /auth/phone-verifications/{verification_id}/resend` — Público

Envía un código nuevo e invalida el anterior. Reinicia los intentos y la vigencia.

`202` → `PhoneVerification`

| Error | Cuándo |
| --- | --- |
| `404 VERIFICATION_NOT_FOUND` | No existe. |
| `410 VERIFICATION_EXPIRED` | La verificación ya se usó. |
| `429 VERIFICATION_RESEND_TOO_SOON` | Antes de `resend_available_at`. |
| `502 SMS_DELIVERY_FAILED` | Falló el envío. |

#### `POST /auth/phone-verifications/{verification_id}/confirm` — Público

Valida el código (S3, S12).

```json
{ "code": "482715" }
```

`200` → `VerificationToken`

```json
{ "verification_token": "eyJhbGciOiJIUzI1NiJ9...", "expires_at": "2026-10-04T15:45:00Z" }
```

| Error | Cuándo |
| --- | --- |
| `400 VERIFICATION_CODE_INVALID` | Código incorrecto; `details.remaining_attempts`. |
| `404 VERIFICATION_NOT_FOUND` | No existe. |
| `410 VERIFICATION_EXPIRED` | Pasaron 10 minutos o ya se usó. |
| `429 VERIFICATION_ATTEMPTS_EXCEEDED` | Se agotaron los 5 intentos. |

#### `POST /auth/register` — Público

Crea la cuenta. La app guarda en memoria lo ingresado en S4 (contraseña), S5 (nombre) y S6/S7 (personaje), y lo envía todo junto al tocar «Crear mi cuenta».

```json
{
  "verification_token": "eyJhbGciOiJIUzI1NiJ9...",
  "password": "Equilibrio1",
  "name": "Marta",
  "avatar": "indigo"
}
```

| Campo | Tipo | Reglas |
| --- | --- | --- |
| `verification_token` | string | Obligatorio; de una verificación `registration`. |
| `password` | string | Reglas de contraseña. |
| `name` | string | 1–40 caracteres. |
| `avatar` | `Avatar` \| null | null si se eligió «Hacerlo más tarde». |

`201` → `AuthSession`

| Error | Cuándo |
| --- | --- |
| `401 INVALID_VERIFICATION_TOKEN` | Token inválido, expirado, ya usado o de otro propósito. |
| `409 PHONE_ALREADY_REGISTERED` | Alguien registró el número entretanto. |

#### `POST /auth/login` — Público

Inicia sesión (S9).

```json
{ "phone": "+56987654321", "password": "Equilibrio1" }
```

`200` → `AuthSession`

| Error | Cuándo |
| --- | --- |
| `401 INVALID_CREDENTIALS` | Número o contraseña incorrectos; `details.remaining_attempts` (S10: «Te quedan 4 intentos»). Un número inexistente responde lo mismo. |
| `423 ACCOUNT_LOCKED` | 5 fallos seguidos; `details.retry_after_seconds`. |

Un inicio de sesión correcto reinicia el contador de intentos.

#### `POST /auth/refresh` — Público

```json
{ "refresh_token": "q3Yt7..." }
```

`200` → `TokenPair`

| Error | Cuándo |
| --- | --- |
| `401 INVALID_REFRESH_TOKEN` | Inválido, expirado, revocado o reutilizado. La app cierra la sesión. |

#### `POST /auth/logout`

```json
{ "refresh_token": "q3Yt7..." }
```

`204`. Revoca la sesión. Es idempotente: repetirlo también responde `204`.

#### `POST /auth/password-reset` — Público

S13, «Guardar y entrar».

```json
{ "verification_token": "eyJhbGciOiJIUzI1NiJ9...", "new_password": "NuevaClave2" }
```

`200` → `AuthSession`. Revoca todas las sesiones anteriores y desbloquea la cuenta.

| Error | Cuándo |
| --- | --- |
| `401 INVALID_VERIFICATION_TOKEN` | Token inválido o de otro propósito. |

---

### 11.3 Usuarios

#### `GET /users/me`

`200` → `User`

#### `PATCH /users/me`

Cambia el nombre de la cuenta, el personaje o el hogar activo. El hogar activo es el último usado (RF09).

```json
{ "name": "Marta", "avatar": "sky", "active_household_id": "5d0f8e2a-1b3c-4d5e-8f60-718293a4b5c6" }
```

Todos los campos son opcionales, pero debe enviarse al menos uno. `active_household_id` debe ser un hogar del usuario; si no, responde `404 HOUSEHOLD_NOT_FOUND`.

`200` → `User`

#### `POST /users/me/devices`

Registra el token de Firebase Cloud Messaging del dispositivo para las notificaciones push (RF07). Registrar el mismo token otra vez no lo duplica.

```json
{ "platform": "android", "push_token": "fcm-token..." }
```

`201` → `Device`

#### `DELETE /users/me/devices/{device_id}`

`204`. Se llama al cerrar sesión.

#### `GET /users/me/notification-settings`

`200` → `NotificationSettings`

#### `PUT /users/me/notification-settings`

Reemplaza los ajustes de avisos (RF07).

```json
{
  "muted": false,
  "muted_types": ["swap_resolved"],
  "quiet_hours": { "start": "22:00", "end": "07:00" },
  "reminder_lead_minutes": 60
}
```

`200` → `NotificationSettings`

---

### 11.4 Hogares e invitaciones (RF01)

#### `GET /households`

Hogares en los que el usuario es integrante activo.

`200` → `HouseholdSummary[]`

#### `POST /households` — Idempotente

A3. Quien crea el hogar queda como administrador. Se genera un código de invitación y el hogar pasa a ser el activo del usuario.

```json
{ "name": "Casa Los Robles", "timezone": "America/Santiago" }
```

| Campo | Tipo | Reglas |
| --- | --- | --- |
| `name` | string | 1–40 caracteres. |
| `timezone` | string | Opcional; zona IANA válida. Por defecto `America/Santiago`. |

`201` → `HouseholdDetail`

#### `GET /households/{household_id}`

`200` → `HouseholdDetail`, con los integrantes activos.

#### `PATCH /households/{household_id}` — Admin

```json
{ "version": 3, "name": "Casa Robles", "timezone": "America/Santiago", "imbalance_threshold_percent": 15 }
```

`version` es obligatorio, junto con al menos otro campo. `imbalance_threshold_percent` (1–100 o null) es la diferencia, en puntos porcentuales, entre la carga y la capacidad a partir de la cual hay desequilibrio (RF06, RF08). Con null no se generan sugerencias.

`200` → `HouseholdDetail`

| Error | Cuándo |
| --- | --- |
| `403 ADMIN_REQUIRED` | No es administrador. |
| `412 VERSION_CONFLICT` | Otra persona lo editó. |

#### `GET /households/{household_id}/invitation` — Admin

A4. Devuelve el código vigente; si no hay uno vigente, lo crea.

`200` → `Invitation`

```json
{ "code": "7QK2-M9XA", "expires_at": "2026-10-11T15:30:00Z", "share_url": "https://hogarapp.cl/unirse/7QK2-M9XA" }
```

#### `POST /households/{household_id}/invitation/regenerate` — Admin

Revoca el código anterior y crea otro con 7 días de vigencia.

`201` → `Invitation`

#### `GET /invitations/{code}`

A10. Muestra a qué hogar lleva el código antes de unirse. `code` admite mayúsculas o minúsculas y guion opcional.

`200` → `InvitationPreview`

```json
{ "household_id": "5d0f8e2a-1b3c-4d5e-8f60-718293a4b5c6", "household_name": "Casa Los Robles", "member_count": 4, "expires_at": "2026-10-11T15:30:00Z" }
```

| Error | Cuándo |
| --- | --- |
| `404 INVITATION_NOT_FOUND` | No existe o fue regenerado. |
| `410 INVITATION_EXPIRED` | Expiró. |

#### `POST /invitations/{code}/accept`

A10, «Unirme al hogar». Entra como `member`, con un perfil doméstico vacío en ese hogar (RF02). El hogar pasa a ser el activo.

`201` → `HouseholdDetail`

| Error | Cuándo |
| --- | --- |
| `404 INVITATION_NOT_FOUND` | No existe. |
| `410 INVITATION_EXPIRED` | Expiró. |
| `409 ALREADY_MEMBER` | Ya pertenece al hogar. |

#### `PATCH /households/{household_id}/members/{user_id}` — Admin

Cambia el rol de un integrante. Transferir la administración consiste en dar `admin` a otra persona.

```json
{ "role": "admin" }
```

`200` → `Member`

| Error | Cuándo |
| --- | --- |
| `404 MEMBER_NOT_FOUND` | No es integrante activo. |
| `409 LAST_ADMIN_MUST_TRANSFER` | Quitaría el rol al último administrador. |

#### `DELETE /households/{household_id}/members/{user_id}` — Admin

Retira a un integrante. No se usa sobre uno mismo (para eso está `leave`). Sus participaciones no completadas quedan libres, su historial se conserva y pasa a figurar como antiguo integrante (RF16).

`204`

| Error | Cuándo |
| --- | --- |
| `404 MEMBER_NOT_FOUND` | No es integrante activo. |
| `409 CONFLICT` | `user_id` es el propio usuario. |

#### `POST /households/{household_id}/leave`

Abandona el hogar. Sus participaciones no completadas quedan libres y su historial se conserva.

`204`

| Error | Cuándo |
| --- | --- |
| `409 LAST_ADMIN_MUST_TRANSFER` | Es el único administrador, aunque sea el único integrante. Primero debe dar `admin` a otra persona (RF01). |

---

### 11.5 Perfiles (RF02, RF10, RF14)

Los datos del perfil son independientes en cada hogar (RF02). Cualquier integrante puede ver los perfiles de su hogar, pero solo el titular edita el suyo. Ni siquiera un administrador puede editar perfiles ajenos.

#### `GET /households/{household_id}/members/{user_id}/profile`

`user_id` puede ser un UUID o `me`.

`200` → `MemberProfile`

| Error | Cuándo |
| --- | --- |
| `404 MEMBER_NOT_FOUND` | No es integrante activo del hogar. |

#### `PATCH /households/{household_id}/members/me/profile`

A5. `proposed_capacity_percent` es una propuesta y no el reparto aprobado (RF18).

```json
{ "nickname": "Marta", "proposed_capacity_percent": 30 }
```

| Campo | Tipo | Reglas |
| --- | --- | --- |
| `nickname` | string \| null | 1–40 caracteres; null usa el nombre de la cuenta. |
| `proposed_capacity_percent` | `Percent` \| null | 0–100. |

`200` → `MemberProfile`

#### `PUT /households/{household_id}/members/me/availability`

A6. Reemplaza toda la disponibilidad. Un tramo que no aparece en `slots` significa «no disponible».

```json
{
  "slots": [
    { "weekday": 0, "period": "morning" },
    { "weekday": 0, "period": "afternoon" }
  ],
  "exceptions": [
    { "date": "2026-10-12", "period": null, "available": false }
  ]
}
```

| Campo | Reglas |
| --- | --- |
| `slots` | Hasta 21 elementos, sin repetidos. |
| `exceptions` | Hasta 100. `period: null` = todo el día. No puede haber dos excepciones para la misma fecha y franja, ni una de día completo junto a otra de franja en la misma fecha. |

`200` → `Availability`

#### `POST /households/{household_id}/members/me/restrictions`

A6, «Añadir restricción», y A7, «Tareas que no puedo hacer». Una restricción apunta a una categoría o a una actividad del catálogo. No se guarda texto libre ni información de salud (RF10). Es una restricción dura: ni la asignación manual ni las sugerencias pueden ignorarla (RF14).

```json
{
  "target": { "type": "category", "key": "food" },
  "kind": "temporary",
  "starts_on": "2026-10-04",
  "ends_on": "2027-03-30"
}
```

| Campo | Reglas |
| --- | --- |
| `target.type` | `category` \| `activity`. |
| `target.key` | Clave existente en el catálogo. |
| `kind` | `permanent` \| `temporary`. |
| `starts_on` | Opcional; por defecto hoy. |
| `ends_on` | Obligatorio si es `temporary` y no anterior a `starts_on`. Debe omitirse si es `permanent`. |

`201` → `Restriction`

| Error | Cuándo |
| --- | --- |
| `409 CONFLICT` | Ya existe una restricción vigente sobre el mismo objetivo. |

Al crear una restricción, las participaciones no completadas que la incumplen no se reasignan solas: la persona puede cederlas mediante un intercambio (RF10, RF11).

#### `PUT /households/{household_id}/members/me/restrictions/{restriction_id}`

Mismo cuerpo que al crear. `200` → `Restriction`

#### `DELETE /households/{household_id}/members/me/restrictions/{restriction_id}`

`204`

#### `PUT /households/{household_id}/members/me/preferences`

A7, «Tareas que prefiero». Una preferencia no es una obligación.

```json
{ "preferred_activity_keys": ["cook", "weekly_shopping", "water_plants"] }
```

| Regla | Detalle |
| --- | --- |
| Máximo | 50 claves, sin repetidos. |
| Compatibilidad | Una actividad con una restricción vigente (sobre la propia actividad o su categoría) no puede ser preferida: `422`, código de campo `conflicting_values`. |

`200` → `Preferences`

---

### 11.6 Capacidad (RF18)

#### `GET /households/{household_id}/capacity`

Muestra el reparto vigente, el programado para el siguiente periodo (si existe) y las propuestas actuales de cada integrante.

`200` → `CapacityOverview`

#### `POST /households/{household_id}/capacity/distributions` — Admin, Idempotente

Aprueba un reparto completo. Se aplica desde el lunes siguiente en la zona del hogar y nunca de forma retroactiva. Aprobarlo no modifica otros datos del perfil.

```json
{
  "allocations": [
    { "user_id": "3f6c2a4e-8b1d-4c2a-9a57-1e2f3d4c5b6a", "percent": 30 },
    { "user_id": "9a1b2c3d-4e5f-4a6b-8c7d-0e1f2a3b4c5d", "percent": 70 }
  ]
}
```

`201` → `CapacityDistribution`

| Error | Cuándo |
| --- | --- |
| `422 CAPACITY_SUM_INVALID` | No suma 100, no incluye exactamente a todos los integrantes activos o todos los valores son 0. |

Un reparto aprobado para el próximo periodo y todavía no vigente se reemplaza si se aprueba otro.

#### `GET /households/{household_id}/capacity/distributions`

Historial de repartos, del más reciente al más antiguo. Paginado.

`200` → `{ items: CapacityDistribution[], next_cursor }`

---

### 11.7 Catálogo

El catálogo lo define el equipo y es igual para todos los hogares.

#### `GET /catalog/task-categories`

`200` → `TaskCategory[]`

```json
[{ "key": "food", "name": "Alimentación" }, { "key": "pets", "name": "Mascotas" }]
```

#### `GET /catalog/activities`

Parámetro opcional `category_key`.

`200` → `Activity[]`

```json
[{ "key": "laundry_load", "name": "Poner la lavadora", "category_key": "laundry" }]
```

---

### 11.8 Plantillas (RF17)

#### `GET /household-templates`

A9. Plantillas predefinidas por el equipo; no existen plantillas creadas por usuarios.

`200` → `TemplateSummary[]`

#### `GET /household-templates/{template_key}`

`200` → `TemplateDetail`

#### `GET /households/{household_id}/template-application`

`200` → `TemplateApplication`. `404 NOT_FOUND` si el hogar todavía no decidió.

#### `POST /households/{household_id}/template-application` — Admin, Idempotente

Se puede usar una sola vez por hogar, durante su creación. Admite combinar varias plantillas. Una lista vacía equivale a «Empezar vacío» y también cierra la decisión. Genera las tareas y rutinas de las plantillas como tareas libres o rutinas libres, sin asignar a terceros (RF03, RF14).

```json
{ "template_keys": ["family_with_children", "pets"] }
```

`201` → `TemplateApplication`

| Error | Cuándo |
| --- | --- |
| `409 TEMPLATES_ALREADY_APPLIED` | El hogar ya decidió. |
| `422 VALIDATION_ERROR` | Plantilla inexistente (`unknown_key`). |

---

### 11.9 Tareas (RF03, RF05)

Una tarea tiene una o más **participaciones**: una si es individual y entre 2 y 10 si es compartida. Cada participación puede tener responsable o estar libre. Cada responsable confirma su parte y la carga se divide por igual entre las participaciones.

Estados (RF05):

| Estado | Regla |
| --- | --- |
| `pending` | No completada y dentro de plazo. |
| `overdue` | No completada y pasada la fecha (`due_date` + `due_time`, o el fin del día si `due_time` es null), en la zona del hogar. Se calcula sola. |
| `completed` | Todas las participaciones confirmadas. No se reabre ni se edita. |

No existe un estado «en curso» ni se registra el inicio.

#### `GET /households/{household_id}/tasks`

Ordenadas por vencimiento ascendente. Excluye las eliminadas. Paginado.

| Parámetro | Descripción |
| --- | --- |
| `status` | Uno o varios separados por coma: `pending,overdue`. |
| `assignee` | `me`, `free` (con alguna participación libre) o el UUID de un integrante. |
| `due_from`, `due_to` | Rango de vencimiento (`LocalDate`). |
| `category_key` | Filtra por categoría. |
| `routine_id` | Ocurrencias de una rutina. |
| `cursor`, `limit` | Paginación. |

`200` → `{ items: Task[], next_cursor }`

#### `POST /households/{household_id}/tasks` — Idempotente

```json
{
  "title": "Fregar el baño",
  "description": "Usar el producto sin lejía",
  "category_key": "cleaning",
  "activity_key": "bathroom_cleaning",
  "due_date": "2026-10-06",
  "due_time": "20:00",
  "estimated_duration_minutes": 30,
  "effort": 3,
  "mental_load": 2,
  "priority": "medium",
  "kind": "individual",
  "participant_count": 1,
  "assignee_user_ids": []
}
```

| Campo | Obligatorio | Reglas |
| --- | :---: | --- |
| `title` | Sí | 1–80 caracteres. |
| `description` | No | Hasta 500 caracteres. |
| `category_key` | Sí | Categoría existente. |
| `activity_key` | No | Actividad de esa categoría. |
| `due_date` | Sí | Fecha o plazo. |
| `due_time` | No | null = fin del día. |
| `estimated_duration_minutes` | Sí | 1–1440. |
| `effort` | Sí | 1–5. |
| `mental_load` | Sí | 1–5. |
| `priority` | No | Por defecto `medium`. |
| `kind` | Sí | `individual` \| `shared`. |
| `participant_count` | No | `individual` → 1; `shared` → 2–10. |
| `assignee_user_ids` | No | Como máximo `participant_count`, sin repetidos. Las participaciones restantes quedan libres. |

`201` → `Task`

| Error | Cuándo |
| --- | --- |
| `403 ADMIN_REQUIRED` | Un no administrador incluye en `assignee_user_ids` a alguien distinto de sí mismo. |
| `404 MEMBER_NOT_FOUND` | Algún responsable no es integrante activo. |
| `409 ASSIGNEE_RESTRICTED` | Algún responsable tiene una restricción vigente. |

#### `GET /households/{household_id}/tasks/{task_id}`

`200` → `Task`

#### `PATCH /households/{household_id}/tasks/{task_id}`

Cualquier integrante. Campos editables: los de creación excepto `kind`, `participant_count` y `assignee_user_ids`. Requiere `version`.

```json
{ "version": 2, "due_date": "2026-10-07", "priority": "high" }
```

`200` → `Task`

| Error | Cuándo |
| --- | --- |
| `409 TASK_COMPLETED_LOCKED` | La tarea está completada, también para administradores. |
| `409 ASSIGNEE_RESTRICTED` | El cambio de categoría o actividad choca con la restricción de un responsable. |
| `412 VERSION_CONFLICT` | Otra persona la editó. |

#### `DELETE /households/{household_id}/tasks/{task_id}`

Borrado lógico: el historial y las estadísticas anteriores se conservan (RF03, RF16). Cancela las solicitudes de intercambio pendientes que la incluyan.

`204`

#### `POST /households/{household_id}/tasks/{task_id}/participations/{participation_id}/take` — Idempotente

El usuario toma una participación libre. Una persona no puede tener dos participaciones de la misma tarea.

`200` → `Task`

| Error | Cuándo |
| --- | --- |
| `409 PARTICIPATION_NOT_AVAILABLE` | Ya tiene responsable o está completada. |
| `409 ASSIGNEE_RESTRICTED` | El usuario tiene una restricción vigente. |
| `409 CONFLICT` | Ya tiene otra participación en la tarea. |

#### `POST /households/{household_id}/tasks/{task_id}/participations/{participation_id}/release`

Libera la participación propia mientras no esté completada. Queda libre y el cambio se registra.

`200` → `Task`

| Error | Cuándo |
| --- | --- |
| `403 PARTICIPATION_NOT_OWNED` | No es suya. |
| `409 PARTICIPATION_NOT_AVAILABLE` | Ya está completada. |

#### `PUT /households/{household_id}/tasks/{task_id}/participations/{participation_id}/assignee` — Admin

Asigna sin aceptación del destinatario (RF03). `user_id: null` deja la participación libre.

```json
{ "user_id": "9a1b2c3d-4e5f-4a6b-8c7d-0e1f2a3b4c5d" }
```

`200` → `Task`

| Error | Cuándo |
| --- | --- |
| `409 PARTICIPATION_NOT_AVAILABLE` | Está completada. |
| `409 ASSIGNEE_RESTRICTED` | El destinatario tiene una restricción vigente. |
| `409 CONFLICT` | El destinatario ya tiene otra participación en la tarea. |

#### `POST /households/{household_id}/tasks/{task_id}/participations/{participation_id}/completion` — Idempotente

RF05. Solo quien es responsable confirma su parte; un administrador no confirma por otra persona. Registra quién, cuándo y la duración real.

```json
{ "actual_duration_minutes": 35 }
```

`200` → `Task`. La tarea pasa a `completed` cuando se confirman todas sus participaciones. Al completarse, se cancelan las solicitudes de intercambio y las sugerencias pendientes que la incluyan.

| Error | Cuándo |
| --- | --- |
| `403 PARTICIPATION_NOT_OWNED` | No es responsable de la participación. |
| `409 PARTICIPATION_NOT_AVAILABLE` | Ya está completada. |

#### `GET /households/{household_id}/tasks/{task_id}/events`

Historial de la tarea, del evento más antiguo al más reciente. Paginado.

`200` → `{ items: TaskEvent[], next_cursor }`

---

### 11.10 Rutinas (RF04)

#### `GET /households/{household_id}/routines`

Parámetro opcional `active=true` para excluir rutinas terminadas. Paginado.

`200` → `{ items: Routine[], next_cursor }`

#### `POST /households/{household_id}/routines` — Idempotente

```json
{
  "title": "Pasear al perro",
  "category_key": "pets",
  "activity_key": "dog_walk",
  "due_time": "20:00",
  "estimated_duration_minutes": 30,
  "effort": 2,
  "mental_load": 1,
  "priority": "medium",
  "recurrence": { "frequency": "weekly", "weekdays": [0, 2, 4] },
  "starts_on": "2026-10-05",
  "ends_on": "2026-12-31",
  "assignment": { "mode": "rotating", "member_ids": ["3f6c2a4e-8b1d-4c2a-9a57-1e2f3d4c5b6a", "9a1b2c3d-4e5f-4a6b-8c7d-0e1f2a3b4c5d"] }
}
```

`recurrence`:

| `frequency` | Campo requerido | Significado |
| --- | --- | --- |
| `daily` | — | Todos los días. |
| `weekly` | `weekdays` (al menos 1) | Los días indicados. |
| `monthly` | `day_of_month` (1–31) | Ese día de cada mes; si el mes no lo tiene, el último día del mes. |
| `interval` | `interval_days` (2–365) | Cada N días desde `starts_on`. |

`assignment`:

| `mode` | `member_ids` | Quién puede usarlo |
| --- | --- | --- |
| `fixed` | Exactamente 1 | Cualquiera consigo mismo; un administrador con cualquier integrante. |
| `rotating` | 2 o más, en orden (alternar entre dos es una rotación) | Solo administradores. |
| `free` | Vacío | Cualquiera. |

Reglas:

- Las ocurrencias son tareas individuales con `routine_id` y `origin: routine`. Se generan con 28 días de anticipación, en la zona horaria del hogar.
- En una rotación, si a quien le toca no está disponible ese día o tiene una restricción vigente, el turno pasa a la siguiente persona que sí pueda. Si nadie puede, la ocurrencia queda libre y se avisa a los administradores (`routine_without_candidate`).
- `ends_on` es inclusiva; null = sin término.

`201` → `Routine`

| Error | Cuándo |
| --- | --- |
| `403 ADMIN_REQUIRED` | Un no administrador usa `rotating` o asigna a otra persona. |
| `409 ASSIGNEE_RESTRICTED` | En `fixed`, la persona tiene una restricción vigente. |

#### `GET /households/{household_id}/routines/{routine_id}`

`200` → `Routine`

#### `PUT /households/{household_id}/routines/{routine_id}`

Mismo cuerpo que al crear, más `version`. Los cambios solo afectan a las ocurrencias futuras no completadas; las anteriores y las completadas se conservan. Mismas reglas de permisos que al crear.

`200` → `Routine`. Errores: los de creación y `412 VERSION_CONFLICT`.

#### `DELETE /households/{household_id}/routines/{routine_id}`

Termina la rutina: elimina las ocurrencias futuras no completadas y conserva el historial. Un no administrador solo puede terminar las rutinas que creó.

`204`

---

### 11.11 Imprevistos (RF12)

#### `POST /households/{household_id}/unplanned-tasks` — Idempotente

Registra una tarea imprevista que el propio usuario ya hizo.

```json
{
  "title": "Destapar el lavaplatos",
  "category_key": "maintenance",
  "activity_key": null,
  "performed_on": "2026-10-03",
  "actual_duration_minutes": 40,
  "effort": 4,
  "mental_load": 2,
  "priority": "high",
  "confirm_despite_similar": false
}
```

| Regla | Detalle |
| --- | --- |
| Autoría | Siempre queda a nombre de quien la registra. |
| Fecha | `performed_on` entre hoy y 7 días atrás, en la zona del hogar. |
| Parecidas | Si existen tareas no eliminadas de la misma categoría (o la misma actividad) con fecha a ±1 día de `performed_on` y `confirm_despite_similar` es `false`, responde `409 SIMILAR_TASKS_FOUND`. La app muestra el aviso y reenvía con `true` si la persona confirma. |
| Resultado | Tarea `completed`, `origin: unplanned`, con `estimated_duration_minutes` igual a la duración real. Cuenta en la carga realizada del periodo de `performed_on`. |

`201` → `Task`

| Error | Cuándo |
| --- | --- |
| `409 SIMILAR_TASKS_FOUND` | `details.similar_tasks`: lista de `SimilarTask`. |
| `422 UNPLANNED_TASK_OUT_OF_RANGE` | Fecha futura o de hace más de 7 días. |

---

### 11.12 Comentarios (RF15)

Cualquier integrante comenta cualquier tarea, también después de completada. Comentar no modifica la tarea ni su carga.

#### `GET /households/{household_id}/tasks/{task_id}/comments`

Del más antiguo al más reciente. Paginado. Los comentarios moderados aparecen con `status: moderated`, sin texto ni fotos.

`200` → `{ items: Comment[], next_cursor }`

#### `POST /households/{household_id}/tasks/{task_id}/comments` — Idempotente

`multipart/form-data`:

| Parte | Reglas |
| --- | --- |
| `text` | Opcional; hasta 1000 caracteres. |
| `photos` | Opcional; hasta 4 archivos JPEG, PNG o WebP de máximo 5 MB cada uno. |

Debe haber texto o al menos una foto. El servidor elimina los metadatos EXIF (incluida la ubicación).

`201` → `Comment`

| Error | Cuándo |
| --- | --- |
| `413 ATTACHMENT_TOO_LARGE` | Una foto supera 5 MB. |
| `415 UNSUPPORTED_MEDIA_TYPE` | Formato no admitido. |

#### `PATCH /households/{household_id}/tasks/{task_id}/comments/{comment_id}`

Solo el autor. Edita el texto; las fotos se mantienen.

```json
{ "text": "Ya compré el producto nuevo" }
```

`200` → `Comment`. `403 FORBIDDEN` si no es el autor.

#### `DELETE /households/{household_id}/tasks/{task_id}/comments/{comment_id}`

Solo el autor. `204`

#### `POST /households/{household_id}/tasks/{task_id}/comments/{comment_id}/moderation` — Admin

Oculta el comentario y registra quién, cuándo y por qué.

```json
{ "reason": "Contenido ofensivo" }
```

`200` → `Comment`

---

### 11.13 Intercambios y ayuda (RF11)

Dos tipos de solicitud:

| `type` | Qué propone | Quién acepta |
| --- | --- | --- |
| `swap` | Intercambiar mi participación por la de otra persona. | La persona responsable de `requested_participation_id`. |
| `handover` | Ceder mi participación sin recibir nada a cambio (pedir ayuda). | `recipient_user_id`; si es null, cualquier integrante que pueda asumirla. |

No requiere aprobación de administración y no caduca por tiempo. Se cancela sola si alguna tarea involucrada se completa o se elimina.

#### `GET /households/{household_id}/swap-requests`

| Parámetro | Descripción |
| --- | --- |
| `status` | `pending` \| `accepted` \| `declined` \| `cancelled`. |
| `direction` | `incoming` (puedo aceptarla) \| `outgoing` (la propuse). |
| `cursor`, `limit` | Paginación. Orden: más recientes primero. |

`200` → `{ items: SwapRequest[], next_cursor }`

#### `POST /households/{household_id}/swap-requests` — Idempotente

```json
{
  "type": "swap",
  "offered_participation_id": "a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d",
  "requested_participation_id": "b2c3d4e5-f6a7-4b8c-9d0e-1f2a3b4c5d6e",
  "recipient_user_id": null,
  "message": "¿Te cambio la lavadora por la compra?"
}
```

| Campo | Reglas |
| --- | --- |
| `offered_participation_id` | Obligatorio. Debe ser mía y no estar completada. |
| `requested_participation_id` | Obligatorio en `swap`; debe tener otro responsable y no estar completada. Prohibido en `handover`. |
| `recipient_user_id` | Solo en `handover`. Opcional. |
| `message` | Opcional; hasta 200 caracteres. |

`201` → `SwapRequest`

| Error | Cuándo |
| --- | --- |
| `403 PARTICIPATION_NOT_OWNED` | La participación ofrecida no es mía. |
| `409 PARTICIPATION_NOT_AVAILABLE` | Alguna participación está completada o libre. |
| `409 CONFLICT` | Ya hay una solicitud pendiente sobre esa participación. |

#### `GET /households/{household_id}/swap-requests/{swap_request_id}`

`200` → `SwapRequest`

#### `POST /households/{household_id}/swap-requests/{swap_request_id}/accept` — Idempotente

Ejecuta el cambio de forma atómica y lo registra en el historial de las tareas (`swapped` o `handed_over`).

`200` → `SwapRequest`

| Error | Cuándo |
| --- | --- |
| `403 FORBIDDEN` | No le corresponde aceptarla. |
| `409 SWAP_REQUEST_NOT_PENDING` | Ya resuelta o cancelada. |
| `409 ASSIGNEE_RESTRICTED` | Quien recibe una participación tiene una restricción vigente sobre ella. |

#### `POST /households/{household_id}/swap-requests/{swap_request_id}/decline`

Quien debía aceptarla la rechaza. En un `handover` abierto (sin destinatario) no aplica: basta con no aceptarlo.

`200` → `SwapRequest`. Errores: `403 FORBIDDEN`, `409 SWAP_REQUEST_NOT_PENDING`.

#### `POST /households/{household_id}/swap-requests/{swap_request_id}/cancel`

Quien la propuso la retira.

`200` → `SwapRequest`. Errores: `403 FORBIDDEN`, `409 SWAP_REQUEST_NOT_PENDING`.

---

### 11.14 Notificaciones (RF07)

Los avisos llegan como notificación push (Firebase Cloud Messaging) y quedan en la bandeja. No se envían correos.

| `type` | Destinatario | Cuándo |
| --- | --- | --- |
| `task_reminder` | Responsables | `reminder_lead_minutes` antes del vencimiento. |
| `task_due` | Responsables | Al vencer sin completar. Una sola vez, sin repetición. |
| `routine_without_candidate` | Administradores | Ocurrencia de rutina que quedó libre por falta de candidatos. |
| `swap_request` | Quien puede aceptarla | Nueva solicitud de intercambio. |
| `swap_resolved` | Quien la propuso | Aceptada, rechazada o cancelada. |
| `suggestion_pending` | Involucrados y administradores | Sugerencia que espera respuesta. |
| `suggestion_resolved` | Involucrados | Sugerencia aprobada, descartada u obsoleta. |
| `member_joined` | Administradores | Alguien se unió con el código. |

Reglas: si `muted` es `true` o el tipo está en `muted_types`, no se genera el aviso. Los avisos que caen dentro de `quiet_hours` se descartan y no se posponen. Si `reminder_lead_minutes` es null, no se envían recordatorios previos; solo el aviso al vencer.

#### `GET /notifications`

| Parámetro | Descripción |
| --- | --- |
| `unread_only` | `true` para solo no leídos. |
| `household_id` | Filtra por hogar. |
| `cursor`, `limit` | Paginación. Orden: más recientes primero. |

`200` → `{ items: Notification[], next_cursor, unread_count }`

#### `POST /notifications/{notification_id}/read`

`204`

#### `POST /notifications/read-all`

Parámetro opcional `household_id`. `204`

---

### 11.15 Panel (RF09)

#### `GET /households/{household_id}/dashboard`

Panel personal del hogar activo: mi carga de la semana, mis tareas atrasadas y de hoy, y las tareas disponibles para tomar. Consultarlo actualiza `active_household_id` del usuario.

`200` → `Dashboard`

```json
{
  "household": { "id": "5d0f8e2a-1b3c-4d5e-8f60-718293a4b5c6", "name": "Casa Los Robles", "my_role": "admin", "member_count": 4, "created_at": "2026-10-04T15:30:00Z" },
  "week": { "start": "2026-09-28", "end": "2026-10-04" },
  "my_load": {
    "capacity_percent": 30,
    "planned": { "task_count": 6, "occurrence_count": 9, "duration_minutes": 240, "effort_points": 21, "mental_load_points": 14, "load_index": null },
    "completed": { "task_count": 4, "occurrence_count": 5, "duration_minutes": 150, "effort_points": 12, "mental_load_points": 8, "load_index": null }
  },
  "overdue": [],
  "today": [],
  "available": []
}
```

`overdue` y `today` contienen mis tareas. `available` contiene hasta 20 tareas con participaciones libres que vencen en los próximos 7 días o están atrasadas.

---

### 11.16 Carga (RF06, RF13)

La carga planificada (tareas asignadas, con duración estimada) y la realizada (participaciones completadas, con duración real si existe) se muestran siempre por separado. La prioridad no multiplica la carga. La carga de una tarea compartida se divide por igual entre sus participaciones; si dos personas registran duración, la duración de referencia es su media.

El SRS deja pendiente la fórmula del índice de carga (RF13). Hasta que el equipo la apruebe, `load_index` y los porcentajes derivados son `null`, y `formula_version` es `null`. Los factores (`duration_minutes`, `effort_points`, `mental_load_points`, `occurrence_count`) se entregan siempre, para mostrar de forma comprensible qué compone la carga.

#### `GET /households/{household_id}/load`

| Parámetro | Descripción |
| --- | --- |
| `period` | `week` \| `month`. Obligatorio. |
| `date` | Cualquier fecha del periodo. Por defecto hoy en la zona del hogar. |

`200` → `LoadDistribution`. Incluye el periodo anterior equivalente para comparar. Si no hay reparto de capacidad válido, `capacity_status` es `not_configured` y los campos de capacidad y desequilibrio son `null`.

#### `GET /households/{household_id}/load/members/{user_id}`

Detalle por tarea de la carga de un integrante. `user_id` puede ser `me`.

| Parámetro | Descripción |
| --- | --- |
| `period`, `date` | Como en el endpoint anterior. |
| `kind` | `planned` \| `completed`. Obligatorio. |

`200` → `MemberLoadBreakdown`

---

### 11.17 Sugerencias de redistribución (RF08)

El servidor genera las sugerencias con reglas deterministas, sin IA, cuando cambia la carga planificada y la diferencia entre carga y capacidad supera el umbral del hogar. Solo propone cambios sobre participaciones no completadas. Nunca propone a alguien con una restricción vigente sobre la tarea ni a quien tiene capacidad 0.

Flujo: `pending_agreement` → todos los involucrados aceptan → `pending_approval` → un administrador aprueba → `approved`, y la reasignación se ejecuta de forma atómica. Si alguien la rechaza pasa a `rejected`. Si cambian los datos y deja de ser válida pasa a `obsolete`. Un administrador puede descartarla (`dismissed`).

Si el hogar no tiene reparto de capacidad válido o umbral, no se generan sugerencias.

#### `GET /households/{household_id}/suggestions`

| Parámetro | Descripción |
| --- | --- |
| `status` | Uno o varios, separados por coma. |
| `cursor`, `limit` | Paginación. Orden: más recientes primero. |

`200` → `{ items: Suggestion[], next_cursor, generation_status }`. `generation_status` es `active`, `capacity_not_configured` o `threshold_not_configured`.

#### `GET /households/{household_id}/suggestions/{suggestion_id}`

`200` → `Suggestion`

#### `POST /households/{household_id}/suggestions/{suggestion_id}/agreement`

Solo integrantes involucrados (los que ceden o reciben una participación).

```json
{ "decision": "accept" }
```

`decision`: `accept` \| `decline`. `200` → `Suggestion`

| Error | Cuándo |
| --- | --- |
| `403 FORBIDDEN` | No está involucrado. |
| `409 SUGGESTION_NOT_PENDING` | Ya no espera acuerdo. |

#### `POST /households/{household_id}/suggestions/{suggestion_id}/approval` — Admin, Idempotente

Ejecuta la reasignación. Antes vuelve a validar restricciones y que ninguna participación se haya completado.

`200` → `Suggestion`

| Error | Cuándo |
| --- | --- |
| `409 SUGGESTION_NOT_PENDING` | No está en `pending_approval`, o quedó obsoleta al revalidar. |

#### `POST /households/{household_id}/suggestions/{suggestion_id}/dismissal` — Admin

`200` → `Suggestion`. `409 SUGGESTION_NOT_PENDING` si ya estaba resuelta.

---

### 11.18 Estadísticas e historial (RF16)

Incluyen a antiguos integrantes (`is_active: false`) y conservan el historial de tareas eliminadas. Los cambios de capacidad no recalculan periodos anteriores.

#### `GET /households/{household_id}/statistics`

| Parámetro | Descripción |
| --- | --- |
| `period` | `week` \| `month` \| `custom`. Obligatorio. |
| `date` | Con `week` o `month`: cualquier fecha del periodo. |
| `from`, `to` | Con `custom`: rango inclusivo de hasta 366 días. |

`200` → `Statistics`. `series` contiene un punto por semana (con `week` o `custom` de hasta 92 días) o por mes (con `month` o `custom` más largo).

#### `GET /households/{household_id}/history`

Eventos de todas las tareas del hogar. Paginado, del más reciente al más antiguo.

| Parámetro | Descripción |
| --- | --- |
| `from`, `to` | Rango de fechas. |
| `user_id` | Eventos donde participa esa persona. |
| `types` | Tipos de `TaskEvent` separados por coma. |

`200` → `{ items: HouseholdEvent[], next_cursor }`

---

## 12. Modelos

Tipos con la notación de TypeScript, para leerlos rápido. `?` no se usa: todos los campos de las respuestas están siempre presentes y los opcionales llevan `| null`.

### Identidad

```ts
PhoneVerification {
  verification_id: Uuid
  phone: PhoneNumber
  purpose: "registration" | "password_reset"
  expires_at: Timestamp
  resend_available_at: Timestamp
}

VerificationToken {
  verification_token: string
  expires_at: Timestamp
}

TokenPair {
  access_token: string
  refresh_token: string
  token_type: "bearer"
  expires_in: integer
}

User {
  id: Uuid
  phone: PhoneNumber
  name: string
  avatar: Avatar | null
  active_household_id: Uuid | null
  created_at: Timestamp
}

AuthSession {
  user: User
  tokens: TokenPair
}

Device {
  id: Uuid
  platform: "android"
  created_at: Timestamp
}

NotificationSettings {
  muted: boolean
  muted_types: NotificationType[]
  quiet_hours: { start: LocalTime, end: LocalTime } | null
  reminder_lead_minutes: integer | null
}
```

`expires_in` va en segundos (900). `quiet_hours` puede cruzar la medianoche (`22:00`–`07:00`). `reminder_lead_minutes` va de 5 a 10080 (una semana).

### Hogares

```ts
HouseholdSummary {
  id: Uuid
  name: string
  my_role: Role
  member_count: integer
  created_at: Timestamp
}

HouseholdDetail {
  id: Uuid
  name: string
  timezone: string
  imbalance_threshold_percent: integer | null
  my_role: Role
  members: Member[]
  templates_applied: boolean
  version: integer
  created_at: Timestamp
}

Member {
  user_id: Uuid
  name: string
  nickname: string | null
  avatar: Avatar | null
  role: Role
  joined_at: Timestamp
  is_me: boolean
}

Invitation {
  code: string
  expires_at: Timestamp
  share_url: string
}

InvitationPreview {
  household_id: Uuid
  household_name: string
  member_count: integer
  expires_at: Timestamp
}
```

`templates_applied` es `true` cuando ya se decidió la plantilla, incluido «Empezar vacío». `code` va en formato `XXXX-XXXX`.

### Perfiles y capacidad

```ts
MemberProfile {
  user_id: Uuid
  name: string
  nickname: string | null
  avatar: Avatar | null
  role: Role
  is_me: boolean
  proposed_capacity_percent: Percent | null
  approved_capacity_percent: Percent | null
  availability: Availability
  restrictions: Restriction[]
  preferences: Preferences
}

Availability {
  slots: { weekday: Weekday, period: DayPeriod }[]
  exceptions: { date: LocalDate, period: DayPeriod | null, available: boolean }[]
}

Restriction {
  id: Uuid
  target: { type: "category" | "activity", key: string }
  target_name: string
  kind: "permanent" | "temporary"
  starts_on: LocalDate
  ends_on: LocalDate | null
  is_active: boolean
  created_at: Timestamp
}

Preferences {
  preferred_activity_keys: string[]
}

CapacityOverview {
  status: "configured" | "not_configured"
  current: CapacityDistribution | null
  upcoming: CapacityDistribution | null
  proposals: { member: UserReference, proposed_capacity_percent: Percent | null }[]
}

CapacityDistribution {
  id: Uuid
  effective_from: LocalDate
  approved_by: UserReference
  approved_at: Timestamp
  allocations: { member: UserReference, percent: Percent }[]
}
```

`approved_capacity_percent` sale del reparto vigente. `target_name` es el nombre visible de la categoría o actividad. `is_active` indica si la restricción está vigente hoy.

### Catálogo y plantillas

```ts
TaskCategory {
  key: string
  name: string
}

Activity {
  key: string
  name: string
  category_key: string
}

TemplateSummary {
  key: string
  name: string
  description: string
  task_count: integer
}

TemplateDetail extends TemplateSummary {
  tasks: TemplateTask[]
}

TemplateTask {
  activity_key: string
  name: string
  category_key: string
  recurrence_label: string
  distribution: "fixed" | "rotating"
  estimated_duration_minutes: integer
  effort: Scale1To5
  mental_load: Scale1To5
}

TemplateApplication {
  template_keys: string[]
  task_count: integer
  applied_by: UserReference
  applied_at: Timestamp
}
```

`recurrence_label` es un texto listo para mostrar, por ejemplo «2 veces por semana».

### Tareas

```ts
Task {
  id: Uuid
  household_id: Uuid
  title: string
  description: string | null
  category_key: string
  category_name: string
  activity_key: string | null
  activity_name: string | null
  due_date: LocalDate
  due_time: LocalTime | null
  estimated_duration_minutes: integer
  effort: Scale1To5
  mental_load: Scale1To5
  priority: Priority
  kind: "individual" | "shared"
  status: "pending" | "overdue" | "completed"
  origin: "manual" | "routine" | "template" | "unplanned"
  participations: Participation[]
  reference_duration_minutes: number | null
  load_share: number
  routine_id: Uuid | null
  performed_on: LocalDate | null
  created_by: UserReference
  created_at: Timestamp
  updated_at: Timestamp
  completed_at: Timestamp | null
  version: integer
}

Participation {
  id: Uuid
  assignee: UserReference | null
  status: "pending" | "overdue" | "completed"
  completed_at: Timestamp | null
  actual_duration_minutes: integer | null
}

TaskEvent {
  id: Uuid
  type: "created" | "updated" | "assigned" | "taken" | "released" | "completed"
      | "swapped" | "handed_over" | "deleted" | "comment_moderated"
  actor: UserReference | null
  occurred_at: Timestamp
  data: object
}

HouseholdEvent extends TaskEvent {
  task: { id: Uuid, title: string, is_deleted: boolean }
}

SimilarTask {
  task_id: Uuid
  title: string
  date: LocalDate
  assignees: UserReference[]
}
```

Notas sobre los campos:

- `reference_duration_minutes`: media de las duraciones reales; null hasta que haya alguna.
- `load_share`: fracción de carga de cada participación (1 / número de participaciones).
- `performed_on`: solo en imprevistos.
- `assignee` null: participación libre.
- `actor` null: el cambio lo hizo el sistema (por ejemplo, una rotación).
- `data` de `TaskEvent`: detalle del cambio, por ejemplo `{ "participation_id", "from_user_id", "to_user_id", "changes": { "due_date": ["2026-10-06", "2026-10-07"] } }`.

### Rutinas

```ts
Routine {
  id: Uuid
  title: string
  description: string | null
  category_key: string
  activity_key: string | null
  due_time: LocalTime | null
  estimated_duration_minutes: integer
  effort: Scale1To5
  mental_load: Scale1To5
  priority: Priority
  recurrence: Recurrence
  recurrence_label: string
  starts_on: LocalDate
  ends_on: LocalDate | null
  assignment: { mode: "fixed" | "rotating" | "free", member_ids: Uuid[] }
  members: UserReference[]
  next_occurrence_on: LocalDate | null
  created_by: UserReference
  created_at: Timestamp
  version: integer
}

Recurrence {
  frequency: "daily" | "weekly" | "monthly" | "interval"
  weekdays: Weekday[] | null
  day_of_month: integer | null
  interval_days: integer | null
}
```

`recurrence_label` es un texto listo para mostrar, por ejemplo «Lunes, miércoles y viernes». `members` lista a las personas de `assignment.member_ids`, en el mismo orden.

### Comentarios

```ts
Comment {
  id: Uuid
  author: UserReference
  status: "visible" | "moderated"
  text: string | null
  photos: CommentPhoto[]
  created_at: Timestamp
  edited_at: Timestamp | null
  moderation: { moderated_by: UserReference, moderated_at: Timestamp, reason: string } | null
}

CommentPhoto {
  id: Uuid
  url: string
  content_type: "image/jpeg" | "image/png" | "image/webp"
  width: integer
  height: integer
}
```

`url` es una URL firmada, válida 15 minutos.

### Intercambios

```ts
SwapRequest {
  id: Uuid
  type: "swap" | "handover"
  status: "pending" | "accepted" | "declined" | "cancelled"
  requester: UserReference
  recipient: UserReference | null
  offered: ParticipationReference
  requested: ParticipationReference | null
  message: string | null
  cancellation_reason: "requester" | "task_completed" | "task_deleted" | "member_left" | null
  created_at: Timestamp
  resolved_at: Timestamp | null
  resolved_by: UserReference | null
}

ParticipationReference {
  task_id: Uuid
  participation_id: Uuid
  title: string
  due_date: LocalDate
  assignee: UserReference | null
}
```

`recipient` es null en un `handover` abierto a cualquier integrante.

### Notificaciones

```ts
NotificationType = "task_reminder" | "task_due" | "routine_without_candidate" | "swap_request"
                 | "swap_resolved" | "suggestion_pending" | "suggestion_resolved" | "member_joined"

Notification {
  id: Uuid
  type: NotificationType
  household_id: Uuid
  title: string
  body: string
  data: object
  read_at: Timestamp | null
  created_at: Timestamp
}
```

`title` y `body` van en español, listos para mostrar. `data` lleva los ids para navegar, por ejemplo `{ "task_id" }` o `{ "swap_request_id" }`.

### Panel y carga

```ts
LoadFigures {
  task_count: integer
  occurrence_count: integer
  duration_minutes: integer
  effort_points: integer
  mental_load_points: integer
  load_index: number | null
}

Dashboard {
  household: HouseholdSummary
  week: DateRange
  my_load: { capacity_percent: Percent | null, planned: LoadFigures, completed: LoadFigures }
  overdue: Task[]
  today: Task[]
  available: Task[]
}

LoadDistribution {
  period: { granularity: "week" | "month", range: DateRange }
  previous_period: { granularity: "week" | "month", range: DateRange }
  formula_version: string | null
  capacity_status: "configured" | "not_configured"
  imbalance_threshold_percent: integer | null
  members: MemberLoad[]
  totals: { planned: LoadFigures, completed: LoadFigures }
}

MemberLoad {
  member: UserReference
  capacity_percent: Percent | null
  planned: LoadFigures
  completed: LoadFigures
  previous_planned: LoadFigures
  previous_completed: LoadFigures
  planned_share_percent: number | null
  completed_share_percent: number | null
  deviation_points: number | null
  is_imbalanced: boolean | null
}

MemberLoadBreakdown {
  member: UserReference
  kind: "planned" | "completed"
  range: DateRange
  items: {
    task_id: Uuid
    title: string
    category_name: string
    date: LocalDate
    duration_minutes: number
    effort: Scale1To5
    mental_load: Scale1To5
    load_share: number
    priority: Priority
  }[]
}

DateRange {
  start: LocalDate
  end: LocalDate
}
```

En `LoadFigures`, `duration_minutes` ya considera la división de las tareas compartidas, y `effort_points` y `mental_load_points` son la suma de cada factor por ocurrencia, también ponderada por `load_share`. `load_index` es null hasta que se apruebe la fórmula de RF13.

En `MemberLoad`:

- `capacity_percent` sale del reparto vigente en ese periodo.
- `planned_share_percent` y `completed_share_percent` son el porcentaje del total del hogar; son null sin fórmula aprobada.
- `deviation_points` es `planned_share_percent − capacity_percent`.
- `is_imbalanced` es `|deviation_points| > umbral`.

En `MemberLoadBreakdown`, `duration_minutes` es la duración real o estimada según `kind`, y `priority` solo indica urgencia: no pondera.

### Sugerencias

```ts
Suggestion {
  id: Uuid
  status: "pending_agreement" | "pending_approval" | "approved" | "rejected" | "dismissed" | "obsolete"
  justification: {
    summary: string
    factors: { code: string, description: string, member: UserReference | null, value: number | null }[]
  }
  changes: {
    task_id: Uuid
    participation_id: Uuid
    title: string
    due_date: LocalDate
    from: UserReference
    to: UserReference
  }[]
  agreements: { member: UserReference, decision: "pending" | "accepted" | "declined", decided_at: Timestamp | null }[]
  created_at: Timestamp
  resolved_at: Timestamp | null
  resolved_by: UserReference | null
}
```

`justification.summary` es un texto en español listo para mostrar, por ejemplo «Ana supera su capacidad en 18 puntos esta semana». Los `code` de `factors` son estables: `over_capacity`, `under_capacity`, `availability_match`, `preference_match`, `recent_history`, `accumulated_load`.

### Estadísticas

```ts
Statistics {
  range: DateRange
  members: MemberStatistics[]
  totals: {
    completed_count: integer
    overdue_count: integer
    reassigned_count: integer
    unplanned_count: integer
    planned: LoadFigures
    completed: LoadFigures
  }
  series: { range: DateRange, members: MemberStatistics[] }[]
}

MemberStatistics {
  member: UserReference
  completed_count: integer
  overdue_count: integer
  reassigned_count: integer
  unplanned_count: integer
  planned: LoadFigures
  completed: LoadFigures
  capacity_percent: Percent | null
}
```

En `MemberStatistics`, `overdue_count` cuenta las participaciones que vencieron sin completarse dentro del rango, y `capacity_percent` sale del reparto vigente al inicio del rango.

---

## 13. Mapa de pantallas

### N1 · Registro e inicio de sesión

| Pantalla | Acción | Endpoint |
| --- | --- | --- |
| S1 Bienvenida | Crear cuenta / Ya tengo una cuenta | — |
| S2 Número | Enviar código | `POST /auth/phone-verifications` (`registration`) |
| S3 Verificar número | Verificar / reenviar | `POST /auth/phone-verifications/{id}/confirm` · `/resend` |
| S4 Contraseña | Continuar | Validación local |
| S5 Nombre | Continuar | Validación local |
| S6 Personaje / S7 Personaje elegido | Crear mi cuenta / Hacerlo más tarde | `POST /auth/register` |
| S8 Cuenta creada | Empezar | Navega a A2 |
| S9 Iniciar sesión / S10 Error | Entrar | `POST /auth/login` |
| S11 Recuperar contraseña | Enviar código | `POST /auth/phone-verifications` (`password_reset`) |
| S12 Código SMS | Continuar | `POST /auth/phone-verifications/{id}/confirm` |
| S13 Nueva contraseña | Guardar y entrar | `POST /auth/password-reset` |

### N2 · Creación del hogar

| Pantalla | Acción | Endpoint |
| --- | --- | --- |
| A2 Crear o unirse | — | — |
| A3 Crear hogar | Continuar | `POST /households` |
| A4 Invitar integrantes | Mostrar código, copiar, compartir, menú de integrante | `GET /households/{id}`, `GET /households/{id}/invitation`, `POST .../invitation/regenerate`, `PATCH`/`DELETE .../members/{user_id}` |
| A5 Perfil doméstico | Guardar y entrar | `PATCH .../members/me/profile`; personaje: `PATCH /users/me` |
| A6 Disponibilidad | Guardar | `PUT .../members/me/availability`; `POST`/`PUT`/`DELETE .../members/me/restrictions` |
| A7 Preferencias | Guardar preferencias | `GET /catalog/activities`; `PUT .../members/me/preferences`; «no puedo hacer» → `POST .../members/me/restrictions` (`permanent`, `activity`) |
| A9 Plantillas | Añadir N tareas / Empezar vacío | `GET /household-templates`, `GET /household-templates/{key}`, `POST .../template-application` |
| A10 Unirme con un código | Unirme al hogar | `GET /invitations/{code}`, `POST /invitations/{code}/accept` |

## 14. Decisiones sobre puntos pendientes del SRS

El SRS deja estos puntos abiertos. El contrato los fija así para poder implementar; cualquier cambio sigue el proceso de la sección siguiente.

| Tema | Decisión | Referencia |
| --- | --- | --- |
| Mecanismo de identidad | Teléfono + contraseña, verificación por SMS con Twilio, JWT con refresh rotativo. | RNF03, RNF04, S1–S13 |
| Vigencia del código de invitación | 7 días, regenerable; regenerar revoca el anterior. Código de 8 caracteres. | RF01, A2, A4 |
| Perfil al unirse a otro hogar | Empieza vacío; el texto de A2/A10 que dice que «viaja contigo» debe ajustarse. | RF02, SRS 4.9.2 |
| Restricciones | Sobre categorías o actividades del catálogo, sin texto libre. Los textos de ejemplo de A6 deben ajustarse. | RF10 |
| Campo «Algo que el hogar deba saber» de A5 | No se incluye: el SRS no aprueba texto libre de salud o restricciones. | RF02, RF10, SRS 4.9.2 |
| Escalas de esfuerzo y carga mental | Enteros de 1 a 5. | RF03, RF13 |
| Fórmula del índice de carga | Pendiente: `load_index` y los porcentajes derivados son null hasta aprobarla. | RF13 |
| Periodo base de capacidad | La semana del hogar; un reparto aprobado rige desde el lunes siguiente. | RF18 |
| Rechazo y cancelación de intercambios | Permitidos (`decline`, `cancel`). | RF11 |
| Fotos en comentarios | JPEG, PNG o WebP; hasta 4 fotos de 5 MB; sin EXIF. | RF15 |
| Coincidencias de imprevistos | Misma categoría o actividad, ±1 día; se puede continuar tras el aviso. | RF12 |
| Tareas disponibles en el panel | Hasta 20, con vencimiento en los próximos 7 días o atrasadas. | RF09 |
| Horizonte de rutinas | Ocurrencias generadas con 28 días de anticipación. | RF04 |

## Cambios al contrato

1. Quien necesite un cambio abre un pull request que modifique este documento (rama `docs/<descripcion>`), explicando el motivo.
2. Los cambios compatibles (endpoints o campos nuevos opcionales, códigos de error nuevos) se aprueban con la revisión de quien implementa el frontend y el backend del módulo afectado.
3. Los cambios incompatibles (renombrar o quitar campos, cambiar tipos o semántica) requieren el acuerdo del equipo y, una vez publicada la API, una versión nueva (`/api/v2`).
4. El backend y el frontend se actualizan en pull requests que referencian el cambio del contrato.
