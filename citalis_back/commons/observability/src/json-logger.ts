import { LogLevel, LoggerService } from '@nestjs/common';

const LEVELS: LogLevel[] = ['fatal', 'error', 'warn', 'log', 'debug', 'verbose'];

/**
 * Logger estructurado (una línea JSON por evento) para producción/Docker.
 * El nivel se controla con `LOG_LEVEL` (error | warn | log | debug | verbose).
 */
export class JsonLogger implements LoggerService {
  private readonly threshold: number;

  constructor(
    private readonly service: string,
    level: string = process.env.LOG_LEVEL ?? 'log',
  ) {
    const idx = LEVELS.indexOf(level as LogLevel);
    this.threshold = idx === -1 ? LEVELS.indexOf('log') : idx;
  }

  log(message: unknown, context?: string) {
    this.write('log', message, context);
  }

  error(message: unknown, stack?: string, context?: string) {
    this.write('error', message, context, stack);
  }

  warn(message: unknown, context?: string) {
    this.write('warn', message, context);
  }

  debug(message: unknown, context?: string) {
    this.write('debug', message, context);
  }

  verbose(message: unknown, context?: string) {
    this.write('verbose', message, context);
  }

  fatal(message: unknown, context?: string) {
    this.write('fatal', message, context);
  }

  private write(level: LogLevel, message: unknown, context?: string, stack?: string) {
    if (LEVELS.indexOf(level) > this.threshold) return;
    const line = JSON.stringify({
      time: new Date().toISOString(),
      level,
      service: this.service,
      context,
      message: typeof message === 'string' ? message : JSON.stringify(message),
      // El stack solo sirve para depurar: nunca en producción (rúbrica S5).
      ...(stack && process.env.NODE_ENV !== 'production' ? { stack } : {}),
    });
    process.stdout.write(`${line}\n`);
  }
}
