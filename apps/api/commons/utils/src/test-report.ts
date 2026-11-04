import { Logger, NotFoundException } from '@nestjs/common';
import type { HealthReport, TestReport } from '@backend/contracts';
import { isTestEndpointEnabled } from './env';

const logger = new Logger('TestReport');

export interface TestReportOptions {
  service: string;
  /** Schema de PostgreSQL dueño del servicio (p. ej. `agenda`). */
  schema: string;
  /** Round-trip mínimo a la BD, normalmente `prisma.$queryRaw\`SELECT 1\``. */
  ping: () => Promise<unknown>;
  /** Un conteo por tabla propia: prueba que la migración corrió y el schema es accesible. */
  tables: Record<string, () => Promise<number>>;
}

/**
 * Cuerpo de `GET /<prefijo>/test`. Responde con datos mínimos (sin cadenas de conexión ni
 * mensajes técnicos): los errores reales van al log del servicio.
 */
export async function buildTestReport(options: TestReportOptions): Promise<TestReport> {
  if (!isTestEndpointEnabled()) throw new NotFoundException();

  const started = Date.now();
  let connected = false;
  let latencyMs: number | null = null;
  try {
    await options.ping();
    connected = true;
    latencyMs = Date.now() - started;
  } catch (error) {
    logger.error(
      `[${options.service}] sin conexión a la BD`,
      error instanceof Error ? error.stack : String(error),
    );
  }

  const tables: Record<string, number | null> = {};
  for (const [name, count] of Object.entries(options.tables)) {
    if (!connected) {
      tables[name] = null;
      continue;
    }
    try {
      tables[name] = await count();
    } catch (error) {
      tables[name] = null;
      logger.error(
        `[${options.service}] no se pudo leer ${options.schema}.${name}`,
        error instanceof Error ? error.stack : String(error),
      );
    }
  }

  const ok = connected && Object.values(tables).every((value) => value !== null);
  return {
    service: options.service,
    status: ok ? 'ok' : 'error',
    timestamp: new Date().toISOString(),
    uptimeSeconds: Math.round(process.uptime()),
    environment: process.env.NODE_ENV ?? 'development',
    database: { connected, latencyMs, schema: options.schema, tables },
  };
}

/** Cuerpo de `GET /health` (liveness + BD). Lo usan Docker y el gateway. */
export async function buildHealthReport(
  service: string,
  ping: () => Promise<unknown>,
): Promise<HealthReport> {
  let database: 'up' | 'down' = 'up';
  try {
    await ping();
  } catch (error) {
    database = 'down';
    logger.error(
      `[${service}] health: BD no disponible`,
      error instanceof Error ? error.stack : String(error),
    );
  }
  return {
    status: database === 'up' ? 'ok' : 'error',
    service,
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    checks: { database },
  };
}

/** Código HTTP que corresponde a un reporte (200 si todo ok, 503 si no). */
export function reportStatusCode(report: { status: 'ok' | 'error' }): 200 | 503 {
  return report.status === 'ok' ? 200 : 503;
}
