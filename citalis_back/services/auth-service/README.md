# auth-service

## Responsabilidad

Identidad de usuarios sobre Firebase Auth: registro en Citalis, perfil y consulta interna para el gateway.

## Dominio

- **Módulo / requerimientos:** Módulo 1 (Req 1.1–1.4) y Req 7.1 de [`docs/historias-de-usuario.md`](../../../docs/historias-de-usuario.md).
- **Schema PostgreSQL:** `auth` · **Tablas propias:** users, audit_log.
- **Puerto:** 3001 · **Prefijo de rutas en el gateway:** `/auth`.

## API / Contrato

- `GET /health` — liveness + ping a la BD (público).
- `GET /auth/test` — prueba de BD y de respuesta del servicio (público en desarrollo).
- Swagger (solo desarrollo): http://localhost:3001/docs
- Los endpoints de negocio se documentan con `@ApiTags`/`@ApiResponse` y aparecen en Swagger.

## Variables de entorno

Se leen del único `.env` de la raíz de `citalis_back/` (ver `.env.example`).

| Variable | Descripción | Default |
|---|---|---|
| `DATABASE_URL` | Cadena de conexión PostgreSQL (la misma para todos los servicios) | — |
| `INTERNAL_API_TOKEN` | Secreto de rutas `/internal/*` y del gateway (≥ 32 caracteres en producción) | — |
| `PORT` | Puerto HTTP del servicio | 3001 |
| `ENABLE_TEST_ENDPOINTS` | Habilita `GET /auth/test` | true en desarrollo |

## Cómo levantar en local

```bash
# desde citalis_back/ (una sola vez: pnpm install, cp .env.example .env, pnpm db:generate, pnpm db:migrate)
pnpm --filter @backend/auth-service start:dev
curl http://localhost:3001/auth/test
```

## Tests

```bash
pnpm --filter @backend/auth-service test
```

## Dependencias de otros servicios

- Ninguno (es la fuente de identidad: lo consultan el gateway y los demás servicios)
