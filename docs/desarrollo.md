# Guía de desarrollo

Cómo preparar el entorno, ejecutar el proyecto y contribuir a `hogar-app`. Las reglas generales de código, documentación, ramas y commits están en [`AGENTS.md`](../AGENTS.md); esta guía las resume y agrega los comandos concretos.

## Requisitos

| Herramienta | Versión | Uso |
| --- | --- | --- |
| [Docker](https://docs.docker.com/get-docker/) con Docker Compose | Reciente | PostgreSQL y Redis locales |
| [uv](https://docs.astral.sh/uv/) | Reciente | Dependencias y entorno de Python |
| Python | 3.13 | Backend (uv puede instalarlo con `uv python install 3.13`) |
| [Flutter](https://docs.flutter.dev/get-started/install) | 3.32.x (estable) | Aplicación móvil |
| Android SDK | API 33 o superior | Emulador o dispositivo para ejecutar la app |
| JDK | 17 | Compilación de Android |

Verifica la instalación con `docker compose version`, `uv --version`, `flutter --version` y `flutter doctor`.

## Estructura del monorepo

```
hogar-app/
├── backend/                API REST (FastAPI, SQLAlchemy, Alembic)
│   ├── app/
│   │   ├── common/         Configuración, base de datos, errores, seguridad
│   │   ├── modules/        Un paquete por módulo funcional (auth, users, households, ...)
│   │   ├── api.py          Registro de routers
│   │   ├── main.py         Fábrica de la aplicación (create_app)
│   │   └── models.py       Reúne los modelos para Alembic
│   ├── migrations/         Migraciones de Alembic
│   ├── tests/
│   ├── compose.yaml        PostgreSQL, Redis y la API para desarrollo
│   └── Dockerfile
├── frontend/               Aplicación Android (Flutter)
│   ├── lib/
│   │   ├── core/           Configuración, red, sesión, tema, widgets compartidos
│   │   └── features/       Una carpeta por funcionalidad
│   ├── test/
│   └── tool/generate.dart  Generación de código
├── docs/                   Documentación del proyecto
└── .github/                Workflows de CI, Dependabot y plantilla de PR
```

## Backend

Todos los comandos se ejecutan dentro de `backend/`.

### Puesta en marcha

```bash
cd backend
cp .env.example .env
docker compose up -d postgres redis
uv sync
uv run alembic upgrade head
uv run uvicorn app.main:create_app --factory --reload
```

- `.env.example` trae valores válidos para desarrollo. `JWT_SECRET` debe tener al menos 32 caracteres; con `SMS_PROVIDER=console` los códigos de verificación se imprimen en el log en vez de enviarse por SMS.
- `docker compose up -d postgres redis` levanta PostgreSQL 17 en `localhost:5432` (usuario, contraseña y base `hogar`) y Redis en `localhost:6379`. Al crear el volumen por primera vez también se crea la base `hogar_test` para los tests.
- La API queda en <http://localhost:8000>, con la documentación interactiva (Swagger UI) en <http://localhost:8000/docs> y el esquema OpenAPI en <http://localhost:8000/api/v1/openapi.json>.
- Para levantar también la API en un contenedor: `docker compose --profile full up -d --build`.

### Tests

```bash
uv run pytest
uv run pytest --cov --cov-report=term-missing
```

Los tests usan la base `hogar_test` (configurable con `TEST_DATABASE_URL`); crean y borran el esquema en cada ejecución, así que nunca apuntes `TEST_DATABASE_URL` a la base de desarrollo.

### Calidad de código

```bash
uv run ruff format .
uv run ruff check --fix .
uv run mypy app tests
```

CI ejecuta `ruff format --check`, `ruff check` y `mypy` en modo estricto; corre los tres antes de abrir un PR.

### Migraciones

Las migraciones se generan a partir de los modelos de SQLAlchemy:

1. Crea o modifica el modelo en `app/modules/<módulo>/models.py`.
2. Si es un modelo nuevo, impórtalo en `app/models.py` para que Alembic lo detecte.
3. Con la base actualizada (`uv run alembic upgrade head`), genera la migración:

   ```bash
   uv run alembic revision --autogenerate -m "create tasks table"
   ```

4. Revisa el archivo generado en `migrations/versions/`: el autogenerate no detecta todo (por ejemplo, renombres de columnas o cambios en tipos `Enum`).
5. Aplícala con `uv run alembic upgrade head` y comprueba que no queden diferencias con `uv run alembic check`.

Para revertir la última migración: `uv run alembic downgrade -1`.

## Frontend

Todos los comandos se ejecutan dentro de `frontend/`.

### Puesta en marcha

```bash
cd frontend
flutter pub get
dart run tool/generate.dart
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```

- `dart run tool/generate.dart` ejecuta `dart run build_runner build --delete-conflicting-outputs` (Riverpod, Freezed y `json_serializable`) y luego quita los comentarios de los archivos generados. Vuelve a ejecutarlo cada vez que cambies una clase anotada. Los archivos `*.g.dart` y `*.freezed.dart` se versionan.
- `10.0.2.2` es la dirección con la que el emulador de Android llega al `localhost` del computador. En un dispositivo físico usa la IP del computador en la red local (y levanta uvicorn con `--host 0.0.0.0`).
- Si no se pasa `API_BASE_URL`, la app usa `http://10.0.2.2:8000/api/v1`.

### Tests y calidad de código

```bash
dart format lib test
flutter analyze --fatal-infos
flutter test
flutter test --coverage
```

## Contrato de API

El contrato entre la app y el backend está en [`docs/contrato-api.md`](contrato-api.md) y es la fuente de verdad para ambos lados. Si un cambio afecta endpoints, modelos o errores, actualiza el contrato en el mismo PR.

## Flujo de ramas

```
main  ←  dev  ←  feat/…, fix/…, docs/…, chore/…, ci/…
```

- `main` contiene versiones estables; solo recibe merges desde `dev`.
- `dev` es la rama de integración. Nadie trabaja directamente sobre `main` ni `dev`.
- Cada cambio se hace en una rama corta creada desde `dev`, con formato `<tipo>/<descripcion-corta>` en inglés y `kebab-case` (`feat/household-management`, `fix/task-reminder-timezone`).
- Los PR apuntan a `dev`, usan la plantilla de PR y deben pasar CI antes del merge.
- Los PR se integran con **merge commit** (nunca squash ni rebase) y la rama se borra después del merge.

```bash
git switch dev
git pull
git switch -c feat/task-reminders
```

## Commits

Se sigue [Conventional Commits](https://www.conventionalcommits.org/): `<tipo>(<scope opcional>): <descripción>`.

- Tipos: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `style`, `perf`, `build`, `ci`.
- Scope opcional: `backend`, `frontend`, `docs`.
- Descripción en inglés, en imperativo, en minúscula, sin punto final y de menos de 72 caracteres.
- Cada commit es una unidad lógica de cambio.

```
feat(backend): add household invitation endpoint
fix(frontend): show overdue tasks on dashboard
```

## Integración continua

Los workflows de GitHub Actions están en `.github/workflows/` y se ejecutan en cada PR y en cada push a `dev` y `main`, solo cuando cambian archivos de su carpeta.

| Workflow | Jobs | Pasos |
| --- | --- | --- |
| `backend.yml` | Lint, type check and test | `uv sync --frozen`, `ruff format --check`, `ruff check`, `mypy`, `alembic upgrade head`, `alembic check` y `pytest` con cobertura sobre PostgreSQL 17 |
| | Build Docker image | `docker build` de `backend/` |
| `frontend.yml` | Format, analyze and test | `flutter pub get`, `dart format --set-exit-if-changed`, `flutter analyze --fatal-infos`, `flutter test --coverage` |
| | Build debug APK | `flutter build apk --debug` |

`alembic check` falla si los modelos tienen cambios sin su migración: genera la migración antes de hacer push.

Dependabot (`.github/dependabot.yml`) abre cada semana PRs hacia `dev` para actualizar las acciones de GitHub y las dependencias de `uv` y `pub`.
