-- ============================================================================
-- Citalis · Esquema de base de datos
-- PostgreSQL 15+
-- ----------------------------------------------------------------------------
-- Cubre los módulos definidos en docs/historias-de-usuario.md:
--   1. Cuenta y seguridad          6. Notificaciones y conectividad
--   2. Negocio y servicios         7. Perfil, privacidad y configuración
--   3. Agenda y reservas
--   4. Clientes y seguimiento
--   5. Ubicación y descubrimiento
-- ============================================================================

BEGIN;

-- ---------------------------------------------------------------------------
-- Extensiones
-- ---------------------------------------------------------------------------
CREATE EXTENSION IF NOT EXISTS "pgcrypto";   -- gen_random_uuid()
CREATE EXTENSION IF NOT EXISTS "citext";     -- correos case-insensitive
-- CREATE EXTENSION IF NOT EXISTS "postgis"; -- habilitar cuando se requiera geo real

-- ---------------------------------------------------------------------------
-- Tipos enumerados
-- ---------------------------------------------------------------------------
CREATE TYPE reservation_status AS ENUM (
  'pending',
  'confirmed',
  'completed',
  'cancelled',
  'no_show'
);

CREATE TYPE notification_platform AS ENUM ('ios', 'android', 'web');

-- ---------------------------------------------------------------------------
-- Función reutilizable para mantener updated_at
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ===========================================================================
-- MÓDULO 1 · CUENTA Y SEGURIDAD
-- Req 1.1 Registro · 1.2 Login · 1.3 Sesión · 1.4 Recuperación
-- ===========================================================================

CREATE TABLE users (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email           CITEXT NOT NULL UNIQUE,
  firebase_uid    VARCHAR(128) UNIQUE,  -- si se delega auth a Firebase
  name            VARCHAR(120) NOT NULL,
  phone           VARCHAR(20),
  default_city    VARCHAR(80),           -- Req 5.3 ubicación manual
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ            -- soft delete
);

CREATE TRIGGER trg_users_updated BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_users_firebase_uid ON users(firebase_uid) WHERE firebase_uid IS NOT NULL;
CREATE INDEX idx_users_deleted ON users(deleted_at) WHERE deleted_at IS NULL;

