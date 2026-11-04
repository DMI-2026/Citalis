# Instrucciones para agentes de IA — Citalis

Monorepo del proyecto integrador **Citalis** (UTEZ, DMI-2026): `apps/mobile/` (Flutter), `apps/api/` (NestJS + Prisma + PostgreSQL + Firebase Auth) y `docs/`.

## Backend (`apps/api/`)

**Antes de crear o modificar cualquier archivo del backend, lee completa [`docs/backend/guia-de-trabajo.md`](docs/backend/guia-de-trabajo.md) y síguela.** Es normativa para todo el equipo; no propongas otra estructura. Resumen de lo esencial:

- 6 microservicios + gateway; **un servicio = un schema de PostgreSQL**; nunca leas tablas de otro servicio ni crees FKs entre schemas (se usa HTTP `/internal/*`).
- Capas por dominio: `presentation → application → domain ← infrastructure`; Prisma solo en `infrastructure/persistence`. Copia el patrón de `services/auth-service/src/modules/users/`.
- Reutiliza `commons/` (`@backend/contracts|security|utils|firebase|observability`); no dupliques utilidades ni DTOs de contrato.
- El `userId` sale **siempre** de `@CurrentUser()`; la autorización por propietario va en el caso de uso y con pruebas.
- Errores con `code` estable; DTOs con `class-validator`; APIs de terceros solo con `ResilientHttpClient`.
- Migraciones con `pnpm prisma:dev` dentro del servicio; nunca edites una migración ya integrada, nunca `db push`/`migrate reset` en bases compartidas.
- Antes de dar algo por terminado: `pnpm lint && pnpm test && pnpm build` (desde `apps/api/`).

## Siempre (todo el repo)

- **Cero secretos en el repositorio** (`.env`, JSON de Firebase, claves de API, keystores). Nunca pegues credenciales ni datos personales reales en un prompt.
- El proyecto se evalúa con una rúbrica ([guía §12](docs/backend/guia-de-trabajo.md#12-cumplimiento-de-la-rúbrica-del-proyecto-integrador)); no rompas ninguno de sus puntos (F1–F7, S1–S8, P1–P3).
- Uso de IA **Nivel 4**: registra la sesión en [`docs/ia/bitacora.md`](docs/ia/bitacora.md). La persona debe poder explicar y modificar en vivo todo el código que entregue.
- Commits en español, imperativo, con prefijo (`feat(agenda): …`); un PR por tarea con al menos 1 aprobación.
- Si una petición contradice la guía, avisa a la persona y propón actualizar la guía en lugar de improvisar.
