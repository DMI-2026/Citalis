import { SERVICE_ROUTE_PREFIX, ServiceName } from '@backend/contracts';
import { isTestEndpointEnabled } from '@backend/utils';

/**
 * Tabla de ruteo: prefijo de ruta → microservicio dueño.
 * Al agregar un recurso nuevo a un servicio, se declara AQUÍ (y en la guía de trabajo).
 */
export const ROUTES: ReadonlyArray<{ prefix: string; service: ServiceName }> = [
  { prefix: '/auth', service: 'auth-service' },
  { prefix: '/users', service: 'auth-service' },
  { prefix: '/businesses', service: 'negocios-service' },
  { prefix: '/catalogs', service: 'negocios-service' },
  { prefix: '/reservations', service: 'agenda-service' },
  { prefix: '/availability', service: 'agenda-service' },
  { prefix: '/schedule', service: 'agenda-service' },
  { prefix: '/clients', service: 'clientes-service' },
  { prefix: '/ratings', service: 'clientes-service' },
  { prefix: '/discover', service: 'descubrimiento-service' },
  { prefix: '/favorites', service: 'descubrimiento-service' },
  { prefix: '/notifications', service: 'notificaciones-service' },
];

/** Rutas que exigen token Firebase pero NO usuario ya registrado en Citalis. */
export const ALLOW_UNREGISTERED_PATHS: readonly string[] = ['/auth/register'];

/** Prefijos que el gateway jamás reenvía hacia afuera (comunicación entre servicios). */
export const BLOCKED_PREFIXES: readonly string[] = ['/internal'];

const matches = (path: string, prefix: string) => path === prefix || path.startsWith(`${prefix}/`);

/** Servicio destino de una ruta, o `undefined` si no existe (el gateway responde 404). */
export function resolveService(path: string): ServiceName | undefined {
  return ROUTES.find((route) => matches(path, route.prefix))?.service;
}

/** Rutas públicas (sin token): health, docs y — si están habilitados — los `/<prefijo>/test`. */
export function isPublicPath(path: string): boolean {
  if (matches(path, '/health') || matches(path, '/docs')) return true;
  if (!isTestEndpointEnabled()) return false;
  return Object.values(SERVICE_ROUTE_PREFIX).some((prefix) => path === `/${prefix}/test`);
}

export const isBlockedPath = (path: string): boolean =>
  BLOCKED_PREFIXES.some((prefix) => matches(path, prefix));

export const allowsUnregistered = (path: string): boolean =>
  ALLOW_UNREGISTERED_PATHS.includes(path);
