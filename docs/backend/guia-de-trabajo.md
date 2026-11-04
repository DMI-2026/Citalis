# Citalis · Guía de trabajo del backend

> **Documento normativo para el equipo y para las IA que usemos** (Claude Code, Copilot, Cursor, ChatGPT…).
> Si eres una IA: **lee este archivo completo antes de generar o modificar código en `apps/api/`** y síguelo al pie de la letra. Si algo del encargo contradice esta guía, no improvises: avisa a la persona y propón actualizar la guía.
> Si eres persona: pega la ruta de este archivo en tu primer prompt (`docs/backend/guia-de-trabajo.md`). Existen `apps/api/CLAUDE.md` y `AGENTS.md` que ya apuntan aquí.

**Objetivo:** que los seis servicios se vean como escritos por una sola persona: mismas carpetas, mismos nombres, mismas respuestas de error, mismas pruebas. **Nadie crea su propia arquitectura.**

---

## Índice

1. [Contexto y reparto de módulos](#1-contexto-y-reparto-de-módulos)
2. [Qué va en cada carpeta](#2-qué-va-en-cada-carpeta)
3. [Estructura interna de un servicio](#3-estructura-interna-de-un-servicio)
4. [Qué ya existe en `commons/` (úsalo, no lo reinventes)](#4-qué-ya-existe-en-commons-úsalo-no-lo-reinventes)
5. [Flujo para agregar una funcionalidad](#5-flujo-para-agregar-una-funcionalidad)
6. [Convenciones de código](#6-convenciones-de-código)
7. [Base de datos y migraciones](#7-base-de-datos-y-migraciones)
8. [Seguridad y Firebase](#8-seguridad-y-firebase)
9. [Comunicación entre servicios](#9-comunicación-entre-servicios)
10. [Pruebas](#10-pruebas)
11. [Git, PR, documentación y bitácora de IA](#11-git-pr-documentación-y-bitácora-de-ia)
12. [Cumplimiento de la rúbrica del proyecto integrador](#12-cumplimiento-de-la-rúbrica-del-proyecto-integrador)
13. [Checklist de Pull Request](#13-checklist-de-pull-request)
14. [Prohibido](#14-prohibido)
15. [Decisiones pendientes](#15-decisiones-pendientes)

---

## 1. Contexto y reparto de módulos

Citalis conecta clientes con negocios de belleza (reservas, QR, favoritos, historial) y da al propietario agenda, servicios y directorio de clientes. Los requerimientos viven en [`docs/historias-de-usuario.md`](../historias-de-usuario.md) (7 módulos) y el modelo de datos en [`docs/db/modelo-datos.md`](../db/modelo-datos.md). El backend es un monorepo de **microservicios NestJS + Prisma + PostgreSQL** detrás de un **API Gateway**; la identidad la gestiona **Firebase Authentication**.

| Servicio | Puerto | Módulo / Req | Schema | Dueño de las tablas | Prefijo gateway |
|---|---|---|---|---|---|
| `gateway` | 3000 | — | — | — | — |
| `auth-service` | 3001 | M1 (1.1–1.4) · 7.1 | `auth` | `users`, `audit_log` | `/auth`, `/users` |
| `negocios-service` | 3002 | M2 (2.1–2.5) | `negocios` | `businesses`, `business_images`, `services`, `business_categories`, `municipalities` | `/businesses`, `/catalogs` |
| `agenda-service` | 3003 | M3 (3.1–3.5) | `agenda` | `business_hours`, `business_hour_exceptions`, `reservations` | `/reservations`, `/availability`, `/schedule` |
| `clientes-service` | 3004 | M4 (4.1–4.3) | `clientes` | `client_business_links`, `ratings` | `/clients`, `/ratings` |
| `descubrimiento-service` | 3005 | M5 (5.1–5.3) | `descubrimiento` | `favorites` | `/discover`, `/favorites` |
| `notificaciones-service` | 3006 | M6 (6.1) · 7.3 | `notificaciones` | `notification_preferences`, `notification_tokens` | `/notifications` |

Notas de reparto:

- **M7** no es un servicio aparte: el perfil (7.1) es `users` → `auth-service`; los permisos (7.3) son preferencias de notificación → `notificaciones-service`; privacidad (7.2) es contenido estático de la app. **6.2 y 6.3** (conexión y reintento) son del cliente; el backend solo debe ser **idempotente** (ver §6.6).
- **Búsqueda/cercanía (5.1–5.3):** los negocios son de `negocios-service`. `descubrimiento-service` los consulta por HTTP interno, calcula distancia/orden, integra la API de terceros de geocodificación (rúbrica F3) y guarda los favoritos.
- **Vínculo cliente-negocio (4.1):** `agenda-service` informa a `clientes-service` cuando una reserva se completa; `clientes-service` mantiene `client_business_links`.

### Reglas de arquitectura (no negociables)

1. **Un servicio = un schema.** Solo `auth-service` toca `auth.*`; solo `agenda-service` toca `agenda.*`, etc. **Nunca** se hace `SELECT` a tablas de otro servicio: se pide por HTTP (`/internal/*`).
2. **Sin llaves foráneas entre schemas.** Una referencia a otro servicio es una columna `UUID` simple (`owner_id`, `business_id`, `client_id`…) comentada en el `schema.prisma` con su origen. La integridad se valida en el caso de uso (consultando al dueño del dato).
3. **El gateway no tiene lógica de negocio:** solo enruta, autentica (Firebase), limita tráfico y observa.
4. **Los servicios no se llaman entre sí a ciegas:** cada llamada pasa por un `http-client` de `infrastructure/http-clients/` que usa el contrato de `@backend/contracts`.
5. **Toda la configuración sale de variables de entorno** (único `.env` en la raíz de `apps/api/`). Nada de secretos en el repo.
6. **Código compartido → `commons/`.** Si lo necesitan dos servicios, va a `commons/`; no se copia y pega entre servicios.

> **Relación con `docs/db/schema.sql`:** `schema.sql` es el **modelo lógico** completo (una sola base). Físicamente se reparte por servicio como arriba, y las migraciones de Prisma (`services/*/prisma/migrations`) son lo que realmente se aplica. Las vistas `v_business_rating` y `v_business_agenda` cruzan servicios, por eso no existen físicamente: se componen en código. Un cambio de modelo se refleja **en ambos**: primero se acuerda en `modelo-datos.md`/`schema.sql` y se implementa en la migración del servicio dueño.

---

## 2. Qué va en cada carpeta

```
apps/api/
├── gateway/                    ⛔ Solo ruteo/auth/límites. Tocar únicamente para: nueva ruta (routes.ts) o ruta pública.
├── services/
│   └── <servicio>/
│       ├── prisma/             schema.prisma + migrations/ (versionadas; ver §7)
│       ├── src/
│       │   ├── main.ts         5 líneas: llama a bootstrapService(). No se personaliza.
│       │   ├── app.module.ts   SecurityModule + PrismaModule + HealthModule + módulos de dominio
│       │   ├── prisma.module.ts · config/prisma.service.ts    (idénticos en todos los servicios)
│       │   └── modules/
│       │       ├── health/     GET /health y GET /<prefijo>/test (ya hechos; no modificar)
│       │       └── <dominio>/  uno por agregado (businesses, reservations, ratings…)
│       ├── test/ (solo si hay pruebas de integración; las unitarias van junto al archivo)
│       └── README.md           plantilla de 9.4: responsabilidad, dominio, API, env, cómo levantar, tests, dependencias
├── commons/                    paquetes @backend/* compartidos (§4)
├── scripts/                    herramientas del monorepo (prisma-cli.mjs, smoke-test.mjs). No se usan para lógica de negocio.
├── docker/ · Dockerfile · docker-compose*.yml    infraestructura de despliegue
└── .env.example                ÚNICO catálogo de variables. Variable nueva ⇒ se agrega aquí con comentario.
```

Fuera de `apps/api/`: `docs/` (documentación del repo), `apps/mobile/` (frontend Flutter; el backend **no** depende de él).

---

## 3. Estructura interna de un servicio

Cada **dominio** dentro de `src/modules/<dominio>/` tiene exactamente estas cuatro capas (el esqueleto con `.gitkeep` ya está creado en cada servicio):

```
src/modules/<dominio>/
├── presentation/                  ← HTTP
│   ├── <dominio>.controller.ts       rutas, @Api* de Swagger, @CurrentUser(); NADA de lógica
│   ├── internal-<dominio>.controller.ts   rutas /internal/* para otros servicios (@InternalOnly)
│   └── <dominio>.module.ts           registra controllers y providers; enlaza token → implementación
├── application/                   ← casos de uso
│   ├── dto/                          DTOs de entrada/salida con class-validator + @ApiProperty
│   └── use-cases/<dominio>.service.ts   lógica de negocio y reglas de acceso (propietario, estado…)
├── domain/                        ← el núcleo, sin frameworks
│   ├── entities/                     interfaces/clases TypeScript puras (sin Prisma, sin decoradores Nest)
│   └── repositories/                 IXRepository + `export const X_REPOSITORY = Symbol(...)`
└── infrastructure/                ← detalles técnicos
    ├── persistence/prisma-<x>.repository.ts   ÚNICO sitio que usa PrismaService
    └── http-clients/<otro>.http-client.ts      llamadas a otros servicios o APIs de terceros
```

**Regla de dependencias:** `presentation → application → domain ← infrastructure`.

| Capa | Puede importar | No puede importar |
|---|---|---|
| presentation | application (DTOs, casos de uso), `@backend/security` | Prisma, repositorios concretos, http-clients |
| application | domain, http-clients (por clase inyectada), `@backend/*` | Prisma, Express, controllers |
| domain | nada del proyecto salvo tipos | Nest, Prisma, otras capas |
| infrastructure | domain, Prisma, `@backend/utils` | presentation |

**Referencia viva:** [`services/auth-service/src/modules/users/`](../../apps/api/services/auth-service/src/modules/users/) implementa el patrón completo (registro idempotente, consulta interna para el gateway, perfil) con pruebas. **Cuando dudes cómo escribir algo, copia su forma.**

Patrón del caso de uso con repositorio inyectado por token:

```ts
@Injectable()
export class UsersService {
  constructor(@Inject(USER_REPOSITORY) private readonly users: IUserRepository) {}
}
// en el módulo:  { provide: USER_REPOSITORY, useClass: PrismaUserRepository }
```

Un servicio nuevo de dominio (p. ej. `ratings` en clientes-service) se registra en el `app.module.ts` del servicio **después** de `HealthModule`: el orden importa para que `GET /<prefijo>/test` se resuelva antes que rutas con parámetros (`/<prefijo>/:id`). Además, todo `:id` se valida con `ParseUUIDPipe`.

---

## 4. Qué ya existe en `commons/` (úsalo, no lo reinventes)

Se importa como `import { … } from '@backend/<paquete>'`. Tras cambiar un paquete de `commons/` ejecuta `pnpm build` (o deja corriendo `pnpm dev`).

### `@backend/contracts` — tipos y constantes (sin dependencias)

| Exporta | Para qué |
|---|---|
| `RequestUser`, `FirebaseIdentity` | forma del usuario autenticado |
| `INTERNAL_TOKEN_HEADER`, `USER_ID_HEADER`, `FIREBASE_UID_HEADER`, `USER_EMAIL_HEADER` | nombres de cabeceras gateway→servicio |
| `ServiceName`, `SERVICE_PORTS`, `SERVICE_ROUTE_PREFIX` | registro de servicios, puertos y prefijos |
| `PaginatedResponse<T>`, `PaginationMeta` | forma de respuestas paginadas |
| `ApiErrorResponse`, `HealthReport`, `TestReport` | forma de errores, `/health` y `/<prefijo>/test` |
| `ReservationStatus` | estados de reserva |
| `InternalUserDto`, `InternalBusinessDto`, `InternalServiceDto`, `InternalReservationCompletedDto` | respuestas de las rutas `/internal/*` entre servicios |

Un DTO que cruza servicios **se declara aquí**, nunca duplicado en dos servicios.

### `@backend/security` — autenticación hacia dentro

| Exporta | Uso |
|---|---|
| `SecurityModule` | importarlo una vez en `AppModule`: activa el guard global (todo endpoint exige identidad salvo que se marque lo contrario) |
| `@CurrentUser()` | `RequestUser` (`userId`, `firebaseUid`, `email`) del usuario autenticado **y registrado** |
| `@CurrentIdentity()` | solo identidad Firebase (registro) |
| `@Public()` | endpoint sin autenticación (casi nunca) |
| `@AllowUnregistered()` | exige token pero no cuenta en Citalis (solo registro) |
| `@InternalOnly()` | ruta `/internal/*` entre servicios (exige `x-internal-token`) |

### `@backend/utils` — plomería común

| Exporta | Uso |
|---|---|
| `bootstrapService()` | arranque estándar (`main.ts`): `.env`, variables obligatorias, `ValidationPipe` estricto, filtro de errores, logs, Swagger (solo dev), shutdown |
| `GlobalHttpExceptionFilter` | formato único de error `{ statusCode, code, message, timestamp, path }` |
| `buildHealthReport`, `buildTestReport`, `reportStatusCode` | cuerpo de `/health` y `/<prefijo>/test` |
| `ResilientHttpClient` | **todo** acceso a APIs de terceros: timeout 5 s, 1 reintento solo en GET, errores 502/504 sin filtrar datos (rúbrica F3) |
| `InternalServiceClient` | cliente hacia otro microservicio (agrega `x-internal-token`); `getOrNull()` devuelve `null` en 404 |
| `ExternalServiceException` | excepción que traduce fallos del upstream |
| `serviceUrl('negocios-service')` | URL base de un servicio vecino (`NEGOCIOS_SERVICE_URL` o `localhost:<puerto>`) |
| `PaginationQueryDto`, `buildPaginatedResponse`, `paginationToSkipTake` | paginación estándar (`page`, `pageSize` ≤ 100) |
| `withNotDeleted()` | filtro de soft delete (`deletedAt: null`) en `users` y `businesses` |
| `loadRootEnv`, `assertRequiredEnv`, `isSwaggerEnabled`, `isTestEndpointEnabled` | manejo de entorno |

### `@backend/firebase` — lo usa el gateway

`FirebaseModule` / `FirebaseAuthService`: `verifyIdToken()` y `revokeSessions()`. Los servicios de dominio **no** verifican tokens: confían en el gateway (ver §8). `notificaciones-service` lo ampliará con el envío push (FCM) cuando se implemente el módulo 6.

### `@backend/observability` — logs sin datos sensibles

`JsonLogger` (producción), `RequestLoggingInterceptor` (ruta + status + ms + id de usuario, nunca cuerpos ni query), `maskSensitiveFields()` para loguear objetos (enmascara contraseñas, tokens, correos, teléfonos…).

### Qué hace ya el gateway

Verifica el token de Firebase, resuelve el usuario interno en `auth-service` (caché 30 s), borra cualquier cabecera `x-*` falsificada, inyecta `x-user-id`/`x-firebase-uid`/`x-user-email`/`x-internal-token`, bloquea `/internal/*`, aplica `helmet`, CORS con lista blanca y límite de peticiones por IP. Rutas públicas: `/health`, `/docs`, `/<prefijo>/test`.

---

## 5. Flujo para agregar una funcionalidad

Ejemplo: *Req 2.4 — crear un servicio del catálogo* en `negocios-service`.

1. **Rama:** `git switch -c feat/negocios-crear-servicio` desde `main` actualizado (§11).
2. **Lee el requerimiento** en `historias-de-usuario.md` y anota sus *reglas de negocio* y *criterios de aplicación*: se convierten en validaciones y pruebas.
3. **Define el contrato primero** (endpoint, entrada, salida, errores). Si otro servicio lo consumirá, agrega el DTO a `@backend/contracts`.
4. **Datos:** si hace falta una tabla/columna, edita el `schema.prisma` **de tu servicio** y crea la migración (§7). Nunca toques el schema de otro servicio.
5. **Dominio:** entidad en `domain/entities`, interfaz `IServiceRepository` + token en `domain/repositories`.
6. **Infraestructura:** `PrismaServiceRepository` en `infrastructure/persistence`. Si necesitas datos de otro servicio, crea su `*.http-client.ts` (§9).
7. **Aplicación:** DTOs con `class-validator` + `@ApiProperty`, y el caso de uso en `use-cases/*.service.ts` con **toda** la lógica y las reglas de acceso (§8.3).
8. **Presentación:** controller con `@ApiTags`, `@ApiOperation` y `@ApiResponse` de **todos** los códigos posibles (200/201, 400, 401, 403, 404, 409…), y registro en el `*.module.ts` del dominio.
9. **Gateway:** si el recurso usa un prefijo nuevo, agrégalo en `gateway/src/modules/proxy/routes.ts` y a la tabla de §1 y del README. Si reutiliza un prefijo existente no hay que tocar nada.
10. **Pruebas** (§10): unitarias del caso de uso (incluyendo las reglas de acceso y los datos inválidos).
11. **Verifica en local:** `pnpm lint && pnpm test && pnpm build`, levanta el servicio y prueba el endpoint (Swagger en `http://localhost:<puerto>/docs`). `pnpm smoke` debe seguir en verde.
12. **Documenta:** actualiza el README del servicio (endpoints, variables), `.env.example` si agregaste variables, y la tabla de §12 si cambió el estado de un requisito.
13. **Bitácora de IA** (§11.4) y **PR** con la plantilla de §13.

---

## 6. Convenciones de código

### 6.1 Nombres

- Identificadores y archivos en **inglés**; comentarios, mensajes de error visibles al usuario y documentación en **español**.
- Archivos en `kebab-case` con sufijo: `*.controller.ts`, `*.service.ts`, `*.module.ts`, `*.dto.ts`, `*.entity.ts`, `*.repository.interface.ts`, `prisma-*.repository.ts`, `*.http-client.ts`, `*.spec.ts` (junto al archivo que prueba).
- DTOs: `CreateXDto`, `UpdateXDto`, `XResponseDto`, `XQueryDto`.
- Clases `PascalCase`; variables/funciones `camelCase`; constantes y tokens `UPPER_SNAKE`; columnas SQL `snake_case` (en Prisma: campo `camelCase` + `@map("snake_case")`).

### 6.2 API REST

- Rutas en inglés, plural y `kebab-case`: `POST /businesses`, `GET /businesses/:id/services`, `PATCH /reservations/:id/status`.
- Verbos HTTP: `GET` leer, `POST` crear, `PATCH` actualizar parcial, `DELETE` eliminar. `201` al crear, `200` al leer/actualizar, `204` sin cuerpo.
- Listados paginados con `PaginationQueryDto` → `PaginatedResponse<T>`.
- **Nunca devuelvas la entidad de Prisma**: mapea a un `XResponseDto` (así no se filtran campos internos como `deletedAt` o `firebaseUid`).

### 6.3 Errores

- Lanza excepciones de Nest con `code` estable y mensaje en español:
  ```ts
  throw new ConflictException({ code: 'RESERVATION_OVERLAP', message: 'Ese horario ya no está disponible' });
  ```
- Todos los errores salen como `{ statusCode, code, message, timestamp, path }` (lo hace `GlobalHttpExceptionFilter`; no lo repliques ni lo sustituyas).
- `code` en `UPPER_SNAKE`. Códigos de validación: `VALIDATION_ERROR` (automático).
- 401 sin token o token inválido · 403 autenticado pero sin permiso (o `USER_NOT_REGISTERED`) · 404 no existe **o no es tuyo** (ver §8.3) · 409 conflicto de estado · 422 no se usa (validación es 400).
- Un `catch` nunca se traga el error: se traduce a excepción de dominio o se relanza. Los 500 muestran mensaje genérico; el detalle va al log.

### 6.4 DTOs y validación (rúbrica F5 y S7)

- `ValidationPipe` global ya está configurado con `whitelist` y `forbidNonWhitelisted`: **un campo no declarado en el DTO se rechaza**.
- Todo campo con `class-validator` (`@IsString`, `@Length`, `@IsUUID`, `@IsInt @Min @Max`, `@Matches`…), `@Transform` para `trim` y `@ApiProperty` con ejemplo.
- Las reglas del cliente (Flutter) **se repiten** en el servidor: nunca se confía en que la app validó.
- Valida también las **respuestas de APIs de terceros** antes de usarlas (rúbrica S7).

### 6.5 Tipos de datos

| Dato | Regla |
|---|---|
| Identificadores | UUID v4 (`gen_random_uuid()`) |
| Fechas/horas | `TIMESTAMPTZ` en UTC; en JSON, ISO 8601 (`2026-11-01T16:00:00.000Z`). La zona horaria solo se aplica en la app |
| Día de la semana | entero `0 = lunes … 6 = domingo` |
| Dinero | `Decimal(10,2)`; en JSON como **string** (`"250.00"`), nunca `float` |
| Correo | `citext` (sin distinguir mayúsculas) |
| Borrado | soft delete (`deleted_at`) solo en `users` y `businesses`; siempre `...withNotDeleted()` en sus consultas |
| Precio/duración de una reserva | se **congelan** al reservar (`price_at_booking`, `duration_minutes`) |

### 6.6 Idempotencia y concurrencia (Req 6.3)

El cliente reintenta tras un corte de red, así que **escribir dos veces no debe duplicar**:

- `POST /auth/register` ya es idempotente (devuelve la cuenta existente).
- **Reservas:** la base impide traslapes con `no_overlap_reservations` (`EXCLUDE USING gist`). Ante un choque Prisma lanza `PrismaClientUnknownRequestError` **sin `code`**; el mensaje contiene `23P01`. El repositorio debe detectarlo y lanzar un error de dominio que el caso de uso convierta en `409 RESERVATION_OVERLAP`. Si quien choca es **la misma reserva del mismo cliente** (reintento), devuelve esa reserva con `200` en vez de error.
- Para otras escrituras repetibles usa claves únicas (`@@unique`) y captura `P2002`.
- Operaciones de varios pasos dentro de un servicio: `prisma.$transaction()`.

### 6.7 Logs y datos personales (rúbrica S5)

- Usa `Logger` de Nest (no `console.log`: ESLint lo prohíbe).
- **Nunca** loguees tokens, contraseñas, correos, teléfonos ni cuerpos de petición. Para objetos usa `maskSensitiveFields()`.
- Los mensajes de error al cliente no incluyen detalles técnicos (SQL, stack, URLs).

### 6.8 Estilo

Prettier + ESLint son la autoridad: `pnpm format` y `pnpm lint` antes de cada commit. Sin `any` explícito (el lint falla), sin `// @ts-ignore`, sin `console.log`. TypeScript en modo `strict`.

---

## 7. Base de datos y migraciones

**Una base, un schema por servicio** (`auth`, `negocios`, `agenda`, `clientes`, `descubrimiento`, `notificaciones`). `DATABASE_URL` es única; el script `scripts/prisma-cli.mjs` le añade `?schema=<servicio>` solo para el CLI de Prisma, de modo que **cada servicio tiene su propio historial de migraciones** (`_prisma_migrations` dentro de su schema) y no se pisan.

### Crear o cambiar una tabla

```bash
cd apps/api/services/<servicio>
# 1. edita prisma/schema.prisma (modelos con @@map("tabla") y @@schema("<schema>"))
# 2. crea y aplica la migración en TU base de desarrollo:
pnpm prisma:dev --name descripcion_corta_del_cambio
# 3. revisa el SQL generado en prisma/migrations/<fecha>_descripcion_corta/migration.sql y súbelo al PR
```

- Para SQL que Prisma no sabe expresar (**CHECK, EXCLUDE, triggers, datos semilla, extensiones**) usa `pnpm prisma:dev --create-only --name x`, **edita** el `migration.sql` nuevo y luego `pnpm prisma:dev` para aplicarlo. Las migraciones iniciales de cada servicio son el modelo a imitar (triggers `updated_at`, `CHECK`, `EXCLUDE`, semillas).
- Las extensiones (`citext`, `pg_trgm`, `btree_gist`) se crean con `CREATE EXTENSION IF NOT EXISTS` dentro de la migración; **no** se declaran en `schema.prisma` (son globales a la base y generarían *drift* entre servicios).
- Los `CHECK`, el `EXCLUDE` y los triggers solo existen en el SQL de la migración; Prisma no los compara (verificado: tras aplicarlos, el schema sigue "en sync" y `prisma:dev` no genera cambios).

### Reglas

1. **Nunca edites una migración que ya está en `main`** ni una ya aplicada en otra base. Corrige con una migración nueva.
2. **Nunca uses `prisma db push`** ni `prisma migrate reset` sobre una base compartida (Supabase/Neon del equipo). Si `migrate dev` pide resetear, **responde no** y pregunta al equipo.
3. En bases compartidas/remotas solo se aplica `pnpm db:migrate` (`migrate deploy`). `migrate dev` (crear migraciones) se hace **en tu Postgres local** (`pnpm db:up`), porque necesita crear una base *shadow*.
4. Si dos personas cambian el schema del mismo servicio, la segunda rehace su migración tras actualizar desde `main` (coordínense por el grupo antes de empezar).
5. El `schema.prisma` y su migración **van en el mismo commit**. Tras cambiar el schema, `pnpm db:generate` regenera el cliente.
6. Cambios que afectan a otro servicio (p. ej. quitar un campo que otro consume) se avisan en el PR y se actualiza `@backend/contracts`.
7. Los catálogos (categorías, municipios) son **datos semilla en la migración**: agregar una categoría = migración con `INSERT … ON CONFLICT DO NOTHING`.

---

## 8. Seguridad y Firebase

### 8.1 Cómo viaja la identidad

```
App ──Bearer <token ID Firebase>──▶ gateway ──x-user-id, x-firebase-uid, x-user-email, x-internal-token──▶ servicio
```

- La app inicia sesión con Firebase y manda el **token ID** (vigencia 1 h; el SDK lo renueva).
- El **gateway** lo verifica (`firebase-admin`), resuelve el usuario interno y reenvía la identidad. **Los servicios no verifican Firebase**: el `GatewayAuthGuard` global exige `x-internal-token` válido (así nadie falsifica las cabeceras saltándose el gateway) y construye `request.user`.
- Los servicios no son accesibles desde fuera (en Docker solo el gateway publica puerto).
- Cerrar sesión (1.3) es del lado de la app (Firebase `signOut`). Para invalidar sesiones desde el servidor existe `FirebaseAuthService.revokeSessions()` (requiere cuenta de servicio).

### 8.2 Qué hacer en un endpoint

```ts
@Controller('businesses')
export class BusinessesController {
  @Post()
  create(@CurrentUser() user: RequestUser, @Body() dto: CreateBusinessDto) { ... }
}
```

- Por defecto **todo endpoint exige usuario registrado**. No uses `@Public()` salvo health/test.
- El `userId` sale **siempre** de `@CurrentUser()`; **jamás** del body, query o params (si el cliente puede decir "soy el usuario X", cualquiera lo suplanta).

### 8.3 Reglas de acceso por usuario (rúbrica F2 y S4)

Autorizar es responsabilidad del **caso de uso** y debe estar cubierto por pruebas unitarias:

| Recurso | Quién puede |
|---|---|
| Negocio y servicios | Solo el propietario (`business.ownerId === user.userId`) modifica; lectura pública de negocios activos |
| Horarios | Solo el propietario del negocio |
| Reserva | Crear: cualquier usuario autenticado (como cliente); ver/cancelar: el cliente dueño **o** el propietario del negocio; cambiar estado a `completed`/`no_show`: solo el propietario |
| Directorio de clientes / historial (4.1, 4.2) | Solo el propietario, y solo de clientes con al menos una reserva en su negocio |
| Valoración | Solo el cliente de una reserva `completed`, una vez |
| Favoritos, preferencias, tokens FCM | Solo el propio usuario |

- Si el recurso **existe pero no es del usuario**, responde **404** (no 403): no reveles que existe.
- Verifica también la pertenencia al encadenar recursos (`serviceId` debe pertenecer al `businessId` indicado).
- Toda consulta de "mis cosas" filtra por `userId`/`ownerId` **en la consulta**, no después en memoria.

### 8.4 Secretos y configuración (rúbrica S3)

- Cero secretos en el repo: `.env`, JSON de cuenta de servicio de Firebase, claves de API y keystores están en `.gitignore` y **no se versionan**. Solo `.env.example` con valores de ejemplo.
- Si subes un secreto por accidente, **rótalo de inmediato** (borrar el commit no basta).
- En producción `INTERNAL_API_TOKEN` ≥ 32 caracteres, `SWAGGER_ENABLED=false`, `ENABLE_TEST_ENDPOINTS=false`.
- Nunca pegues credenciales ni datos personales reales en una IA.

### 8.5 Transporte (rúbrica S2)

El gateway debe quedar detrás de TLS (balanceador o proxy inverso) y con `TRUST_PROXY` configurado; `helmet` ya agrega HSTS y cabeceras de seguridad. La app solo habla HTTPS con el backend de producción.

---

## 9. Comunicación entre servicios

- **Síncrona por HTTP interno.** El servicio dueño expone `GET/POST /internal/...` con `@InternalOnly()` (controlador `internal-*.controller.ts`, oculto en Swagger). El consumidor lo llama desde un `http-client`:

```ts
// infrastructure/http-clients/negocios.http-client.ts
@Injectable()
export class NegociosHttpClient {
  private readonly client = new InternalServiceClient('negocios-service', serviceUrl('negocios-service'));

  getService(serviceId: string): Promise<InternalServiceDto | null> {
    return this.client.getOrNull<InternalServiceDto>(`/internal/services/${serviceId}`);
  }
}
```

- El DTO de respuesta es de `@backend/contracts` (`InternalServiceDto`…).
- **Timeouts y errores:** `InternalServiceClient` ya trae timeout de 5 s y traduce fallos a 502/504; el caso de uso decide si la operación puede continuar.
- Un servicio **no** llama a otro dentro de una transacción de BD.
- **Efectos entre servicios** (p. ej. reserva `completed` → actualizar `client_business_links`): `agenda-service` llama a `POST /internal/clients/visits` de `clientes-service` **después** de confirmar su propio cambio; la operación del destino debe ser idempotente (clave `reservationId`). No hay Kafka/outbox en Citalis (a diferencia de nómina): no lo agregues sin acuerdo del equipo.
- Los **datos de contacto** del cliente que ve el propietario (4.1: nombre, teléfono, correo) los pide `clientes-service` a `auth-service` (`/internal/users/...`) solo para clientes vinculados.

### APIs de terceros (rúbrica F3)

Toda API externa (geocodificación, FCM…) se consume así: un `*.http-client.ts` en `infrastructure/http-clients/` que **envuelve `ResilientHttpClient`** (timeout, reintento controlado, errores traducidos), con URL y credencial leídas de variables de entorno (`GEOCODING_BASE_URL`, `GEOCODING_API_KEY`), validando la respuesta recibida y con pruebas con **datos inválidos y fallos** (ver `http-client.spec.ts` como modelo). El caso de uso depende de una interfaz del dominio, no del cliente concreto, para poder sustituirlo por uno falso en pruebas.

---

## 10. Pruebas

| Qué | Dónde | Cómo |
|---|---|---|
| Reglas de negocio / casos de uso | `*.service.spec.ts` junto al servicio | repositorio y http-clients **falsos** (objetos con `jest.fn()`); sin BD ni red |
| Guards, utilidades, clientes HTTP | `commons/*/src/*.spec.ts` | igual |
| Controladores con lógica de estado HTTP | `*.controller.spec.ts` | instanciar con dependencias falsas |
| Endpoint `/test` de cada servicio | `modules/health/test.controller.spec.ts` | ya creado |
| Todo el sistema | `pnpm smoke` | contra el stack levantado |

- Comandos: `pnpm test` (todo) · `pnpm --filter @backend/<servicio> test`.
- **Mínimo por caso de uso:** camino feliz + cada regla de negocio + autorización (usuario ajeno ⇒ 404/403) + entrada inválida.
- Las pruebas no dependen del orden ni de datos previos; no usan la base de desarrollo.
- Un bug corregido lleva una prueba que lo reproduce.
- La cobertura objetivo de la lógica de negocio es ≥ 70 %.

---

## 11. Git, PR, documentación y bitácora de IA

### 11.1 Ramas

Se trabaja **solo por Pull Request** hacia `main` (nadie hace push directo; conviene activar la protección de rama en GitHub). Una rama por tarea con prefijo `feat/`, `fix/`, `refactor/`, `docs/`, `chore/`, `test/`: `feat/agenda-disponibilidad`.

### 11.2 Commits

En **español, imperativo**, con prefijo de tipo y alcance (el del servicio o `gateway`/`commons`):

```
feat(agenda): calcular horarios disponibles por servicio
fix(auth): responder 200 al reintentar el registro
docs(guia): documentar el flujo de migraciones
```

Un commit = un cambio coherente. El `schema.prisma` y su migración van juntos.

### 11.3 Pull Request

- Un PR por tarea, que **referencie el requerimiento** (`Req 3.3`) y la rúbrica si aplica (`F2`).
- Descripción: qué cambia · por qué · cómo probarlo (comandos o `curl`).
- **Mínimo 1 aprobación** de otro integrante (la rúbrica lo exige; el autor no se aprueba a sí mismo). CI en verde.
- Debe cumplir el checklist de §13.

### 11.4 Uso de IA — Nivel 4 (bitácora obligatoria)

La rúbrica permite IA libre **con bitácora de prompts** en [`docs/ia/bitacora.md`](../ia/bitacora.md) y **declaración en cada entrega**. Por eso:

1. **Registra** cada sesión relevante: fecha, quién, herramienta/modelo, qué pediste (resumen del prompt), qué generó y **qué revisaste/cambiaste**.
2. **Tú eres responsable del código**: en la defensa debes poder explicarlo y modificarlo en vivo (5 min por integrante). No subas código que no entiendes.
3. **Nunca** pegues credenciales, llaves, `.env` ni datos personales reales en una IA.
4. La IA debe seguir **esta guía**; si propone otra estructura, recházala.

### 11.5 Documentos que se actualizan con tu cambio

| Si cambias… | Actualiza… |
|---|---|
| un endpoint o variable | README del servicio · `.env.example` |
| una tabla/columna | `schema.prisma` + migración · `docs/db/modelo-datos.md` si cambia el modelo |
| un permiso/capacidad del dispositivo (cámara, ubicación, notificaciones) | `docs/permisos.md` (rúbrica 4.5) |
| el estado de un requisito | `docs/estado.md` |
| pruebas o evidencias | `docs/pruebas.md` |
| esta guía (nueva regla/decisión) | este archivo, en su propio PR |

---

## 12. Cumplimiento de la rúbrica del proyecto integrador

Fuente: *Proyecto integrador — Desarrollo Móvil Integral (UTEZ, sep–dic 2026)*. **Incumplir un punto baja la calificación**; esta tabla dice qué le toca al backend y en qué estado está. Los requisitos que son 100 % de la app Flutter (F4, F6, F7, 4.1–4.5 de pantallas y permisos del SO) los lleva el frontend, pero el backend no debe bloquearlos.

### 12.1 Requisitos funcionales

| ID | Requisito | Backend | Estado |
|---|---|---|---|
| F1 | Autenticación remota: registro, inicio/cierre de sesión, restauración y recuperación de contraseña | Firebase Auth; gateway verifica token; `POST /auth/register`, `GET /users/me` | ✅ Base lista. Registro/inicio/recuperación los hace Firebase desde la app |
| F2 | ≥ 2 entidades del dominio con alta, consulta, edición y baja en la nube; una pertenece al usuario autenticado; reglas de acceso | Candidatas: `Business` + `Service` (negocios) y `Reservation` (agenda). Reglas en §8.3 | ⏳ Pendiente. **Hito H3 (30 oct)** |
| F3 | ≥ 1 API de terceros detrás de servicio/repositorio, con timeout, manejo de errores y credencial fuera del repo; prueba con datos inválidos | `ResilientHttpClient` listo; falta elegir proveedor (geocodificación en descubrimiento-service) | ⏳ Cliente base listo · proveedor pendiente (§15) |
| F4 | ≥ 6 pantallas con navegación coherente, incl. perfil/ajustes | App | — (frontend) |
| F5 | Formularios validados en el cliente **y reglas equivalentes en el servidor** | `ValidationPipe` estricto global + DTOs (§6.4) | ✅ Mecanismo listo; cada endpoint debe declarar sus DTOs |
| F6 | Estados cargando/datos/error/vacío | App; el backend responde errores con formato estándar y listados vacíos como `data: []` | — (frontend) |
| F7 | Sin conexión: detecta, indica y reintenta | App; el backend es idempotente (§6.6) | ⏳ Idempotencia de reservas pendiente de implementar |

### 12.2 Seguridad mínima (OWASP MASVS / LFPDPPP)

| ID | Requisito | Qué lo cubre en el backend |
|---|---|---|
| S1 | Token solo en almacenamiento seguro | App (`flutter_secure_storage`). El backend no guarda sesiones |
| S2 | Todo el tráfico por HTTPS | Despliegue detrás de TLS + `helmet`/HSTS + `TRUST_PROXY` (§8.5). ⏳ Falta definir hosting (§15) |
| S3 | Cero secretos en el repo; configuración por ambiente | `.env` ignorado, `.env.example`, cuentas de servicio fuera del repo, validación de variables al arrancar ✅ |
| S4 | Reglas de BD y de almacenamiento en la nube restringidas a la identidad autorizada, con mínimo privilegio **y probadas** | La app no tiene acceso a la BD: solo vía API con reglas por usuario (§8.3) **+ pruebas unitarias de esas reglas**. Para Firebase Storage (fotos) hay que escribir y probar `storage.rules` por propietario (§15) |
| S5 | Logs sin tokens ni datos personales; release sin mensajes técnicos | `JsonLogger`, `RequestLoggingInterceptor`, `maskSensitiveFields`; Swagger y `/test` apagados en producción; errores genéricos ✅ |
| S6 | Inventario de datos con finalidad y retención; aviso de privacidad | Documento de inventario de datos (pendiente) a partir de `modelo-datos.md`; aviso en la app (§15) |
| S7 | Validación de entradas y de **respuestas de la API** | DTOs estrictos ✅; validar respuestas de terceros en cada http-client (§9) |
| S8 | Dependencias vigentes y verificadas | Revisar con `pnpm outdated` / `pnpm audit` antes de H4 y H7 |

### 12.3 Capacidades del dispositivo (base obligatoria) — apoyo del backend

| ID | Capacidad | Parte del backend |
|---|---|---|
| P1 | Cámara/galería → foto ligada al registro, reducida, **subida a la nube con acceso restringido al dueño** | Guardar `hero_image_url` / `business_images.url` (negocios-service). La foto va a **Firebase Storage** con reglas por propietario; el backend valida que la URL pertenezca al bucket y a la ruta del propietario (§15) |
| P2 | Ubicación en primer plano; alternativa manual (dirección/zona) | Búsqueda por municipio/zona y por cercanía (`latitude`/`longitude`, descubrimiento-service); geocodificación de dirección (F3) |
| P3 | Notificación útil, con permiso en contexto e interruptor en Ajustes | `notificaciones-service`: `notification_preferences` (interruptor) y `notification_tokens` (FCM); recordatorios de citas |

Las 9 reglas de permisos (4.2) y el documento `docs/permisos.md` (4.5) los completa el equipo con el frontend; el backend aporta la **finalidad y retención** del dato (qué se guarda, hasta cuándo).

### 12.4 Optativas relacionadas con el backend

El equipo elige capacidades optativas (mínimo 5 pts con 5 integrantes, 6 con 6; al menos 2 distintas). Las que tocan backend: **O6 Push remoto segmentado** (2 pts, `notificaciones-service` + FCM), **O2 Escáner QR** (el código ya viene de `deep_link_code`, Req 2.5/3.5), **O3 Mapa** (usa P2 y datos de descubrimiento). Registrar la elección en `docs/permisos.md` antes del **hito H3**.

### 12.5 Calendario y entregables

| Hito | Fecha | Entrega | Qué implica para el backend |
|---|---|---|---|
| H2 | 16 oct (formativo) | Esqueleto por capas + F1 + P1 | ✅ Esqueleto del backend y F1 base |
| **H3** | **30 oct** (formativo) | **F2 datos en la nube con reglas por usuario + P2 + P3** | CRUD con propiedad por usuario (negocios, agenda), ubicación, notificaciones |
| **H4** | **12 nov** (sumativo U II) | App funcional: F1–F7, S1–S8, API de terceros, nube y base obligatoria; ≥ 50 % de optativas | Todos los módulos del backend, F3, S1–S8 verificables, backend desplegado con HTTPS |
| H5 | 27 nov (sumativo) | Reporte de pruebas (unitarias, widget, integración) y builds debug/release | Pruebas del backend y `docs/pruebas.md` |
| H6 | 4 dic (sumativo) | `docs/permisos.md` completo + manifiesto fusionado revisado | Finalidad/retención de datos |
| H7 | 7–11 dic | AAB/APK firmado, distribución y **defensa** | Backend estable; cada integrante explica y modifica su parte |

**Prioridad sugerida de implementación** (cada paso desbloquea al frontend): 1) `negocios` (negocio + servicios + catálogos) → 2) `agenda` (horarios, disponibilidad, reservas) → 3) `descubrimiento` (búsqueda, cercanía, API de terceros, favoritos) → 4) `notificaciones` (preferencias, tokens, recordatorios) → 5) `clientes` (vínculo, historial, valoraciones).

**Estructura de repositorio exigida** (§7 del enunciado): `README.md` con integrantes, cómo ejecutar y **tabla de responsables por capacidad** · `docs/planeacion` · `docs/estado.md` · `docs/permisos.md` · `docs/pruebas.md` · `docs/distribucion/` · `docs/ia/bitacora.md`. Cada integrante es responsable de al menos una capacidad y su historial de commits lo demuestra: **commitea con tu propio usuario** y en ramas propias.

---

## 13. Checklist de Pull Request

Marca cada punto antes de pedir revisión:

- [ ] Sigue la estructura de §3 (capas, nombres, sin lógica en controllers, Prisma solo en `infrastructure/persistence`).
- [ ] No lee tablas de otro servicio ni crea llaves foráneas entre schemas.
- [ ] `userId` sale de `@CurrentUser()`; la autorización por propietario/cliente está en el caso de uso y probada (usuario ajeno ⇒ 404/403).
- [ ] DTOs con `class-validator` y `@ApiProperty`; el controller documenta todos los `@ApiResponse` posibles.
- [ ] Errores con `code` estable y mensaje en español; sin `try/catch` que oculte fallos.
- [ ] Migración nueva (si hay cambio de datos) junto al `schema.prisma`; ninguna migración antigua editada.
- [ ] Pruebas nuevas o actualizadas; `pnpm lint`, `pnpm test`, `pnpm build` en verde; `pnpm smoke` ok con el stack levantado.
- [ ] Sin secretos, `.env`, JSON de Firebase ni datos personales; variables nuevas en `.env.example`.
- [ ] Sin `console.log`, `any`, tokens ni datos personales en logs.
- [ ] README del servicio, `docs/estado.md` y (si aplica) `docs/permisos.md` actualizados.
- [ ] Entrada en `docs/ia/bitacora.md` si usaste IA.
- [ ] Commits con el formato de §11.2 y descripción del PR con *qué / por qué / cómo probar* y el `Req` o rúbrica que atiende.

---

## 14. Prohibido

- Crear carpetas o capas distintas a §3, o una arquitectura "propia" en tu servicio.
- Importar `PrismaService` fuera de `infrastructure/persistence` (y de `health`).
- Leer/escribir el schema de otro servicio, o añadir FKs entre schemas.
- Usar `axios`/`fetch` directo a un servicio o API externa: se usa `InternalServiceClient`/`ResilientHttpClient`.
- Verificar tokens de Firebase dentro de un servicio de dominio (lo hace el gateway).
- Devolver entidades de Prisma crudas, o aceptar `userId` desde el cliente.
- Editar migraciones ya integradas, `db push`, `migrate reset` en bases compartidas.
- Subir `.env`, JSON de cuenta de servicio, claves de API, keystores o `google-services.json`.
- Lógica de negocio en el gateway, en `commons/` o en `scripts/`.
- Duplicar tipos/DTOs de contrato en lugar de `@backend/contracts`; copiar y pegar utilidades entre servicios en lugar de `commons/`.
- `console.log`, `any`, `// @ts-ignore`, `catch {}` vacío.
- Agregar dependencias pesadas, un message broker o un nuevo servicio sin acuerdo del equipo.

---

## 15. Decisiones pendientes

Cosas que **hay que decidir y documentar** (abrir PR/ADR cuando se resuelvan):

| # | Decisión | Por qué importa | Límite sugerido |
|---|---|---|---|
| 1 | **Proveedor de geocodificación** (F3): OpenStreetMap/Nominatim, Geoapify, Google… | Es la API de terceros que exige la rúbrica; define `GEOCODING_BASE_URL`/`GEOCODING_API_KEY` | Antes de H3 |
| 2 | **Hosting del backend con HTTPS** y de la base (Supabase/Neon/EC2/Render) | S2 y las pruebas en dispositivo físico (P1/P2) necesitan un backend alcanzable por HTTPS | Antes de H4 |
| 3 | **Firebase Storage + `storage.rules`** por propietario, con pruebas de reglas | S4 y P1: foto subida a la nube con acceso restringido al dueño | Antes de H3 |
| 4 | Cómo se guarda y expira el **token FCM** y quién envía los recordatorios (cron en notificaciones-service) | P3/6.1/O6 | Antes de H3 |
| 5 | **Roles de BD por servicio** con permisos solo sobre su schema (mínimo privilegio) | Refuerza S4; hoy todos los servicios usan la misma credencial | Antes de H7 |
| 6 | **Inventario de datos** (finalidad, retención) y aviso de privacidad | S6 y LFPDPPP | Antes de H4 |
| 7 | ¿Un negocio por propietario? (hoy `UNIQUE(owner_id)`) | Preguntas abiertas de `modelo-datos.md` | Cuando cambie el alcance |
