-- Schema propio del servicio (Prisma no lo emite por sí mismo).
CREATE SCHEMA IF NOT EXISTS "notificaciones";

-- CreateEnum
CREATE TYPE "notificaciones"."notification_platform" AS ENUM ('ios', 'android', 'web');

-- CreateTable
CREATE TABLE "notificaciones"."notification_preferences" (
    "user_id" UUID NOT NULL,
    "reminders" BOOLEAN NOT NULL DEFAULT true,
    "promos" BOOLEAN NOT NULL DEFAULT false,
    "news" BOOLEAN NOT NULL DEFAULT true,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notification_preferences_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "notificaciones"."notification_tokens" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "user_id" UUID NOT NULL,
    "platform" "notificaciones"."notification_platform" NOT NULL,
    "token" TEXT NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "last_used_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notification_tokens_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE INDEX "notification_tokens_user_id_idx" ON "notificaciones"."notification_tokens"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "notification_tokens_user_id_token_key" ON "notificaciones"."notification_tokens"("user_id", "token");

-- Mantiene updated_at también ante UPDATEs hechos fuera de Prisma (convención del modelo de datos).
CREATE OR REPLACE FUNCTION "notificaciones".set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_notification_preferences_updated BEFORE UPDATE ON "notificaciones"."notification_preferences"
  FOR EACH ROW EXECUTE FUNCTION "notificaciones".set_updated_at();
