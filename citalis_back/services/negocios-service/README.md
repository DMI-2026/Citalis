# negocios-service

## Responsabilidad

Perfil del negocio, catálogo de servicios, imágenes, código QR/deep link y catálogos (categorías y municipios).

## Dominio

- **Módulo / requerimientos:** Módulo 2 (Req 2.1–2.5) de [`docs/historias-de-usuario.md`](../../../docs/historias-de-usuario.md).
- **Schema PostgreSQL:** `negocios` · **Tablas propias:** businesses, business_images, services, business_categories, municipalities.
- **Puerto:** 3002 · **Prefijo de rutas en el gateway:** `/businesses`.

## API / Contrato

- `GET /health` — liveness + ping a la BD (público).
- `GET /businesses/test` — prueba de BD y de respuesta del servicio (público en desarrollo).
- Swagger (solo desarrollo): http://localhost:3002/docs
- Los endpoints de negocio se documentan con `@ApiTags`/`@ApiResponse` y aparecen en Swagger.

## Variables de entorno

Se leen del único `.env` de la raíz de `citalis_back/` (ver `.env.example`).

| Variable | Descripción | Default |
|---|---|---|
| `DATABASE_URL` | Cadena de conexión PostgreSQL (la misma para todos los servicios) | — |
| `INTERNAL_API_TOKEN` | Secreto de rutas `/internal/*` y del gateway (≥ 32 caracteres en producción) | — |
| `PORT` | Puerto HTTP del servicio | 3002 |
| `ENABLE_TEST_ENDPOINTS` | Habilita `GET /businesses/test` | true en desarrollo |

## Cómo levantar en local

```bash
# desde citalis_back/ (una sola vez: pnpm install, cp .env.example .env, pnpm db:generate, pnpm db:migrate)
pnpm --filter @backend/negocios-service start:dev
curl http://localhost:3002/businesses/test
```

## Tests

```bash
pnpm --filter @backend/negocios-service test
```

## Dependencias de otros servicios

- auth-service (datos del propietario, si se requieren)
