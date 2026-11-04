-- Schema propio del servicio (Prisma no lo emite por sí mismo).
CREATE SCHEMA IF NOT EXISTS "clientes";

-- CreateTable
CREATE TABLE "clientes"."client_business_links" (
    "user_id" UUID NOT NULL,
    "business_id" UUID NOT NULL,
    "first_visit_at" TIMESTAMPTZ NOT NULL,
    "last_visit_at" TIMESTAMPTZ NOT NULL,
    "total_visits" INTEGER NOT NULL DEFAULT 0,
    "total_spent" DECIMAL(12,2) NOT NULL DEFAULT 0,

    CONSTRAINT "client_business_links_pkey" PRIMARY KEY ("user_id","business_id")
);

-- CreateTable
CREATE TABLE "clientes"."ratings" (
    "reservation_id" UUID NOT NULL,
    "business_id" UUID NOT NULL,
    "client_id" UUID NOT NULL,
    "rating" SMALLINT NOT NULL,
    "comment" TEXT,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "ratings_pkey" PRIMARY KEY ("reservation_id")
);

-- CreateIndex
CREATE INDEX "client_business_links_business_id_last_visit_at_idx" ON "clientes"."client_business_links"("business_id", "last_visit_at" DESC);

-- CreateIndex
CREATE INDEX "ratings_business_id_created_at_idx" ON "clientes"."ratings"("business_id", "created_at" DESC);

-- Calificación de 1 a 5 (Req 4.3).
ALTER TABLE "clientes"."ratings"
  ADD CONSTRAINT ratings_rating_valid CHECK (rating BETWEEN 1 AND 5);

ALTER TABLE "clientes"."client_business_links"
  ADD CONSTRAINT client_links_totals_valid CHECK (total_visits >= 0 AND total_spent >= 0);
