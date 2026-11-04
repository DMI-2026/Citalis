# Citalis · Endpoints que necesita la app

> Contrato **app ⇄ backend** derivado del frontend ya refactorizado a MVVM (`apps/mobile/lib/`).
> Cada endpoint sale de un método de un repositorio de la app (`lib/data/repositories/*/*_repository.dart`). Hoy esos repositorios tienen una implementación *fake* en memoria; al terminar un endpoint, se escribe la implementación remota y se registra en `lib/config/dependencies.dart`, **sin tocar pantallas ni ViewModels**.
>
> Este documento **no sustituye** a [`guia-de-trabajo.md`](guia-de-trabajo.md): la estructura, las reglas de acceso (§8.3), los errores (§6.3) y los tipos (§6.5) de la guía mandan. Si algo de aquí la contradice, gana la guía y se corrige este archivo.

_Última actualización: 2026-11-04._

---

## Índice

1. [Convenciones comunes](#1-convenciones-comunes)
2. [Resumen y orden de implementación](#2-resumen-y-orden-de-implementación)
3. [Autenticación y perfil — auth-service](#3-autenticación-y-perfil--auth-service)
4. [Catálogos y negocio propio — negocios-service](#4-catálogos-y-negocio-propio--negocios-service)
5. [Disponibilidad, reservas y horarios — agenda-service](#5-disponibilidad-reservas-y-horarios--agenda-service)
6. [Exploración y favoritos — descubrimiento-service](#6-exploración-y-favoritos--descubrimiento-service)
7. [Directorio de clientes — clientes-service](#7-directorio-de-clientes--clientes-service)
8. [Preferencias y tokens — notificaciones-service](#8-preferencias-y-tokens--notificaciones-service)
9. [Endpoints internos que hacen falta](#9-endpoints-internos-que-hacen-falta)
10. [Objetos JSON compartidos](#10-objetos-json-compartidos)
11. [Diferencias entre la app y el modelo de datos](#11-diferencias-entre-la-app-y-el-modelo-de-datos)

---

## 1. Convenciones comunes

| Tema | Regla |
|---|---|
| Base URL | El **gateway** (`http://localhost:3000` en desarrollo; HTTPS en producción). La app nunca llama a un servicio directo |
| Autenticación | `Authorization: Bearer <token ID de Firebase>` en **todas** las rutas de esta lista |
| Identidad | El usuario sale de `@CurrentUser()`; **ningún** endpoint recibe `userId`/`ownerId`/`clientId` propio en body o query |
| Errores | `{ statusCode, code, message, timestamp, path }`. La app muestra `message` tal cual y decide por `code` (p. ej. `RESERVATION_OVERLAP` recarga horarios) |
| Recurso ajeno | `404` (no `403`), para no revelar que existe |
| Fechas | ISO 8601 en UTC (`2026-11-06T17:30:00.000Z`). Una fecha sin hora (`date`) va como `YYYY-MM-DD` y se interpreta en `America/Mexico_City` |
| Horas del día | `"HH:mm"` (`"09:00"`) |
| Día de la semana | `0 = lunes … 6 = domingo` |
| Dinero | string con 2 decimales (`"320.00"`) |
| Listas | `{ "data": [...] }`; si está paginada, se agrega `pagination` (`PaginatedResponse` de `@backend/contracts`). Vacía = `data: []`, nunca `404` |
| Reintentos (F7) | La app reintenta tras un corte de red: los `POST`/`PUT`/`DELETE` marcados como **idempotentes** no deben duplicar ni fallar al repetirse |

---

## 2. Resumen y orden de implementación

Estado: ✅ ya existe · ⏳ pendiente. Prioridad = orden sugerido por la guía (§16): cada bloque desbloquea pantallas de la app.

| # | Método y ruta | Servicio | Repositorio · método (app) | Pantallas | Prioridad | Estado |
|---|---|---|---|---|---|---|
| 1 | `POST /auth/register` | auth | `AuthRepository.register` | Registro | — | ✅ |
| 2 | `GET /users/me` | auth | `ProfileRepository.getProfile` | Perfil, Editar perfil, Ubicación | — | ✅ |
| 3 | `PATCH /users/me` | auth | `ProfileRepository.updateProfile` | Editar perfil, Ubicación | 1 | ⏳ |
| 4 | `GET /catalogs/categories` | negocios | `CatalogRepository.getCategories` | Explorar, Registrar/editar negocio | 1 | ⏳ |
| 5 | `GET /catalogs/municipalities` | negocios | `CatalogRepository.getMunicipalities` | Registrar/editar negocio, Ubicación | 1 | ⏳ |
| 6 | `POST /businesses` | negocios | `MyBusinessRepository.register` | Registrar negocio | 1 | ⏳ |
| 7 | `GET /businesses/me` | negocios | `MyBusinessRepository.getMyBusiness` | Perfil (banner), todo el modo empresa | 1 | ⏳ |
| 8 | `PATCH /businesses/me` | negocios | `MyBusinessRepository.updateProfile` | Editar perfil del negocio | 1 | ⏳ |
| 9 | `POST /businesses/me/services` | negocios | `MyBusinessRepository.addService` | Servicios (empresa) | 1 | ⏳ |
| 10 | `PATCH /businesses/me/services/:serviceId` | negocios | `MyBusinessRepository.updateService` | Servicios (empresa) | 1 | ⏳ |
| 11 | `DELETE /businesses/me/services/:serviceId` | negocios | `MyBusinessRepository.deleteService` | Servicios (empresa) | 1 | ⏳ |
| 12 | `GET /schedule/hours` | agenda | `MyBusinessRepository.getMyBusiness` (compone) | Perfil del negocio, Horarios | 2 | ⏳ |
| 13 | `PUT /schedule/hours/:dayOfWeek` | agenda | `MyBusinessRepository.setDayHours` | Horarios | 2 | ⏳ |
| 14 | `GET /availability` | agenda | `ReservationRepository.getAvailability` | Reservar | 2 | ⏳ |
| 15 | `POST /reservations` | agenda | `ReservationRepository.create` | Reservar | 2 | ⏳ |
| 16 | `GET /reservations/me` | agenda | `ReservationRepository.getMyReservations` | Reservas, Perfil (contadores) | 2 | ⏳ |
| 17 | `GET /reservations/:id` | agenda | `ReservationRepository.getById` | Confirmación (enlace directo) | 2 | ⏳ |
| 18 | `POST /reservations/:id/cancel` | agenda | `ReservationRepository.cancel` | Reservas | 2 | ⏳ |
| 19 | `GET /reservations/business` | agenda | `ReservationRepository.getBusinessReservations` | Agenda (empresa) | 2 | ⏳ |
| 20 | `PATCH /reservations/:id/status` | agenda | _(sin UI todavía)_ | Agenda (empresa) | 2 | ⏳ |
| 21 | `GET /discover/businesses` | descubrimiento | `BusinessRepository.search` | Explorar | 3 | ⏳ |
| 22 | `GET /discover/nearby` | descubrimiento | `BusinessRepository.getNearby` | Explorar ("Cerca de ti") | 3 | ⏳ |
| 23 | `GET /discover/businesses/:id` | descubrimiento | `BusinessRepository.getById` | Detalle de negocio, Reservar | 3 | ⏳ |
| 24 | `GET /favorites` | descubrimiento | `FavoritesRepository.getFavorites` / `isFavorite` | Guardados, Perfil (contador) | 3 | ⏳ |
| 25 | `PUT /favorites/:businessId` | descubrimiento | `FavoritesRepository.add` | Detalle de negocio | 3 | ⏳ |
| 26 | `DELETE /favorites/:businessId` | descubrimiento | `FavoritesRepository.remove` | Detalle, Guardados | 3 | ⏳ |
| 27 | `GET /notifications/preferences` | notificaciones | `NotificationsRepository.getPreferences` | Notificaciones | 4 | ⏳ |
| 28 | `PATCH /notifications/preferences` | notificaciones | `NotificationsRepository.updatePreferences` | Notificaciones | 4 | ⏳ |
| 29 | `POST /notifications/tokens` | notificaciones | _(pendiente en app: FCM, P3)_ | — | 4 | ⏳ |
| 30 | `DELETE /notifications/tokens/:token` | notificaciones | _(pendiente en app: al cerrar sesión)_ | — | 4 | ⏳ |
| 31 | `GET /clients` | clientes | `ClientsRepository.getClients` | Clientes (empresa), Perfil del negocio | 5 | ⏳ |
| 32 | `GET /clients/:clientId/reservations` | clientes | `ClientsRepository.getClientHistory` | Detalle de cliente | 5 | ⏳ |

**Sin endpoint propio (los resuelve Firebase Auth desde la app):** iniciar sesión, cerrar sesión, recuperar contraseña y cambiar contraseña (`AuthRepository.login/logout/sendPasswordReset/changePassword`). Ver §3.

**Pantallas estáticas, sin backend:** Métodos de pago (stub), Privacidad, Términos, Ayuda.

---

## 3. Autenticación y perfil — auth-service

### Flujos que la app resuelve con Firebase

| Acción | App | Backend |
|---|---|---|
| Registro (1.1) | `createUserWithEmailAndPassword` → `POST /auth/register` | ✅ ya existe e idempotente |
| Login (1.2) | `signInWithEmailAndPassword` → `GET /users/me` | si responde `403 USER_NOT_REGISTERED`, la app manda a completar el registro |
| Restaurar sesión (1.3) | Firebase persiste la sesión; al abrir, `GET /users/me` | — |
| Cerrar sesión (1.3) | `signOut` (+ `DELETE /notifications/tokens/:token` cuando exista FCM) | — |
| Recuperar contraseña (1.4) | `sendPasswordResetEmail` | — |
| Cambiar contraseña (7.1) | `reauthenticateWithCredential` + `updatePassword` | — |

### `PATCH /users/me` ⏳

Edita el perfil propio (Req 7.1) y la ciudad por defecto (Req 5.3).

```json
// Request (todos opcionales, al menos uno)
{ "name": "María García", "phone": "+52 777 234 5678", "defaultCity": "cuernavaca" }
```

- Validaciones: las mismas de `RegisterDto` para `name` y `phone`; `defaultCity` debe existir en el catálogo de municipios (slug) o ser `null`.
- Respuesta `200`: `UserResponseDto` (el mismo de `GET /users/me`).
- El **correo no se edita aquí**: lo controla Firebase (`verifyBeforeUpdateEmail`). Al cambiar en Firebase, el backend debe sincronizarlo desde `x-user-email` (p. ej. en `GET /users/me`). _Decisión pendiente para la app:_ hoy "Información personal" deja escribir el correo; habrá que volverlo de solo lectura o pasar por Firebase.

---

## 4. Catálogos y negocio propio — negocios-service

### `GET /catalogs/categories` ⏳ · `GET /catalogs/municipalities` ⏳

```json
{ "data": [ { "slug": "peluqueria", "displayName": "Peluquería", "iconHint": "content_cut", "position": 1 } ] }
{ "data": [ { "slug": "cuernavaca", "displayName": "Cuernavaca", "state": "Morelos" } ] }
```

Ordenados por `position` / `displayName`. La app agrega "Todos" a las categorías por su cuenta. Son datos semilla de la migración (guía §7, regla 7).

### `POST /businesses` ⏳ — registrar mi negocio (Req 2.1)

```json
{
  "name": "Estudio María",
  "category": "peluqueria",
  "description": "Peluquería y color editorial con enfoque natural.",
  "phone": "+52 777 456 7890",
  "address": "Av. Álvaro Obregón 320",
  "municipality": "cuernavaca"
}
```

- `201` → `MyBusiness` (§10). Genera `deepLinkCode` único e inmutable (p. ej. `estudio-maria-x7k2`).
- `409 BUSINESS_ALREADY_EXISTS` si el usuario ya tiene negocio (`UNIQUE(owner_id)`). Reintentar con el mismo usuario no debe crear otro.
- `400` si `category`/`municipality` no existen en el catálogo.
- Latitud/longitud: se pueden calcular con la API de geocodificación (F3) a partir de `address` + `municipality`; mientras no exista, quedan `null`.

### `GET /businesses/me` ⏳

- `200` → `MyBusiness` con sus servicios activos.
- `404 BUSINESS_NOT_FOUND` si el usuario aún no tiene negocio. **La app lo interpreta como "sin negocio"** (muestra el banner "Registra tu negocio"), así que debe ser exactamente ese `code`.
- `weeklyHours` no viene aquí: la app lo completa con `GET /schedule/hours` (agenda-service es dueño de los horarios).

### `PATCH /businesses/me` ⏳ — editar perfil del negocio (Req 2.2, 2.3)

Campos opcionales: `name`, `category`, `description`, `phone`, `address`, `municipality`, `heroImageUrl`. `200` → `MyBusiness`.

- La foto (2.3) la sube la app a **Firebase Storage** (`businesses/{businessId}/…`, con `storage.rules` por propietario) y aquí solo se guarda la URL.
- `deepLinkCode` no se puede cambiar.

### Servicios del negocio (Req 2.4) ⏳

| Ruta | Body | Respuesta |
|---|---|---|
| `POST /businesses/me/services` | `{ "name", "description", "durationMinutes", "price": "300.00" }` | `201` → `Service` |
| `PATCH /businesses/me/services/:serviceId` | mismos campos, opcionales | `200` → `Service` |
| `DELETE /businesses/me/services/:serviceId` | — | `204` (idempotente) |

- Validación: `name` 2–120, `description` ≤ 500, `durationMinutes` entero 1–600, `price` ≥ 0 con 2 decimales.
- `serviceId` que no es del negocio del usuario → `404 SERVICE_NOT_FOUND`.
- **Borrado lógico** (`is_active = false`): `reservations.service_id` lo referencia y el historial debe seguir mostrando el nombre.

---

## 5. Disponibilidad, reservas y horarios — agenda-service

> Rutas estáticas (`/reservations/me`, `/reservations/business`) se declaran **antes** que `/reservations/:id` (que usa `ParseUUIDPipe`), igual que se hace con `/test` (guía §3).

### `GET /schedule/hours` ⏳ — horario semanal de mi negocio (Req 3.1)

```json
{ "data": [
  { "dayOfWeek": 0, "isOpen": true,  "openTime": "10:00", "closeTime": "20:00" },
  { "dayOfWeek": 6, "isOpen": false, "openTime": null,    "closeTime": null }
] }
```

- Siempre 7 elementos (0–6). Si el negocio aún no tiene filas, se devuelve la plantilla por defecto que usa la app hoy: lun–vie 10:00–20:00, sáb 11:00–18:00, dom cerrado. Así negocios-service **no** necesita llamar a agenda al registrar un negocio.
- El negocio se resuelve por `ownerId` (interno a negocios-service, §9). Sin negocio → `404 BUSINESS_NOT_FOUND`.

### `PUT /schedule/hours/:dayOfWeek` ⏳

Body `{ "isOpen": true, "openTime": "10:00", "closeTime": "20:00" }` → `200` con el día. Upsert (idempotente). `400` si `openTime >= closeTime` o faltan horas con `isOpen: true`.

### `GET /availability?businessId=&serviceId=&date=YYYY-MM-DD` ⏳ (Req 3.2)

```json
{
  "date": "2026-11-06",
  "slots": [
    { "start": "2026-11-06T15:00:00.000Z", "end": "2026-11-06T15:45:00.000Z", "available": true },
    { "start": "2026-11-06T15:45:00.000Z", "end": "2026-11-06T16:30:00.000Z", "available": false }
  ]
}
```

- Cálculo (modelo de datos §3): horario recurrente del día → aplicar `business_hour_exceptions` → restar reservas `pending`/`confirmed` que se traslapan con `[start, start + duración del servicio)`.
- Paso entre horarios: duración del servicio (o 15 min; decidir y documentar). Los horarios ya pasados del día actual van `available: false`.
- La app muestra la lista completa y tacha los no disponibles; si se prefiere devolver solo los libres, avisar para ajustar la UI.
- `404` si el negocio o el servicio no existen o el servicio no es de ese negocio. `date` fuera de los próximos 14 días → `400`.

### `POST /reservations` ⏳ — crear reserva (Req 3.3)

```json
{ "businessId": "uuid", "serviceId": "uuid", "scheduledAt": "2026-11-06T15:00:00.000Z" }
```

- `201` → `Reservation` (§10) con `status: "confirmed"`.
- Valida, consultando a negocios (§9), que el servicio pertenece al negocio y está activo; **congela** `durationMinutes` y `priceAtBooking`.
- `400 OUTSIDE_BUSINESS_HOURS` si cae fuera del horario o en el pasado.
- `409 RESERVATION_OVERLAP` si el `EXCLUDE` rechaza el traslape. La app, al recibir este `code`, recarga la disponibilidad.
- **Idempotente** (guía §6.6): si el traslape es con una reserva del **mismo cliente, mismo servicio y misma hora**, devolver esa reserva con `200`.

### `GET /reservations/me` ⏳ — mis reservas como cliente

`{ "data": [Reservation] }` del usuario (`client_id = userId`), todas las de estado. La app separa "Próximas" (`pending`/`confirmed` futuras) e "Historial" y calcula los contadores del perfil. Si crece mucho, agregar `?scope=upcoming|history` y paginación.

### `GET /reservations/:id` ⏳

`200` → `Reservation` si el usuario es el cliente **o** el propietario del negocio; si no, `404 RESERVATION_NOT_FOUND`.

### `POST /reservations/:id/cancel` ⏳ (Req 3.4)

Body opcional `{ "reason": "…" }` (≤ 240). `200` → `Reservation` con `status: "cancelled"` y `cancelledAt`.

- Puede cancelar el cliente dueño o el propietario del negocio.
- Ya cancelada → `200` con la misma reserva (idempotente). `completed`/`no_show` → `409 RESERVATION_NOT_CANCELLABLE`.

### `GET /reservations/business?from=&to=` ⏳ — agenda de mi negocio (Req 3.4)

`from`/`to` en ISO UTC, rango `[from, to)` de máximo 31 días. `{ "data": [Reservation] }` del negocio del usuario, **con `client`** (nombre, correo, teléfono) y ordenadas por `scheduledAt`. Sin negocio → `404 BUSINESS_NOT_FOUND`.

### `PATCH /reservations/:id/status` ⏳ — marcar completada / no asistió

Body `{ "status": "completed" | "no_show" }`, solo el propietario. Al pasar a `completed`, agenda avisa a clientes-service (§9) para actualizar `client_business_links`.

> ⚠️ La app todavía **no tiene botón** para esto, pero sin él ninguna reserva llega a `completed` y el directorio de clientes (§7) queda vacío con datos reales. Alternativa: un job que marque como `completed` las reservas confirmadas ya pasadas. **Decidir en equipo.**

---

## 6. Exploración y favoritos — descubrimiento-service

Descubrimiento arma las vistas que lee el **cliente**: consulta negocios por HTTP interno, calcula distancia y agrega favoritos (guía §1). Los campos que vienen de otros servicios (`rating`, `todayHours`) pueden llegar `null` en una primera versión; la app usa valores por defecto.

### `GET /discover/businesses?q=&category=&municipality=&lat=&lng=&page=1&pageSize=20` ⏳ (Req 5.1)

- `q`: busca en nombre, categoría y municipio/colonia (`pg_trgm`, en negocios-service vía interno). `category` y `municipality` son slugs.
- `lat`/`lng` opcionales (ubicación del dispositivo, P2): si vienen, se llena `distanceKm`.
- `200` → `PaginatedResponse<BusinessSummary>`. Solo negocios activos y no borrados.

### `GET /discover/nearby?lat=&lng=&limit=4` ⏳ (Req 5.3)

`{ "data": [BusinessSummary] }` ordenados por distancia. Sin `lat`/`lng`, se usa el `defaultCity` del usuario (filtra por municipio) y `distanceKm: null`.

### `GET /discover/businesses/:id?lat=&lng=` ⏳ (Req 5.2, 2.2 lectura)

`200` → `BusinessDetail` (§10): datos públicos, servicios activos, galería, horario de hoy, valoración y si es favorito del usuario. Inactivo/borrado → `404 BUSINESS_NOT_FOUND`. Lo usan Detalle y Reservar.

### Favoritos ⏳

| Ruta | Respuesta |
|---|---|
| `GET /favorites` | `{ "data": [BusinessSummary] }` del usuario, más recientes primero |
| `PUT /favorites/:businessId` | `204`. **Idempotente** (si ya existe, `204`; `P2002` no es error). `404` si el negocio no existe |
| `DELETE /favorites/:businessId` | `204`. **Idempotente** (si no existía, `204`) |

Se usa `PUT`/`DELETE` sobre el recurso (no un "toggle") para que el reintento tras un corte de red sea seguro.

---

## 7. Directorio de clientes — clientes-service

Solo el propietario, y solo clientes con al menos una reserva en su negocio (guía §8.3).

### `GET /clients?q=` ⏳ (Req 4.1)

```json
{ "data": [ {
  "clientId": "uuid", "name": "Laura Pérez", "email": "laura@correo.com", "phone": "+52 777 345 1122",
  "totalVisits": 2, "totalSpent": "640.00", "firstVisitAt": "…", "lastVisitAt": "…"
} ] }
```

- Sale de `client_business_links`; nombre/correo/teléfono se piden a auth (§9). Orden: `lastVisitAt` descendente. `q` filtra por nombre o correo.
- La app hoy también cuenta clientes con reservas **futuras** (aún sin `completed`). Si el backend solo lista vínculos por reservas completadas, el directorio de un negocio nuevo saldrá vacío. Es correcto según el modelo, pero conviene saberlo al probar.

### `GET /clients/:clientId/reservations` ⏳ (Req 4.2)

`{ "data": [Reservation] }` de ese cliente **en mi negocio**, más recientes primero (compuesto desde agenda, §9). Si `clientId` no tiene reservas en mi negocio → `404 CLIENT_NOT_FOUND`.

---

## 8. Preferencias y tokens — notificaciones-service

### `GET /notifications/preferences` ⏳ · `PATCH /notifications/preferences` ⏳ (Req 6.1, 7.3)

```json
{ "reminders": true, "promos": false, "news": true }
```

`GET` devuelve los valores por defecto si el usuario no tiene fila. `PATCH` acepta cualquier subconjunto y responde el objeto completo. La app guarda de forma optimista y revierte si falla.

### `POST /notifications/tokens` ⏳ · `DELETE /notifications/tokens/:token` ⏳

`POST` con body `{ "token": "<FCM>", "platform": "android" | "ios" | "web" }` → `204`, upsert por token (idempotente). `DELETE` al cerrar sesión. La app aún no integra FCM (P3), pero los recordatorios de 6.1 dependen de esto.

---

## 9. Endpoints internos que hacen falta

Protegidos por `x-internal-token`, nunca expuestos por el gateway (guía §9). Siempre en **lote** para evitar N+1.

| Dueño | Ruta interna | Lo usa | Para |
|---|---|---|---|
| auth | `GET /internal/users?ids=a,b,c` | agenda, clientes | `client` en reservas del negocio y directorio |
| negocios | `GET /internal/businesses/by-owner/:ownerId` | agenda, clientes | resolver "mi negocio" |
| negocios | `GET /internal/businesses?ids=…` | agenda, descubrimiento | `business` resumido en reservas y favoritos |
| negocios | `GET /internal/businesses/:id` (con servicios) | agenda, descubrimiento | validar servicio al reservar; detalle |
| negocios | `GET /internal/businesses/search?q=&category=&municipality=` | descubrimiento | búsqueda |
| agenda | `GET /internal/schedule/:businessId/today` | descubrimiento | `todayHours` del detalle |
| agenda | `GET /internal/reservations?businessId=&clientId=` | clientes | historial del cliente (4.2) |
| clientes | `POST /internal/client-links/visits` | agenda | al completar una reserva (4.1) |
| clientes | `GET /internal/ratings/summary?businessIds=…` | descubrimiento | `rating` (opcional en fase 1) |

---

## 10. Objetos JSON compartidos

Propuesta para `@backend/contracts` (tipos de respuesta). Entre paréntesis, el campo del modelo Dart que llena.

**`BusinessSummary`**: tarjetas de Explorar, Cerca de ti y Guardados.
```json
{
  "id": "uuid", "name": "Casa Bella", "category": "Peluquería",
  "municipality": "Cuernavaca", "address": "Av. Reforma 123, Cuernavaca",
  "description": "Color editorial y cortes de autor.",     // tagline
  "heroImageUrl": "https://…",                              // heroImage
  "rating": { "average": 4.9, "count": 182 },               // rating, reviews (null → 0)
  "distanceKm": 0.6                                         // null sin ubicación
}
```

**`BusinessDetail`** = `BusinessSummary` + 
```json
{
  "phone": "+52 777 123 4567",
  "gallery": ["https://…"],                                  // business_images por position
  "todayHours": { "isOpen": true, "openTime": "09:00", "closeTime": "20:00" },  // openHours
  "isFavorite": true,
  "services": [Service]
}
```

**`Service`**
```json
{ "id": "uuid", "name": "Corte & lavado", "description": "…", "durationMinutes": 45, "price": "320.00" }
```

**`MyBusiness`**
```json
{
  "id": "uuid", "name": "…", "category": "peluqueria", "description": "…", "phone": "…",
  "address": "…", "municipality": "cuernavaca", "heroImageUrl": "https://…" ,
  "deepLinkCode": "estudio-maria-x7k2", "isActive": true, "services": [Service]
}
```
La app arma el QR con `https://citalis.app/n/{deepLinkCode}`.

**`Reservation`**
```json
{
  "id": "uuid",
  "status": "confirmed",                     // pending | confirmed | completed | cancelled | no_show
  "scheduledAt": "2026-11-06T15:00:00.000Z", // when
  "durationMinutes": 45,
  "priceAtBooking": "320.00",
  "cancelledAt": null,
  "business": { "id": "uuid", "name": "Casa Bella", "address": "…", "heroImageUrl": "https://…" },
  "service": { "id": "uuid", "name": "Corte & lavado" },
  "client": { "id": "uuid", "name": "…", "email": "…", "phone": "…" }   // solo para el propietario; null para el cliente
}
```

---

## 11. Diferencias entre la app y el modelo de datos

Puntos que se resuelven en la capa remota de la app (mapper JSON → modelo), sin cambiar la UI. Conviene conocerlos al implementar:

| Tema | App hoy | Backend | Cómo se concilia |
|---|---|---|---|
| Estados de reserva | `upcoming`, `completed`, `cancelled` | `pending`, `confirmed`, `completed`, `cancelled`, `no_show` | `pending`/`confirmed` → `upcoming`; `no_show` → historial (la app agregará su chip) |
| Precio | `double` | string `"320.00"` | se parsea en el mapper |
| Categoría y municipio | texto visible (`"Peluquería"`) | slug + `displayName` | se envía el slug y se muestra `displayName` |
| Horario de hoy | texto `"Hoy · 09:00 — 20:00"` | `todayHours` estructurado | la app lo formatea |
| Colonia (`neighborhood`) | se muestra en tarjetas | no existe columna | se usa `municipality`; si hace falta, agregar columna en negocios (migración nueva) |
| Teléfono del negocio | `Business.phone` | `businesses.phone` | directo |
| Precio/duración en reservas | toma los del servicio actual | congelados (`priceAtBooking`) | la app debe mostrar los congelados |
| Contraseña / correo | pantallas propias | Firebase | sin endpoint (§3) |
