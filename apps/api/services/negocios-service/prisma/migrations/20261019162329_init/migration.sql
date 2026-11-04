-- Schema propio del servicio (Prisma no lo emite por sí mismo).
CREATE SCHEMA IF NOT EXISTS "negocios";

-- CreateExtension
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- CreateTable
CREATE TABLE "negocios"."businesses" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "owner_id" UUID NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "category" VARCHAR(60) NOT NULL,
    "description" TEXT NOT NULL,
    "phone" VARCHAR(20) NOT NULL,
    "address" VARCHAR(240) NOT NULL,
    "municipality" VARCHAR(80) NOT NULL,
    "hero_image_url" TEXT,
    "deep_link_code" VARCHAR(32) NOT NULL,
    "latitude" DOUBLE PRECISION,
    "longitude" DOUBLE PRECISION,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "deleted_at" TIMESTAMPTZ,

    CONSTRAINT "businesses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "negocios"."business_images" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "business_id" UUID NOT NULL,
    "url" TEXT NOT NULL,
    "position" SMALLINT NOT NULL DEFAULT 0,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "business_images_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "negocios"."services" (
    "id" UUID NOT NULL DEFAULT gen_random_uuid(),
    "business_id" UUID NOT NULL,
    "name" VARCHAR(120) NOT NULL,
    "description" TEXT NOT NULL DEFAULT '',
    "duration_minutes" INTEGER NOT NULL,
    "price" DECIMAL(10,2) NOT NULL,
    "is_active" BOOLEAN NOT NULL DEFAULT true,
    "created_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "services_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "negocios"."business_categories" (
    "slug" VARCHAR(60) NOT NULL,
    "display_name" VARCHAR(80) NOT NULL,
    "icon_hint" VARCHAR(60),
    "position" SMALLINT NOT NULL DEFAULT 0,

    CONSTRAINT "business_categories_pkey" PRIMARY KEY ("slug")
);

-- CreateTable
CREATE TABLE "negocios"."municipalities" (
    "slug" VARCHAR(60) NOT NULL,
    "display_name" VARCHAR(80) NOT NULL,
    "state" VARCHAR(60) NOT NULL DEFAULT 'Morelos',

    CONSTRAINT "municipalities_pkey" PRIMARY KEY ("slug")
);

-- CreateIndex
CREATE UNIQUE INDEX "businesses_owner_id_key" ON "negocios"."businesses"("owner_id");

-- CreateIndex
CREATE UNIQUE INDEX "businesses_deep_link_code_key" ON "negocios"."businesses"("deep_link_code");

-- CreateIndex
CREATE INDEX "businesses_category_idx" ON "negocios"."businesses"("category");

-- CreateIndex
CREATE INDEX "businesses_municipality_idx" ON "negocios"."businesses"("municipality");

-- CreateIndex
CREATE INDEX "businesses_name_idx" ON "negocios"."businesses" USING GIN ("name" gin_trgm_ops);

-- CreateIndex
CREATE INDEX "business_images_business_id_position_idx" ON "negocios"."business_images"("business_id", "position");

-- CreateIndex
CREATE INDEX "services_business_id_idx" ON "negocios"."services"("business_id");

-- AddForeignKey
ALTER TABLE "negocios"."business_images" ADD CONSTRAINT "business_images_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "negocios"."businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "negocios"."services" ADD CONSTRAINT "services_business_id_fkey" FOREIGN KEY ("business_id") REFERENCES "negocios"."businesses"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- Mantiene updated_at también ante UPDATEs hechos fuera de Prisma (convención del modelo de datos).
CREATE OR REPLACE FUNCTION "negocios".set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_businesses_updated BEFORE UPDATE ON "negocios"."businesses"
  FOR EACH ROW EXECUTE FUNCTION "negocios".set_updated_at();

CREATE TRIGGER trg_services_updated BEFORE UPDATE ON "negocios"."services"
  FOR EACH ROW EXECUTE FUNCTION "negocios".set_updated_at();

-- Reglas de integridad de servicios (Req 2.4: duración y precio válidos).
ALTER TABLE "negocios"."services"
  ADD CONSTRAINT services_duration_valid CHECK (duration_minutes > 0 AND duration_minutes <= 600),
  ADD CONSTRAINT services_price_valid CHECK (price >= 0);

-- Datos semilla de catálogos (listas que crecen sin requerir cambios de código).
INSERT INTO "negocios"."business_categories" (slug, display_name, position) VALUES
  ('peluqueria',     'Peluquería',       1),
  ('unas',           'Uñas',             2),
  ('spa',            'Spa',              3),
  ('barberia',       'Barbería',         4),
  ('cejas-pestanas', 'Cejas & Pestañas', 5),
  ('wellness',       'Wellness',         6),
  ('masajes',        'Masajes',          7),
  ('depilacion',     'Depilación',       8)
ON CONFLICT (slug) DO NOTHING;

INSERT INTO "negocios"."municipalities" (slug, display_name) VALUES
  ('cuernavaca',      'Cuernavaca'),
  ('jiutepec',        'Jiutepec'),
  ('temixco',         'Temixco'),
  ('yautepec',        'Yautepec'),
  ('emiliano-zapata', 'Emiliano Zapata'),
  ('xochitepec',      'Xochitepec')
ON CONFLICT (slug) DO NOTHING;
