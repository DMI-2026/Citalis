-- Schema propio del servicio (Prisma no lo emite por sí mismo).
CREATE SCHEMA IF NOT EXISTS "auth";

-- CreateExtension
CREATE EXTENSION IF NOT EXISTS "citext";

-- CreateTable
CREATE TABLE "auth"."users" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "email" CITEXT NOT NULL,
    "firebase_uid" VARCHAR(128),
    "name" VARCHAR(120) NOT NULL,
    "phone" VARCHAR(20),
    "default_city" VARCHAR(80),
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth"."audit_log" (
    "id" BIGSERIAL NOT NULL,
    "user_id" UUID,
    "entity" VARCHAR(60) NOT NULL,
    "entity_id" UUID,
    "action" VARCHAR(60) NOT NULL,
    "metadata" JSONB,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "audit_log_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "auth"."users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_firebase_uid_key" ON "auth"."users"("firebase_uid");

-- CreateIndex
CREATE INDEX "users_deleted_at_idx" ON "auth"."users"("deleted_at");

-- CreateIndex
CREATE INDEX "audit_log_entity_entity_id_idx" ON "auth"."audit_log"("entity", "entity_id");

-- CreateIndex
CREATE INDEX "audit_log_user_id_created_at_idx" ON "auth"."audit_log"("user_id", "created_at" DESC);

-- AddForeignKey
ALTER TABLE "auth"."audit_log" ADD CONSTRAINT "audit_log_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- Mantiene updated_at también ante UPDATEs hechos fuera de Prisma (convención del modelo de datos).
CREATE OR REPLACE FUNCTION "auth".set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated BEFORE UPDATE ON "auth"."users"
  FOR EACH ROW EXECUTE FUNCTION "auth".set_updated_at();
