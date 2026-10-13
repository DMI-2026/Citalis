# Citalis · Modelo de datos

Documento acompañante del esquema PostgreSQL en [`schema.sql`](schema.sql) y del diagrama entidad-relación en [`citalis-er.drawio`](citalis-er.drawio).

El modelo responde directamente a las historias de usuario definidas en [`../historias-de-usuario.md`](../historias-de-usuario.md), agrupadas en siete módulos.

---

## Convenciones generales

- **PK**: UUID v4 generado por `gen_random_uuid()`. Facilita la migración entre entornos y evita filtrar cardinalidad por ID secuencial.
- **Timestamps**: `created_at` y `updated_at` en todas las tablas de contenido. `updated_at` se mantiene con el trigger `set_updated_at()`.
- **Soft delete**: `deleted_at NULL` para registros activos. Aplica solo a entidades sensibles a historial (usuarios y negocios); el resto cascada o restringe.
- **Normalización**: 3FN con dos excepciones controladas (`client_business_links` y vistas materializadas) para acelerar queries del dashboard empresa.
- **Correos**: `CITEXT` para comparación case-insensitive sin lowercase manual.
- **Timezone**: todos los `TIMESTAMPTZ`. Guardamos en UTC; la zona horaria del usuario se aplica solo en la capa de presentación.

---

## Vista general por dominio

```
┌─ Cuenta y seguridad ──────────────────────────────────────────────────┐
│  users · notification_preferences · notification_tokens               │
└───────────────────────────────────────────────────────────────────────┘
┌─ Negocio y servicios ─────────────────────────────────────────────────┐
│  businesses · business_images · services                              │
│  business_hours · business_hour_exceptions                            │
└───────────────────────────────────────────────────────────────────────┘
┌─ Transacciones (reservas, favoritos, valoraciones) ───────────────────┐
│  reservations · favorites · ratings · client_business_links           │
└───────────────────────────────────────────────────────────────────────┘
┌─ Catálogos ───────────────────────────────────────────────────────────┐
│  business_categories · municipalities                                 │
└───────────────────────────────────────────────────────────────────────┘
┌─ Auditoría ───────────────────────────────────────────────────────────┐
│  audit_log                                                            │
└───────────────────────────────────────────────────────────────────────┘
```

---

## Decisiones de diseño clave

### 1. Una sola cuenta, dos modos operativos

La HU 1.1 pide que cliente y propietario sean el **mismo tipo de cuenta**. En el modelo esto se refleja así:

- `users` es la única tabla de identidad.
- Un usuario *se convierte* en propietario cuando aparece como `owner_id` en `businesses`.
- La restricción `UNIQUE (owner_id)` en `businesses` impone un negocio por propietario (regla del prototipo; si en el futuro se permiten varios, se elimina).

### 2. Firebase Auth opcional

- `users.firebase_uid` es `UNIQUE` pero *nullable*. Permite mezclar cuentas creadas vía Firebase con cuentas administrativas creadas por el backend.
- No almacenamos contraseñas si Firebase gestiona el login. Si se decide hacer auth propia, se añade una tabla `credentials(user_id, password_hash)` y se deja `firebase_uid` en `NULL`.

### 3. Horarios: recurrente + excepciones

- `business_hours`: siete filas por negocio (una por día de la semana), representa la plantilla recurrente.
- `business_hour_exceptions`: filas puntuales que *sobreescriben* el día (feriado, media jornada, cerrado por evento).
- Cálculo de disponibilidad (Req 3.2): se parte del horario recurrente, se aplican excepciones, se restan las franjas de las `reservations` activas.

### 4. Protección contra doble reserva

La `EXCLUDE USING gist` sobre `reservations` evita a nivel de base de datos que dos reservas confirmadas o pendientes del mismo negocio solapen sus franjas temporales. Esta es la mitigación definitiva al "race condition" cuando dos clientes reservan el mismo horario al mismo tiempo (Req 3.3).

```sql
EXCLUDE USING gist (
  business_id WITH =,
  tstzrange(scheduled_at, scheduled_at + duration_minutes * INTERVAL '1 minute') WITH &&
) WHERE (status IN ('pending','confirmed'));
```

### 5. Vinculación cliente-negocio

Aunque técnicamente se puede derivar vía `SELECT DISTINCT client_id FROM reservations WHERE business_id = ?`, mantenemos `client_business_links` como tabla materializada para:

- Mostrar al propietario métricas por cliente (visitas, gasto total, última visita) sin recalcular en cada visita al dashboard.
- Mantenerla actualizada vía trigger o job al cambiar estado de una reserva a `completed`.

