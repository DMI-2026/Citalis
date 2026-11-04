/**
 * @backend/contracts
 * Tipos, constantes e interfaces compartidas entre microservicios.
 * Ningún servicio debe duplicar estos tipos: siempre importar desde aquí.
 * Este paquete NO tiene dependencias de runtime (solo tipos y constantes).
 */

// ─── Cabeceras que el gateway inyecta hacia los servicios ───────────────────

/** Secreto compartido gateway↔servicios y servicio↔servicio (`INTERNAL_API_TOKEN`). */
export const INTERNAL_TOKEN_HEADER = 'x-internal-token';
/** UUID interno del usuario (`auth.users.id`). Ausente si aún no completó su registro. */
export const USER_ID_HEADER = 'x-user-id';
/** UID del usuario en Firebase Auth. */
export const FIREBASE_UID_HEADER = 'x-firebase-uid';
/** Correo verificado por Firebase. */
export const USER_EMAIL_HEADER = 'x-user-email';

// ─── Identidad ──────────────────────────────────────────────────────────────

/** Identidad verificada por Firebase (token ID válido). */
export interface FirebaseIdentity {
  firebaseUid: string;
  email: string | null;
}

/** Usuario autenticado Y registrado en Citalis (existe en `auth.users`). */
export interface RequestUser extends FirebaseIdentity {
  /** `auth.users.id` */
  userId: string;
}

// ─── Registro de servicios ──────────────────────────────────────────────────

export type ServiceName =
  | 'auth-service'
  | 'negocios-service'
  | 'agenda-service'
  | 'clientes-service'
  | 'descubrimiento-service'
  | 'notificaciones-service';

/** Puertos por defecto (desarrollo local). En Docker cada contenedor usa su propio PORT. */
export const SERVICE_PORTS: Record<ServiceName, number> = {
  'auth-service': 3001,
  'negocios-service': 3002,
  'agenda-service': 3003,
  'clientes-service': 3004,
  'descubrimiento-service': 3005,
  'notificaciones-service': 3006,
};

/**
 * Prefijo de ruta (`/<prefijo>`) con el que el gateway identifica a cada servicio.
 * El endpoint de prueba de cada servicio vive en `/<prefijo>/test`.
 */
export const SERVICE_ROUTE_PREFIX: Record<ServiceName, string> = {
  'auth-service': 'auth',
  'negocios-service': 'businesses',
  'agenda-service': 'reservations',
  'clientes-service': 'clients',
  'descubrimiento-service': 'discover',
  'notificaciones-service': 'notifications',
};

// ─── Paginación ─────────────────────────────────────────────────────────────

export interface PaginationMeta {
  page: number;
  pageSize: number;
  total: number;
  totalPages: number;
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: PaginationMeta;
}

// ─── Respuestas estándar ────────────────────────────────────────────────────

/** Formato único de error de TODA la API (lo produce `GlobalHttpExceptionFilter`). */
export interface ApiErrorResponse {
  statusCode: number;
  /** Código estable legible por máquina, p. ej. `RESERVATION_OVERLAP`. */
  code: string;
  message: string;
  timestamp: string;
  path: string;
}

/** Respuesta de `GET /health`. */
export interface HealthReport {
  status: 'ok' | 'error';
  service: string;
  timestamp: string;
  uptime: number;
  checks: { database: 'up' | 'down' };
}

/** Respuesta de `GET /<prefijo>/test` (validación de BD y del servicio). */
export interface TestReport {
  service: string;
  status: 'ok' | 'error';
  timestamp: string;
  uptimeSeconds: number;
  environment: string;
  database: {
    connected: boolean;
    latencyMs: number | null;
    schema: string;
    /** Filas de las tablas propias del servicio (prueba que las migraciones corrieron). */
    tables: Record<string, number | null>;
  };
}

// ─── Dominio compartido ─────────────────────────────────────────────────────

export type ReservationStatus = 'pending' | 'confirmed' | 'completed' | 'cancelled' | 'no_show';

// ─── Contratos HTTP internos (rutas /internal/* entre servicios) ────────────
// Cada DTO lo EXPONE el servicio dueño de los datos y lo CONSUME, vía un
// http-client, el servicio que lo necesita. Nunca se lee la BD ajena.

/** auth-service → gateway y demás servicios. */
export interface InternalUserDto {
  id: string;
  firebaseUid: string | null;
  email: string;
  name: string;
  phone: string | null;
}

/** negocios-service → agenda, clientes, descubrimiento. */
export interface InternalBusinessDto {
  id: string;
  ownerId: string;
  name: string;
  isActive: boolean;
}

/** negocios-service → agenda (precio y duración se congelan en la reserva). */
export interface InternalServiceDto {
  id: string;
  businessId: string;
  name: string;
  durationMinutes: number;
  price: string;
  isActive: boolean;
}

/** agenda-service → clientes (al completarse una reserva se actualiza el vínculo). */
export interface InternalReservationCompletedDto {
  reservationId: string;
  businessId: string;
  clientId: string;
  scheduledAt: string;
  price: string;
}
