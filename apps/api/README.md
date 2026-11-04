# apps/api · Backend de Citalis

Backend de **Citalis** como monorepo **pnpm + Turborepo** de microservicios **NestJS 10** con **Prisma 5** sobre **PostgreSQL**, detrás de un **API Gateway**. El control de acceso se delega en **Firebase Authentication**. La estructura replica la de `RH-Nomina/apps/nomina-backend`.

> **¿Vas a escribir código aquí (tú o tu IA)?** Primero lee la [guía de trabajo](../docs/backend/guia-de-trabajo.md): define qué va en cada carpeta, qué ofrece `commons/` y el flujo para agregar funcionalidades. Todos seguimos la misma estructura.

---

## Arquitectura

```
                    App Flutter (iOS / Android / Web)
                                 │  HTTPS · Authorization: Bearer <token ID de Firebase>
                                 ▼
┌──────────────────────────── gateway :3000 ────────────────────────────┐
│ helmet · CORS · rate limit · verifica token Firebase (firebase-admin)  │
│ resuelve usuario interno · inyecta x-user-id / x-internal-token        │
└───┬───────────┬───────────┬───────────┬───────────────┬───────────┬────┘
    ▼           ▼           ▼           ▼               ▼           ▼
 auth-       negocios-    agenda-    clientes-    descubrimiento-  notificaciones-
 service     service      service    service      service          service
 :3001       :3002        :3003      :3004        :3005            :3006
    │           │           │           │               │           │
    └───────────┴───────────┴─────┬─────┴───────────────┴───────────┘
                                  ▼
                 PostgreSQL · UNA base, UN schema por servicio
          auth · negocios · agenda · clientes · descubrimiento · notificaciones
```

| Servicio | Puerto | Módulo (historias de usuario) | Schema | Tablas propias | Prefijo en el gateway |
|---|---|---|---|---|---|
| `gateway` | 3000 | — (auth, proxy, límites) | — | — | — |
| `auth-service` | 3001 | 1 Cuenta y seguridad · 7.1 Perfil | `auth` | `users`, `audit_log` | `/auth`, `/users` |
| `negocios-service` | 3002 | 2 Negocio y servicios | `negocios` | `businesses`, `business_images`, `services`, `business_categories`, `municipalities` | `/businesses`, `/catalogs` |
| `agenda-service` | 3003 | 3 Agenda y reservas | `agenda` | `business_hours`, `business_hour_exceptions`, `reservations` | `/reservations`, `/availability`, `/schedule` |
| `clientes-service` | 3004 | 4 Clientes y seguimiento | `clientes` | `client_business_links`, `ratings` | `/clients`, `/ratings` |
| `descubrimiento-service` | 3005 | 5 Ubicación y descubrimiento | `descubrimiento` | `favorites` | `/discover`, `/favorites` |
| `notificaciones-service` | 3006 | 6 Notificaciones · 7.3 Permisos | `notificaciones` | `notification_preferences`, `notification_tokens` | `/notifications` |

Reglas de oro: **un servicio es dueño de su schema** y nadie lee tablas ajenas (se pide por HTTP `/internal/*`); las referencias entre servicios son UUID **sin llave foránea física**; el gateway **no tiene lógica de negocio**. El detalle está en la guía de trabajo.

El modelo de datos lógico está en [`docs/db/modelo-datos.md`](../docs/db/modelo-datos.md) y [`docs/db/schema.sql`](../docs/db/schema.sql); aquí se materializa repartido por servicio (`services/*/prisma/schema.prisma`).

---

## Requisitos

