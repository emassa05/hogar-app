# AGENTS.md

Guía de prácticas para cualquier persona o agente que trabaje en este repositorio.

## Proyecto

`hogar-app` es una aplicación para organizar y equilibrar la carga doméstica entre los integrantes de un hogar. Los requerimientos están en [`docs/requerimientos/funcionales.md`](docs/requerimientos/funcionales.md).

## Estructura

Monorepo con todo el proyecto:

```
backend/    Código del servidor
frontend/   Código del cliente
docs/       Documentación del proyecto (en español)
```

El stack aún no está definido. Las carpetas vacías se mantienen con `.gitkeep`; elimínalo cuando la carpeta tenga contenido real.

## Idioma

| Ámbito | Idioma |
| --- | --- |
| Código: identificadores, comentarios, nombres de archivos y carpetas de código | Inglés |
| Ramas y mensajes de commit | Inglés |
| Documentación (`docs/`), `README.md`, `AGENTS.md` | Español |

## Código

- Sigue las convenciones idiomáticas del lenguaje y framework de cada carpeta.
- Nombres de archivos en `kebab-case`, salvo que el lenguaje o framework exija otra convención (por ejemplo, componentes en `PascalCase`).
- Nombres descriptivos y concisos; evita abreviaturas poco claras.

## Documentación

- Toda la documentación vive en `docs/`, agrupada por tema en subcarpetas (`docs/requerimientos/`, `docs/arquitectura/`, etc.).
- Nombres de archivos en español, `kebab-case`, en minúsculas, sin tildes ni `ñ`.
- Nombres cortos: la carpeta aporta el contexto, el archivo no lo repite. Ejemplo: `docs/requerimientos/funcionales.md`, no `docs/requerimientos/requerimientos-funcionales.md`.
- Sin versiones, fechas ni estados en el nombre (`-v2`, `-final`, `-actualizado`); el historial lo lleva git.
- El título (`#`) del documento debe coincidir con su propósito, no con su versión.

## Ramas

Formato `<type>/<short-description>` en inglés y `kebab-case`:

- `feat/household-management`
- `fix/task-reminder-timezone`
- `docs/non-functional-requirements`
- `chore/setup-ci`

`main` es la rama principal; no se trabaja directamente sobre ella.

## Commits

Se sigue [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<optional scope>): <description>
```

- Tipos: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`, `style`, `perf`, `build`, `ci`.
- Scope opcional según el área: `backend`, `frontend`, `docs`.
- Descripción en inglés, en imperativo, minúscula, sin punto final y concisa (idealmente menos de 72 caracteres).
- Sin `Co-authored-by` ni otras líneas de atribución.
- Agrupa los cambios relacionados en un commit coherente: ni un commit por cada archivo tocado, ni todo el trabajo en un único commit. Cada commit debe representar una unidad lógica de cambio.

Ejemplos:

```
feat(backend): add household invitation endpoint
fix(frontend): show overdue tasks on dashboard
docs: add functional requirements
chore: scaffold monorepo structure
```