Cumple la Req 4.1 y da base a la Req 4.2.

### 6. Precio y duración "congelados" en la reserva

`reservations.price_at_booking` y `duration_minutes` guardan los valores **al momento de reservar**. Si el propietario cambia el precio de un servicio después, el histórico y los reportes no se ven afectados.

### 7. QR y deep link

- `businesses.deep_link_code`: cadena corta e inmutable (ej. `casa-bella-x7k2`) usada en el QR.
- URL final para el QR: `https://citalis.app/n/{deep_link_code}` (Req 2.5 y 3.5).
- Permite rotación del dominio o CDN sin regenerar los QRs ya impresos.

### 8. Geolocalización

- Latitud/longitud en `businesses` como `DOUBLE PRECISION`. Suficiente para distancias en pequeña escala.
- Para búsqueda por radio (Req 5.3), activar `postgis` y crear índice `GIST` sobre un `geography(Point,4326)`.
- Mientras tanto, el ordenamiento por proximidad puede hacerse con la fórmula del coseno en SQL puro (lento con muchos registros, aceptable en MVP).

### 9. Catálogos vs enums

Para **estados fijos del dominio** (`reservation_status`) usamos `ENUM`: menor overhead y validación en la DB.
Para **categorías y municipios** usamos tablas (`business_categories`, `municipalities`) porque son listas que crecen con el producto sin requerir migraciones.

---

## Mapeo HU → tablas

| HU | Tablas involucradas |
|---|---|
| 1.1 Registro de usuario | `users` |
| 1.2 Login | `users` (+ Firebase) |
| 1.3 Sesión | manejada por token, no requiere tabla si se usa Firebase |
| 1.4 Recuperación de contraseña | manejada por Firebase |
| 2.1 Registro de negocio | `businesses` |
| 2.2 Administración de negocio | `businesses` |
| 2.3 Imagen del negocio | `businesses.hero_image_url`, `business_images` |
| 2.4 Administración de servicios | `services` |
| 2.5 QR del negocio | `businesses.deep_link_code` |
| 3.1 Configuración de horarios | `business_hours`, `business_hour_exceptions` |
| 3.2 Consulta de disponibilidad | derivada en query, usa `business_hours`, `business_hour_exceptions`, `reservations` |
| 3.3 Creación de reserva | `reservations` |
| 3.4 Administración de reservas | `reservations` |
| 3.5 Reserva vía QR | `businesses.deep_link_code` + flujo app |
| 4.1 Vinculación de clientes | `client_business_links` |
| 4.2 Historial de citas | `reservations` filtradas por `(business_id, client_id)` |
| 4.3 Valoración del servicio | `ratings` |
| 5.1 Búsqueda de negocios | `businesses` + índices + `pg_trgm` |
| 5.2 Consulta de ubicación | `businesses.latitude`, `businesses.longitude` |
| 5.3 Negocios cercanos | igual que 5.2 + ordenamiento + filtro por `municipalities` |
| 6.1 Recordatorios | `notification_tokens`, `notification_preferences` + jobs programados |
| 6.2 Detección de conexión | cliente (sin tabla) |
| 6.3 Reintento de operaciones | cliente (sin tabla) |
| 7.1 Administración del perfil | `users` |
| 7.2 Configuración de privacidad | contenido estático |
| 7.3 Administración de permisos | `notification_preferences` |

---

## Preguntas abiertas (para refinar antes de implementar)

1. **¿Múltiples negocios por propietario?** El modelo actual lo prohíbe (`UNIQUE (owner_id)`); si en el futuro un propietario tiene varias sucursales se levanta la restricción.
2. **¿Pagos online?** Si se integra Stripe u otro gateway, se añade tabla `payments(reservation_id, provider, provider_id, amount, status, paid_at)` sin tocar `reservations`.
3. **¿Staff dentro del negocio?** El prototipo asume un único "stylist" implícito. Para equipos (varios profesionales dentro del mismo salón) habrá que añadir `staff_members` y asociar `reservations.staff_id`.
4. **¿Multi-idioma?** No contemplado. Si se requiere, los campos `name/description` pasarían a JSONB con locales o a tablas de traducciones.

---

## Cómo correr el script

```bash
# Postgres local
createdb citalis_dev
psql citalis_dev -f docs/db/schema.sql

# Prisma (desde el futuro citalis_api)
# El schema de Prisma se derivará de este SQL con `prisma db pull` tras aplicarlo.
```

El archivo se mantiene como la **fuente canónica** del modelo. Cualquier cambio al esquema debe pasar primero por aquí y luego reflejarse en las migraciones de Prisma.