| Herramienta | Versión | Para qué |
|---|---|---|
| Node.js | 20.12 o superior de la serie 20 (`.nvmrc`) | runtime |
| pnpm | 8.15.0 (`corepack enable`) | gestor del workspace |
| Docker Desktop | reciente | Postgres local (`pnpm db:up`) y stack completo |
| Proyecto de Firebase | — | Authentication (ver [Firebase](#firebase-control-de-acceso)) |

---

## Puesta en marcha (desarrollo)

Todos los comandos se ejecutan **desde `apps/api/`**.

```bash
# 1. Dependencias (necesitas pnpm 8.15.0; compruébalo con `pnpm -v`)
#    Si no lo tienes: `corepack enable` (en Windows, PowerShell como administrador)
#    o bien `npm install -g pnpm@8.15.0`.
pnpm install

# 2. Variables de entorno (UN solo .env para gateway, servicios y Prisma)
cp .env.example .env          # en PowerShell: Copy-Item .env.example .env
#    → completa FIREBASE_PROJECT_ID y revisa DATABASE_URL (ver más abajo)

# 3. Base de datos: opción A, Postgres local en Docker (puerto 5433)
pnpm db:up
#    Opción B: apunta DATABASE_URL a tu Postgres/Supabase/Neon y omite este paso.

# 4. Cliente Prisma + migraciones (crea los 6 schemas y sus tablas)
pnpm db:generate
pnpm db:migrate

# 5. Levantar gateway + 6 servicios (compila commons/ la primera vez)
pnpm dev

# 6. Validar que todo responde y que cada servicio ve su schema
pnpm smoke
```

Salida esperada de `pnpm smoke`:

```
✔ gateway /health                              228 ms  ok (6/6 servicios up)
✔ auth-service /auth/test                       39 ms  HTTP 200 · schema auth · users=0 audit_log=0
✔ negocios-service /businesses/test             29 ms  HTTP 200 · schema negocios · businesses=0 services=0 business_categories=8
✔ agenda-service /reservations/test             32 ms  HTTP 200 · schema agenda · reservations=0 ...
✔ clientes-service /clients/test                30 ms  HTTP 200 · schema clientes · ...
✔ descubrimiento-service /discover/test         37 ms  HTTP 200 · schema descubrimiento · favorites=0
✔ notificaciones-service /notifications/test    34 ms  HTTP 200 · schema notificaciones · ...
Todo operativo.
```

### Conexión a la base de datos

`DATABASE_URL` es **una sola cadena** para todos los servicios; cada uno trabaja en su schema.

| Escenario | `DATABASE_URL` |
|---|---|
| Docker local (`pnpm db:up`) | `postgresql://citalis:citalis_dev@localhost:5433/citalis` (valor por defecto de `.env.example`) |
| Supabase / Neon | La cadena **directa** (no la del *pooler*) con `?sslmode=require`; la necesitan las migraciones |
| Postgres instalado en tu PC | `postgresql://USUARIO:PASSWORD@localhost:5432/citalis` (crea antes la base: `createdb citalis`) |

Si la contraseña tiene caracteres especiales (`@`, `/`, `#`…), codifícalos en la URL (`@` → `%40`).

El cliente necesita permiso para crear extensiones (`citext`, `pg_trgm`, `btree_gist`) y schemas; en Supabase/Neon el rol por defecto ya puede.

### Ejecutar un solo microservicio

```bash
pnpm --filter @backend/agenda-service start:dev      # en modo watch
pnpm --filter @backend/agenda-service test           # sus pruebas
curl http://localhost:3003/health                    # directo al servicio
curl http://localhost:3003/reservations/test         # prueba de BD de ese servicio
curl http://localhost:3000/reservations/test         # el mismo, a través del gateway
```

Las rutas `/health` y `/<prefijo>/test` son públicas y pasan por el gateway sin token. Cualquier otra ruta exige token de Firebase y que `auth-service` esté arriba (el gateway le pregunta quién es el usuario); levántalo junto al servicio que estés desarrollando.

Los endpoints de prueba existen en cada servicio:

| Servicio | Endpoint de prueba | Qué valida |
|---|---|---|
| auth-service | `GET /auth/test` | servicio responde · BD conectada · `auth.users`, `auth.audit_log` legibles |
| negocios-service | `GET /businesses/test` | … · `businesses`, `services`, `business_categories` (8 categorías semilla) |
| agenda-service | `GET /reservations/test` | … · `reservations`, `business_hours`, `business_hour_exceptions` |
| clientes-service | `GET /clients/test` | … · `client_business_links`, `ratings` |
| descubrimiento-service | `GET /discover/test` | … · `favorites` |
| notificaciones-service | `GET /notifications/test` | … · `notification_preferences`, `notification_tokens` |

Responden `200` con `status: "ok"`, o `503` si la BD no está disponible o falta una migración. No revelan cadenas de conexión ni mensajes técnicos. En producción se apagan con `ENABLE_TEST_ENDPOINTS=false`.

---

## Firebase (control de acceso)

La contraseña y las sesiones las gestiona **Firebase Authentication**; el backend nunca ve contraseñas.

1. La app Flutter crea la cuenta / inicia sesión con Firebase (correo + contraseña, recuperación de contraseña incluida) y obtiene un **token ID**.
2. Cada petición a la API lleva `Authorization: Bearer <token ID>`.
3. El **gateway** verifica el token con `firebase-admin`, busca al usuario en `auth-service` y reenvía la identidad a los servicios en cabeceras internas (`x-user-id`, `x-firebase-uid`, `x-user-email`) junto con `x-internal-token`.
4. Tras crear la cuenta en Firebase la app llama **una vez** a `POST /auth/register` `{ name, phone? }` para crear el perfil en Citalis (idempotente: reintentar no duplica). `GET /users/me` devuelve el perfil y sirve para restaurar la sesión.

Configuración (`.env`; **nunca** subas credenciales al repo):

| Variable | Obligatoria | Descripción |
|---|---|---|
| `FIREBASE_PROJECT_ID` | Sí | ID del proyecto (Consola de Firebase → Configuración del proyecto) |
| `FIREBASE_CLIENT_EMAIL` + `FIREBASE_PRIVATE_KEY` | Solo para revocar sesiones o enviar push | Valores del JSON de la cuenta de servicio (clave en una línea con `\n`) |
| `GOOGLE_APPLICATION_CREDENTIALS` | Alternativa | Ruta, **fuera del repo**, al JSON de la cuenta de servicio |
| `FIREBASE_AUTH_EMULATOR_HOST` | Opcional | Usar el emulador de Firebase Auth en desarrollo |

Con solo `FIREBASE_PROJECT_ID` el backend ya puede **verificar** tokens.

---

## Scripts (raíz)

| Comando | Qué hace |
|---|---|
| `pnpm dev` | gateway + 6 servicios en modo watch (compila `commons/` y genera Prisma antes) |
| `pnpm build` / `pnpm start` | compila todo / arranca compilado (`start:prod`) |
| `pnpm test` | pruebas unitarias de todo el monorepo (Jest) |
| `pnpm lint` · `pnpm format` · `pnpm format:check` | ESLint · Prettier |
| `pnpm db:up` · `db:down` · `db:reset` | Postgres local en Docker: levantar · detener · borrar y recrear vacío |
| `pnpm db:generate` | genera el cliente Prisma de cada servicio |
| `pnpm db:migrate` | aplica `prisma migrate deploy` en cada servicio |
| `pnpm db:status` | estado de las migraciones de cada servicio |
| `pnpm smoke` | `GET /health` y `GET /<prefijo>/test` de todo el sistema (`GATEWAY_URL` para otro host) |

Dentro de un servicio (`pnpm --filter @backend/<servicio> …`): `start:dev`, `test`, `prisma:dev` (crear/aplicar migración en desarrollo), `prisma:migrate`, `prisma:status`, `prisma:studio`.

---

## Docker (stack completo)

```bash
cp .env.example .env     # en producción: INTERNAL_API_TOKEN ≥ 32 caracteres (openssl rand -hex 32)
docker compose build                    # 7 imágenes desde un único Dockerfile multi-stage
docker compose run --rm migrator        # aplica las migraciones (perfil "tools")
docker compose up -d                    # gateway publicado en GATEWAY_PORT (3000)
pnpm smoke                              # con ENABLE_TEST_ENDPOINTS=true en .env
```

Dentro de Docker `localhost` es el propio contenedor: si la base corre en tu máquina usa `host.docker.internal` en `DATABASE_URL`. Solo el gateway publica puerto; los servicios se ven entre sí por nombre en la red `citalis`.

---

## Estructura

```
apps/api/
├── gateway/                 # API Gateway (proxy + auth Firebase)
├── services/<servicio>/     # 6 microservicios (src/modules/<dominio>/{presentation,application,domain,infrastructure})
│   └── prisma/              # schema.prisma + migrations del servicio
├── commons/                 # paquetes compartidos @backend/*
│   ├── contracts/           # tipos, cabeceras y DTOs internos entre servicios
│   ├── security/            # guard global, @Public(), @CurrentUser(), rutas /internal
│   ├── firebase/            # verificación de tokens (firebase-admin)
│   ├── observability/       # logger JSON, interceptor de logs, enmascarado de PII
│   └── utils/               # bootstrap, filtro de errores, cliente HTTP, paginación, env
├── scripts/                 # prisma-cli.mjs (migraciones por servicio), smoke-test.mjs
├── docker/                  # run-migrations.sh
├── Dockerfile · docker-compose.yml · docker-compose.db.yml
└── .env.example             # único archivo de variables (el .env real NO se versiona)
```

---

## Solución de problemas

| Síntoma | Causa y solución |
|---|---|
| `Cannot find module '../generated/prisma'` | Falta generar el cliente: `pnpm db:generate` |
| `/<prefijo>/test` responde 503 con `connected: true` | Migraciones pendientes: `pnpm db:migrate` |
| `/<prefijo>/test` responde 503 con `connected: false` | Revisa `DATABASE_URL` y que la base esté arriba (`docker ps`); el motivo exacto está en el log del servicio |
| `ECONNREFUSED …:5432` | Tu Postgres local ocupa el 5432; usa el de Docker (5433) o ajusta `DATABASE_URL` |
| `faltan variables de entorno obligatorias` | Falta `.env` (cópialo de `.env.example`) o `FIREBASE_PROJECT_ID` en el gateway |
| `/users/me` responde 403 `USER_NOT_REGISTERED` | El usuario existe en Firebase pero no ha llamado a `POST /auth/register` |
| `EBUSY … symlink` al instalar (Windows) | Bloqueo transitorio del antivirus/sincronización: repite `pnpm install` |
| `migrate dev` pide resetear la base | No lo aceptes en una base compartida; revisa la guía (sección Base de datos) |
| `INTERNAL_API_TOKEN debe tener al menos 32 caracteres` | Estás en `NODE_ENV=production`: genera uno real con `openssl rand -hex 32` |
