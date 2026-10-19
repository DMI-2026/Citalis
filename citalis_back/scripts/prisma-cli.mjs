#!/usr/bin/env node
/**
 * Envoltorio del CLI de Prisma para los servicios del monorepo.
 *
 * Uso (desde la carpeta de un servicio):  node ../../scripts/prisma-cli.mjs <comando de prisma>
 * Se invoca a través de los scripts `prisma:*` del package.json de cada servicio.
 *
 * Qué resuelve:
 *  1. Carga el ÚNICO .env de citalis_back/ (sin pisar variables ya definidas, p. ej. en Docker/CI).
 *  2. Todos los servicios comparten UNA base de datos con un schema por servicio. Prisma guarda su
 *     historial en la tabla `_prisma_migrations` del schema de la URL; si todos usaran `public`
 *     se mezclarían los historiales y `migrate dev` pediría resetear la base. Aquí se añade
 *     `?schema=<schema del servicio>` a DATABASE_URL solo para el CLI, así cada servicio tiene
 *     su propio historial dentro de su propio schema.
 *  3. `prisma generate` no necesita una base real: usa una URL ficticia si DATABASE_URL no existe.
 */
import { spawnSync } from 'node:child_process';
import { existsSync, readFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const args = process.argv.slice(2);
const schemaFile = join(process.cwd(), 'prisma', 'schema.prisma');

if (args.length === 0 || !existsSync(schemaFile)) {
  console.error(
    'Uso: node ../../scripts/prisma-cli.mjs <comando prisma>  (ejecutar dentro de services/<servicio>)',
  );
  process.exit(1);
}

const envFile = join(root, '.env');
if (existsSync(envFile)) {
  if (typeof process.loadEnvFile !== 'function') {
    console.error(
      `Se requiere Node >= 20.12 (tienes ${process.version}). Actualiza Node (ver .nvmrc).`,
    );
    process.exit(1);
  }
  process.loadEnvFile(envFile);
}

const schemaName = /schemas\s*=\s*\["([^"]+)"\]/.exec(readFileSync(schemaFile, 'utf8'))?.[1];
if (!schemaName) {
  console.error('No se encontró `schemas = ["..."]` en prisma/schema.prisma');
  process.exit(1);
}

let databaseUrl = process.env.DATABASE_URL;
if (!databaseUrl) {
  if (args[0] !== 'generate') {
    console.error('DATABASE_URL no está definida. Copia .env.example a .env y complétala.');
    process.exit(1);
  }
  databaseUrl = 'postgresql://build:build@127.0.0.1:5432/build';
}

const url = new URL(databaseUrl);
url.searchParams.set('schema', schemaName);

const result = spawnSync('pnpm', ['exec', 'prisma', ...args], {
  stdio: 'inherit',
  shell: process.platform === 'win32',
  env: { ...process.env, DATABASE_URL: url.toString(), PRISMA_HIDE_UPDATE_MESSAGE: 'true' },
});
process.exit(result.status ?? 1);
