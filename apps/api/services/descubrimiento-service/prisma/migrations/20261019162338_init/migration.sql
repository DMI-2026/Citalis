-- Schema propio del servicio (Prisma no lo emite por sí mismo).
CREATE SCHEMA IF NOT EXISTS "descubrimiento";

-- CreateTable
CREATE TABLE "descubrimiento"."favorites" (
    "user_id" UUID NOT NULL,
    "business_id" UUID NOT NULL,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "favorites_pkey" PRIMARY KEY ("user_id","business_id")
);

-- CreateIndex
CREATE INDEX "favorites_user_id_idx" ON "descubrimiento"."favorites"("user_id");
