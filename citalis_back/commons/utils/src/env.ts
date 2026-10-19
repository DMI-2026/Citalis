import { existsSync } from 'fs';
import { dirname, join } from 'path';
import { config } from 'dotenv';
import { SERVICE_PORTS, ServiceName } from '@backend/contracts';

/**
 * Carga el ÚNICO `.env` del monorepo (el que está junto a `pnpm-workspace.yaml`).
 * No pisa variables ya definidas: en Docker/producción mandan las del entorno.
 * Devuelve la ruta cargada o `null` si no existe (caso normal en Docker).
 */
export function loadRootEnv(startDir: string = process.cwd()): string | null {
  let dir = startDir;
  for (;;) {
    if (existsSync(join(dir, 'pnpm-workspace.yaml'))) {
      const file = join(dir, '.env');
      if (!existsSync(file)) return null;
      config({ path: file });
      return file;
    }
    const parent = dirname(dir);
    if (parent === dir) return null;
    dir = parent;
  }
}

/** Falla al arrancar (fail-fast) si falta alguna variable obligatoria. */
export function assertRequiredEnv(service: string, names: string[]): void {
  const missing = names.filter((name) => !process.env[name]?.trim());
  if (missing.length > 0) {
    throw new Error(
      `[${service}] faltan variables de entorno obligatorias: ${missing.join(', ')}. ` +
        'Copia .env.example a .env y complétalas.',
    );
  }
}

/** En producción exige secretos reales (no de ejemplo ni demasiado cortos). */
export function assertStrongSecret(service: string, name: string, minLength = 32): void {
  if (process.env.NODE_ENV !== 'production') return;
  const value = process.env[name] ?? '';
  if (value.length < minLength || value.includes('change_me')) {
    throw new Error(
      `[${service}] ${name} debe tener al menos ${minLength} caracteres en producción.`,
    );
  }
}

/**
 * URL base de un servicio vecino: `<NOMBRE>_SERVICE_URL` (p. ej. `NEGOCIOS_SERVICE_URL`)
 * o `http://localhost:<puerto por defecto>` en desarrollo local.
 */
export function serviceUrl(name: ServiceName): string {
  const envKey = `${name.replace('-service', '').toUpperCase()}_SERVICE_URL`;
  return process.env[envKey] ?? `http://localhost:${SERVICE_PORTS[name]}`;
}

/** Swagger (/docs) solo en desarrollo, salvo `SWAGGER_ENABLED=true` (rúbrica S5). */
export function isSwaggerEnabled(): boolean {
  const explicit = process.env.SWAGGER_ENABLED;
  return explicit !== undefined ? explicit === 'true' : process.env.NODE_ENV !== 'production';
}

/** Endpoints `/<prefijo>/test`: activos en desarrollo; en producción solo con `ENABLE_TEST_ENDPOINTS=true`. */
export function isTestEndpointEnabled(): boolean {
  const explicit = process.env.ENABLE_TEST_ENDPOINTS;
  return explicit !== undefined ? explicit === 'true' : process.env.NODE_ENV !== 'production';
}
