# notificaciones-service

## Responsabilidad

Preferencias de notificación, tokens FCM por dispositivo y envío de recordatorios de citas.

## Dominio

- **Módulo / requerimientos:** Módulo 6 (Req 6.1) y Req 7.3 de [`docs/historias-de-usuario.md`](../../../docs/historias-de-usuario.md).
- **Schema PostgreSQL:** `notificaciones` · **Tablas propias:** notification_preferences, notification_tokens.
- **Puerto:** 3006 · **Prefijo de rutas en el gateway:** `/notifications`.

## API / Contrato

- `GET /health` — liveness + ping a la BD (público).
- `GET /notifications/test` — prueba de BD y de respuesta del servicio (público en desarrollo).
- Swagger (solo desarrollo): http://localhost:3006/docs
- Los endpoints de negocio se documentan con `@ApiTags`/`@ApiResponse` y aparecen en Swagger.

## Variables de entorno

Se leen del único `.env` de la raíz de `apps/api/` (ver `.env.example`).

| Variable | Descripción | Default |
|---|---|---|
| `DATABASE_URL` | Cadena de conexión PostgreSQL (la misma para todos los servicios) | — |
| `INTERNAL_API_TOKEN` | Secreto de rutas `/internal/*` y del gateway (≥ 32 caracteres en producción) | — |
| `PORT` | Puerto HTTP del servicio | 3006 |
| `ENABLE_TEST_ENDPOINTS` | Habilita `GET /notifications/test` | true en desarrollo |
| `FIREBASE_CLIENT_EMAIL / FIREBASE_PRIVATE_KEY` | Cuenta de servicio de Firebase para enviar push (solo en .env) | — |

## Cómo levantar en local

```bash
# desde apps/api/ (una sola vez: pnpm install, cp .env.example .env, pnpm db:generate, pnpm db:migrate)
pnpm --filter @backend/notificaciones-service start:dev
curl http://localhost:3006/notifications/test
```

## Tests

```bash
pnpm --filter @backend/notificaciones-service test
```

## Dependencias de otros servicios

- agenda-service (reservas próximas a recordar)
- auth-service (datos del usuario)
- Firebase Cloud Messaging (envío push)
