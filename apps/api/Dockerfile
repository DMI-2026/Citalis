# syntax=docker/dockerfile:1.7
# ---------------------------------------------------------------------------
# Dockerfile ÚNICO para todo el monorepo (pnpm workspace + NestJS + Prisma).
#
# La misma imagen base sirve al gateway y a los 6 microservicios. Cada uno se distingue
# solo por dos build args:
#
#   SERVICE_DIR   ruta del paquete dentro del workspace (ej: services/auth-service)
#   SERVICE_PORT  puerto que expone (ej: 3001)
#
# Por qué un solo Dockerfile y no 7: `pnpm install` y la compilación de commons/* son capas
# compartidas; solo la última capa (el `dist` del servicio) cambia entre imágenes.
#
# Etapas:
#   base       -> Node 20 + openssl (Prisma) + pnpm
#   manifests  -> solo package.json + lockfile (capa cacheable de dependencias)
#   deps       -> pnpm install completo (dev + prod) para poder compilar
#   builder    -> prisma generate + turbo build de todo el monorepo
#   prod-deps  -> pnpm install --prod
#   runtime    -> imagen final por servicio (target por defecto)
#   migrator   -> imagen auxiliar con el CLI de Prisma (migrate deploy)
# ---------------------------------------------------------------------------

########################  base  ############################################
FROM node:20-bookworm-slim AS base

# openssl + ca-certificates: requeridos por el motor de Prisma y por conexiones TLS a la BD.
RUN apt-get update \
 && apt-get install -y --no-install-recommends openssl ca-certificates \
 && rm -rf /var/lib/apt/lists/*

ENV PNPM_HOME=/pnpm
ENV PATH="$PNPM_HOME:$PATH"
# Debe coincidir con "packageManager" del package.json raíz (formato del pnpm-lock.yaml).
RUN corepack enable && corepack prepare pnpm@8.15.0 --activate

WORKDIR /app


########################  manifests  #######################################
FROM base AS manifests

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml .npmrc ./

COPY commons/contracts/package.json      ./commons/contracts/
COPY commons/firebase/package.json       ./commons/firebase/
COPY commons/observability/package.json  ./commons/observability/
COPY commons/security/package.json       ./commons/security/
COPY commons/utils/package.json          ./commons/utils/

COPY gateway/package.json ./gateway/

COPY services/auth-service/package.json           ./services/auth-service/
COPY services/negocios-service/package.json       ./services/negocios-service/
COPY services/agenda-service/package.json         ./services/agenda-service/
COPY services/clientes-service/package.json       ./services/clientes-service/
COPY services/descubrimiento-service/package.json ./services/descubrimiento-service/
COPY services/notificaciones-service/package.json ./services/notificaciones-service/


########################  deps (dev + prod)  ###############################
FROM manifests AS deps

RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    pnpm install --frozen-lockfile


########################  builder  #########################################
FROM deps AS builder

COPY . .

# prisma generate NO se conecta a la base: scripts/prisma-cli.mjs usa una URL ficticia si no hay
# DATABASE_URL. Genera el cliente Linux en <servicio>/src/generated/prisma.
RUN pnpm run db:generate

# turbo build: primero commons/* (dependsOn ^build) y luego gateway + los 6 servicios.
# nest-cli copia src/generated/** a dist/generated/** (cliente + motor de consultas).
RUN pnpm run build


########################  prod-deps  #######################################
# node_modules sin dependencias de desarrollo. node-linker=hoisted deja un node_modules plano
# en la raíz: los paquetes de commons/* declaran @nestjs/* como peerDependencies y con el
# layout aislado de pnpm + --prod no los encontrarían (MODULE_NOT_FOUND al arrancar).
FROM manifests AS prod-deps

ENV NPM_CONFIG_NODE_LINKER=hoisted

RUN --mount=type=cache,id=pnpm-store,target=/pnpm/store \
    pnpm install --frozen-lockfile --prod --ignore-scripts


########################  runtime (imagen final por servicio)  #############
FROM base AS runtime

ENV NODE_ENV=production
ENV NPM_CONFIG_UPDATE_NOTIFIER=false

WORKDIR /app

COPY --from=prod-deps /app ./

COPY --from=builder /app/commons/contracts/dist     ./commons/contracts/dist
COPY --from=builder /app/commons/firebase/dist      ./commons/firebase/dist
COPY --from=builder /app/commons/observability/dist ./commons/observability/dist
COPY --from=builder /app/commons/security/dist      ./commons/security/dist
COPY --from=builder /app/commons/utils/dist         ./commons/utils/dist

ARG SERVICE_DIR
ARG SERVICE_PORT

# Compilado del servicio (incluye dist/generated/prisma cuando aplica).
COPY --from=builder /app/${SERVICE_DIR}/dist ./${SERVICE_DIR}/dist

WORKDIR /app/${SERVICE_DIR}
EXPOSE ${SERVICE_PORT}

USER node
CMD ["node", "dist/main"]


########################  migrator  ########################################
# Imagen auxiliar (perfil `tools` del compose): aplica `prisma migrate deploy` de cada servicio.
# Nunca corre automáticamente ni usa `db push`.
FROM builder AS migrator

ENV PRISMA_HIDE_UPDATE_MESSAGE=true

COPY docker/run-migrations.sh /usr/local/bin/run-migrations
# sed: normaliza CRLF -> LF por si el script se clonó en Windows.
RUN sed -i 's/\r$//' /usr/local/bin/run-migrations \
 && chmod +x /usr/local/bin/run-migrations

WORKDIR /app
ENTRYPOINT ["run-migrations"]
