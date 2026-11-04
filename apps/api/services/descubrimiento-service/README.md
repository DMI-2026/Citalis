# descubrimiento-service

## Responsabilidad

Búsqueda de negocios, cercanía/geolocalización, API de terceros de geocodificación y favoritos.

## Dominio

- **Módulo / requerimientos:** Módulo 5 (Req 5.1–5.3) de [`docs/historias-de-usuario.md`](../../../docs/historias-de-usuario.md).
- **Schema PostgreSQL:** `descubrimiento` · **Tablas propias:** favorites.
- **Puerto:** 3005 · **Prefijo de rutas en el gateway:** `/discover`.

## API / Contrato

- `GET /health` — liveness + ping a la BD (público).
- `GET /discover/test` — prueba de BD y de respuesta del servicio (público en desarrollo).
- Swagger (solo desarrollo): http://localhost:3005/docs
- Los endpoints de negocio se documentan con `@ApiTags`/`@ApiResponse` y aparecen en Swagger.

## Variables de entorno

Se leen del único `.env` de la raíz de `apps/api/` (ver `.env.example`).

| Variable | Descripción | Default |
|---|---|---|
| `DATABASE_URL` | Cadena de conexión PostgreSQL (la misma para todos los servicios) | — |
| `INTERNAL_API_TOKEN` | Secreto de rutas `/internal/*` y del gateway (≥ 32 caracteres en producción) | — |
| `PORT` | Puerto HTTP del servicio | 3005 |
| `ENABLE_TEST_ENDPOINTS` | Habilita `GET /discover/test` | true en desarrollo |
| `GEOCODING_BASE_URL` | URL base de la API de geocodificación (cuando el equipo la defina) | — |
| `GEOCODING_API_KEY` | Credencial de la API de terceros (solo en .env, nunca en el repo) | — |

## Cómo levantar en local

```bash
# desde apps/api/ (una sola vez: pnpm install, cp .env.example .env, pnpm db:generate, pnpm db:migrate)
pnpm --filter @backend/descubrimiento-service start:dev
curl http://localhost:3005/discover/test
```

## Tests

```bash
pnpm --filter @backend/descubrimiento-service test
```

## Dependencias de otros servicios

- negocios-service (fuente de los negocios a buscar y ordenar)
- API de terceros de geocodificación (por definir por el equipo, ver guía de trabajo)