-- Preferencias de notificaciones (Req 6.1 · 7.3)
CREATE TABLE notification_preferences (
  user_id         UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  reminders       BOOLEAN NOT NULL DEFAULT TRUE,
  promos          BOOLEAN NOT NULL DEFAULT FALSE,
  news            BOOLEAN NOT NULL DEFAULT TRUE,
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_notif_prefs_updated BEFORE UPDATE ON notification_preferences
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Tokens FCM por dispositivo (Req 6.1)
CREATE TABLE notification_tokens (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  platform        notification_platform NOT NULL,
  token           TEXT NOT NULL,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  last_used_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (user_id, token)
);

CREATE INDEX idx_notif_tokens_user ON notification_tokens(user_id);

-- ===========================================================================
-- MÓDULO 2 · NEGOCIO Y SERVICIOS
-- Req 2.1 Registro · 2.2 Administración · 2.3 Imagen · 2.4 Servicios · 2.5 QR
-- ===========================================================================

CREATE TABLE businesses (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id        UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  name            VARCHAR(120) NOT NULL,
  category        VARCHAR(60) NOT NULL,
  description     TEXT NOT NULL,
  phone           VARCHAR(20) NOT NULL,
  address         VARCHAR(240) NOT NULL,
  municipality    VARCHAR(80) NOT NULL,
  hero_image_url  TEXT,
  deep_link_code  VARCHAR(32) NOT NULL UNIQUE,  -- usado en el QR (Req 2.5 · 3.5)
  latitude        DOUBLE PRECISION,              -- Req 5.2 · 5.3
  longitude       DOUBLE PRECISION,
  is_active       BOOLEAN NOT NULL DEFAULT TRUE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at      TIMESTAMPTZ,
  CONSTRAINT one_business_per_owner UNIQUE (owner_id)
);

CREATE TRIGGER trg_businesses_updated BEFORE UPDATE ON businesses
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_businesses_category ON businesses(category) WHERE deleted_at IS NULL;
CREATE INDEX idx_businesses_municipality ON businesses(municipality) WHERE deleted_at IS NULL;
CREATE INDEX idx_businesses_name_trgm ON businesses USING gin (name gin_trgm_ops);  -- búsqueda fuzzy
-- Habilitar la extensión pg_trgm si se usa el índice anterior:
-- CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Galería de fotos adicionales (Req 2.3)
CREATE TABLE business_images (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id     UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  url             TEXT NOT NULL,
  position        SMALLINT NOT NULL DEFAULT 0,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_business_images_business ON business_images(business_id, position);

-- Servicios ofrecidos (Req 2.4)
CREATE TABLE services (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id       UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  name              VARCHAR(120) NOT NULL,
  description       TEXT NOT NULL DEFAULT '',
  duration_minutes  INTEGER NOT NULL CHECK (duration_minutes > 0 AND duration_minutes <= 600),
  price             NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  is_active         BOOLEAN NOT NULL DEFAULT TRUE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_services_updated BEFORE UPDATE ON services
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE INDEX idx_services_business_active ON services(business_id) WHERE is_active;

-- ===========================================================================
-- MÓDULO 3 · AGENDA Y RESERVAS
-- Req 3.1 Horarios · 3.2 Disponibilidad · 3.3 Reserva · 3.4 Administración · 3.5 QR
-- ===========================================================================

-- Horario semanal recurrente del negocio (Req 3.1)
CREATE TABLE business_hours (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id     UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  day_of_week     SMALLINT NOT NULL CHECK (day_of_week BETWEEN 0 AND 6), -- 0=lunes
  is_open         BOOLEAN NOT NULL DEFAULT TRUE,
  open_time       TIME,
  close_time      TIME,
  CONSTRAINT valid_hours CHECK (
    NOT is_open OR (open_time IS NOT NULL AND close_time IS NOT NULL AND close_time > open_time)
  ),
  UNIQUE (business_id, day_of_week)
);

-- Excepciones puntuales (días cerrados por feriado, horarios especiales)
CREATE TABLE business_hour_exceptions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id     UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  date            DATE NOT NULL,
  is_closed       BOOLEAN NOT NULL DEFAULT TRUE,
  open_time       TIME,
  close_time      TIME,
  reason          VARCHAR(240),
  UNIQUE (business_id, date)
);

-- Reservas (Req 3.3 · 3.4)
CREATE TABLE reservations (
  id                     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  business_id            UUID NOT NULL REFERENCES businesses(id) ON DELETE RESTRICT,
  service_id             UUID NOT NULL REFERENCES services(id) ON DELETE RESTRICT,
  client_id              UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  scheduled_at           TIMESTAMPTZ NOT NULL,
  duration_minutes       INTEGER NOT NULL CHECK (duration_minutes > 0),
  price_at_booking       NUMERIC(10,2) NOT NULL CHECK (price_at_booking >= 0),
  status                 reservation_status NOT NULL DEFAULT 'confirmed',
  notes                  TEXT,
  cancelled_at           TIMESTAMPTZ,
  cancellation_reason    VARCHAR(240),
  created_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at             TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TRIGGER trg_reservations_updated BEFORE UPDATE ON reservations
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- Índices críticos para consultas de agenda e historial
CREATE INDEX idx_reservations_business_time ON reservations(business_id, scheduled_at);
CREATE INDEX idx_reservations_client_time   ON reservations(client_id, scheduled_at DESC);
CREATE INDEX idx_reservations_status        ON reservations(status) WHERE status IN ('pending','confirmed');

-- Evita doble reserva en la misma franja para el mismo negocio
-- (requiere btree_gist)
CREATE EXTENSION IF NOT EXISTS btree_gist;
ALTER TABLE reservations ADD CONSTRAINT no_overlap_reservations
  EXCLUDE USING gist (
    business_id WITH =,
    tstzrange(scheduled_at, scheduled_at + (duration_minutes * INTERVAL '1 minute')) WITH &&
  ) WHERE (status IN ('pending','confirmed'));

-- ===========================================================================
-- MÓDULO 4 · CLIENTES Y SEGUIMIENTO
-- Req 4.1 Vinculación · 4.2 Historial · 4.3 Valoración
-- ===========================================================================

-- Vinculación materializada cliente-negocio (Req 4.1)
-- Se puede derivar vía SQL, pero esta tabla acelera las consultas del dashboard empresa.
CREATE TABLE client_business_links (
  user_id           UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  business_id       UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  first_visit_at    TIMESTAMPTZ NOT NULL,
  last_visit_at     TIMESTAMPTZ NOT NULL,
  total_visits      INTEGER NOT NULL DEFAULT 0,
  total_spent       NUMERIC(12,2) NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id, business_id)
);

CREATE INDEX idx_client_links_business ON client_business_links(business_id, last_visit_at DESC);

-- Valoraciones post-cita (Req 4.3)
CREATE TABLE ratings (
  reservation_id    UUID PRIMARY KEY REFERENCES reservations(id) ON DELETE CASCADE,
  business_id       UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  client_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  rating            SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment           TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ratings_business ON ratings(business_id, created_at DESC);

-- ===========================================================================
-- MÓDULO 5 · UBICACIÓN Y DESCUBRIMIENTO
-- Req 5.1 Búsqueda · 5.2 Mapa · 5.3 Cercanos
-- ===========================================================================

-- Favoritos del cliente (soporta "Guardados" en la app)
CREATE TABLE favorites (
  user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  business_id     UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, business_id)
);

CREATE INDEX idx_favorites_user ON favorites(user_id);

-- Catálogo de categorías para selectores consistentes
CREATE TABLE business_categories (
  slug            VARCHAR(60) PRIMARY KEY,
  display_name    VARCHAR(80) NOT NULL,
  icon_hint       VARCHAR(60),
  position        SMALLINT NOT NULL DEFAULT 0
);

INSERT INTO business_categories (slug, display_name, position) VALUES
  ('peluqueria',       'Peluquería',        1),
  ('unas',             'Uñas',              2),
  ('spa',              'Spa',               3),
  ('barberia',         'Barbería',          4),
  ('cejas-pestanas',   'Cejas & Pestañas',  5),
  ('wellness',         'Wellness',          6),
  ('masajes',          'Masajes',           7),
  ('depilacion',       'Depilación',        8);

-- Catálogo de municipios (expandible)
CREATE TABLE municipalities (
  slug            VARCHAR(60) PRIMARY KEY,
  display_name    VARCHAR(80) NOT NULL,
  state           VARCHAR(60) NOT NULL DEFAULT 'Morelos'
);

INSERT INTO municipalities (slug, display_name) VALUES
  ('cuernavaca',       'Cuernavaca'),
  ('jiutepec',         'Jiutepec'),
  ('temixco',          'Temixco'),
  ('yautepec',         'Yautepec'),
  ('emiliano-zapata',  'Emiliano Zapata'),
  ('xochitepec',       'Xochitepec');

-- ===========================================================================
-- MÓDULO 6 · AUDITORÍA (opcional, útil para debugging y métricas internas)
-- ===========================================================================

CREATE TABLE audit_log (
  id              BIGSERIAL PRIMARY KEY,
  user_id         UUID REFERENCES users(id) ON DELETE SET NULL,
  entity          VARCHAR(60) NOT NULL,
  entity_id       UUID,
  action          VARCHAR(60) NOT NULL,
  metadata        JSONB,
  created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_entity ON audit_log(entity, entity_id);
CREATE INDEX idx_audit_user ON audit_log(user_id, created_at DESC);

-- ===========================================================================
-- Vistas útiles
-- ===========================================================================

-- Rating agregado por negocio (para listados y detalle)
CREATE OR REPLACE VIEW v_business_rating AS
SELECT
  r.business_id,
  COUNT(*)::INT       AS reviews_count,
  ROUND(AVG(r.rating)::NUMERIC, 2) AS average_rating
FROM ratings r
GROUP BY r.business_id;

-- Agenda del día para un negocio (muy usada en el dashboard empresa)
CREATE OR REPLACE VIEW v_business_agenda AS
SELECT
  res.id,
  res.business_id,
  res.scheduled_at,
  res.status,
  res.price_at_booking,
  res.duration_minutes,
  svc.name   AS service_name,
  u.name     AS client_name,
  u.email    AS client_email,
  u.phone    AS client_phone
FROM reservations res
JOIN services svc ON svc.id = res.service_id
JOIN users    u   ON u.id   = res.client_id;

COMMIT;

-- ===========================================================================
-- Datos semilla mínimos (opcional, útil para desarrollo)
-- ===========================================================================
-- INSERT INTO users (id, email, name, phone) VALUES
--   (gen_random_uuid(), 'maria@correo.com', 'María García', '+52 777 234 5678');
