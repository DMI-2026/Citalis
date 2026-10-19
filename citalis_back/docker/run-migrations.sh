#!/bin/sh
# ---------------------------------------------------------------------------
# Aplica las migraciones de Prisma de los servicios contra la base de datos.
#
# Uso (desde citalis_back/):
#   docker compose run --rm migrator                      # todos los servicios
#   docker compose run --rm migrator auth-service         # solo uno
#   docker compose run --rm migrator status               # estado, sin aplicar nada
#
# Usa SIEMPRE `prisma migrate deploy` (nunca `db push`): aplica las migraciones ya versionadas
# en <servicio>/prisma/migrations y no altera el schema por su cuenta.
# ---------------------------------------------------------------------------
set -e

cd /app

if [ -z "$DATABASE_URL" ]; then
  echo "ERROR: DATABASE_URL no está definida. Revisa citalis_back/.env" >&2
  exit 1
fi

COMMAND="migrate deploy"
TARGET=""

case "$1" in
  status)
    COMMAND="migrate status"
    TARGET="$2"
    ;;
  "")
    ;;
  *)
    TARGET="$1"
    ;;
esac

FOUND=0

for dir in services/*/; do
  name=$(basename "$dir")

  [ -f "${dir}prisma/schema.prisma" ] || continue

  if [ -n "$TARGET" ] && [ "$TARGET" != "$name" ]; then
    continue
  fi

  FOUND=1
  echo ""
  echo "=== prisma ${COMMAND} :: ${name} ==================="
  if [ "$COMMAND" = "migrate status" ]; then
    # `migrate status` devuelve código != 0 si hay migraciones pendientes; aquí solo se informa.
    ( cd "$dir" && node ../../scripts/prisma-cli.mjs migrate status ) || true
  else
    ( cd "$dir" && node ../../scripts/prisma-cli.mjs migrate deploy )
  fi
done

if [ "$FOUND" = "0" ]; then
  echo "ERROR: no se encontró ningún servicio con prisma/schema.prisma que coincida con '${TARGET}'." >&2
  exit 1
fi

echo ""
echo "=== Migraciones finalizadas ==================================="
