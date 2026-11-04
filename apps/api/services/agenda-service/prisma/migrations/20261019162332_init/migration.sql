-- Schema propio del servicio (Prisma no lo emite por sí mismo).
CREATE SCHEMA IF NOT EXISTS "agenda";

-- CreateExtension
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- CreateEnum
CREATE TYPE "agenda"."reservation_status" AS ENUM ('pending', 'confirmed', 'completed', 'cancelled', 'no_show');

-- CreateTable
CREATE TABLE "agenda"."business_hours" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "business_id" UUID NOT NULL,
    "day_of_week" SMALLINT NOT NULL,
    "is_open" BOOLEAN NOT NULL DEFAULT true,
    "open_time" TIME(6),
    "close_time" TIME(6),

    CONSTRAINT "business_hours_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "agenda"."business_hour_exceptions" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "business_id" UUID NOT NULL,
    "date" DATE NOT NULL,
    "is_closed" BOOLEAN NOT NULL DEFAULT true,
    "open_time" TIME(6),
    "close_time" TIME(6),
    "reason" VARCHAR(240),

    CONSTRAINT "business_hour_exceptions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "agenda"."reservations" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "business_id" UUID NOT NULL,
    "service_id" UUID NOT NULL,
    "client_id" UUID NOT NULL,
    "scheduled_at" TIMESTAMPTZ NOT NULL,
    "duration_minutes" INTEGER NOT NULL,
    "price_at_booking" DECIMAL(10,2) NOT NULL,
    "status" "agenda"."reservation_status" NOT NULL DEFAULT 'confirmed',
    "notes" TEXT,
    "cancelled_at" TIMESTAMPTZ,
    "cancellation_reason" VARCHAR(240),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "reservations_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "business_hours_business_id_day_of_week_key" ON "agenda"."business_hours"("business_id", "day_of_week");

-- CreateIndex
CREATE UNIQUE INDEX "business_hour_exceptions_business_id_date_key" ON "agenda"."business_hour_exceptions"("business_id", "date");

-- CreateIndex
CREATE INDEX "reservations_business_id_scheduled_at_idx" ON "agenda"."reservations"("business_id", "scheduled_at");

-- CreateIndex
CREATE INDEX "reservations_client_id_scheduled_at_idx" ON "agenda"."reservations"("client_id", "scheduled_at" DESC);

-- CreateIndex
CREATE INDEX "reservations_status_idx" ON "agenda"."reservations"("status");

-- Mantiene updated_at también ante UPDATEs hechos fuera de Prisma (convención del modelo de datos).
CREATE OR REPLACE FUNCTION "agenda".set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_reservations_updated BEFORE UPDATE ON "agenda"."reservations"
  FOR EACH ROW EXECUTE FUNCTION "agenda".set_updated_at();

-- Horarios válidos (Req 3.1: la hora de cierre es posterior a la de apertura).
ALTER TABLE "agenda"."business_hours"
  ADD CONSTRAINT business_hours_day_valid CHECK (day_of_week BETWEEN 0 AND 6),
  ADD CONSTRAINT business_hours_valid CHECK (
    NOT is_open OR (open_time IS NOT NULL AND close_time IS NOT NULL AND close_time > open_time)
  );

ALTER TABLE "agenda"."business_hour_exceptions"
  ADD CONSTRAINT business_hour_exceptions_valid CHECK (
    is_closed OR (open_time IS NOT NULL AND close_time IS NOT NULL AND close_time > open_time)
  );

ALTER TABLE "agenda"."reservations"
  ADD CONSTRAINT reservations_duration_valid CHECK (duration_minutes > 0),
  ADD CONSTRAINT reservations_price_valid CHECK (price_at_booking >= 0);

-- Protección definitiva contra doble reserva (Req 3.3 y 6.3): la propia base impide que dos
-- reservas pendientes/confirmadas del mismo negocio traslapen su franja, aun con peticiones
-- simultáneas o reintentos. El servicio traduce la violación (23P01) a 409 RESERVATION_OVERLAP.
-- El rango se calcula en UTC con tsrange: `timestamptz + interval` es STABLE (depende de la zona
-- horaria de la sesión) y PostgreSQL exige expresiones IMMUTABLE en índices/restricciones.
ALTER TABLE "agenda"."reservations"
  ADD CONSTRAINT no_overlap_reservations
  EXCLUDE USING gist (
    business_id WITH =,
    tsrange(
      (scheduled_at AT TIME ZONE 'UTC'),
      (scheduled_at AT TIME ZONE 'UTC') + (duration_minutes * INTERVAL '1 minute')
    ) WITH &&
  ) WHERE (status IN ('pending', 'confirmed'));
