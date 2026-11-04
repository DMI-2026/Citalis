# clientes-service

## Responsabilidad

Directorio de clientes por negocio, historial de citas y valoraciones.

## Dominio

- **Módulo / requerimientos:** Módulo 4 (Req 4.1–4.3) de [`docs/historias-de-usuario.md`](../../../docs/historias-de-usuario.md).
- **Schema PostgreSQL:** `clientes` · **Tablas propias:** client_business_links, ratings.
- **Puerto:** 3004 · **Prefijo de rutas en el gateway:** `/clients`.

## API / Contrato

- `GET /health` — liveness + ping a la BD (público).
- `GET /clients/test` — prueba de BD y de respuesta del servicio (público en desarrollo).
- Swagger (solo desarrollo): http://localhost:3004/docs
- Los endpoints de negocio se documentan con `@ApiTags`/`@ApiResponse` y aparecen en Swagger.

## Variables de entorno

Se leen del único `.env` de la raíz de `apps/api/` (ver `.env.example`).

| Variable | Descripción | Default |
|---|---|---|
| `DATABASE_URL` | Cadena de conexión PostgreSQL (la misma para todos los servicios) | — |
| `INTERNAL_API_TOKEN` | Secreto de rutas `/internal/*` y del gateway (≥ 32 caracteres en producción) | — |
| `PORT` | Puerto HTTP del servicio | 3004 |
| `ENABLE_TEST_ENDPOINTS` | Habilita `GET /clients/test` | true en desarrollo |

## Cómo levantar en local

```bash
# desde apps/api/ (una sola vez: pnpm install, cp .env.example .env, pnpm db:generate, pnpm db:migrate)
pnpm --filter @backend/clientes-service start:dev
curl http://localhost:3004/clients/test
```

## Tests

```bash
pnpm --filter @backend/clientes-service test
```

## Dependencias de otros servicios

- agenda-service (reservas completadas e historial)
- negocios-service (validar propietario)
- auth-service (datos de contacto del cliente)
