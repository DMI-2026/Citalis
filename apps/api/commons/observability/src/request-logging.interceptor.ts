import { CallHandler, ExecutionContext, Injectable, Logger, NestInterceptor } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import type { Request, Response } from 'express';
import { USER_ID_HEADER } from '@backend/contracts';

/**
 * Registra `METHOD /ruta -> status (ms) user=<uuid>`.
 * Solo se loguea la RUTA (sin query string) y el id interno del usuario:
 * nunca tokens, cuerpos ni correos (rúbrica S5).
 */
@Injectable()
export class RequestLoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    if (context.getType() !== 'http') return next.handle();
    const http = context.switchToHttp();
    const req = http.getRequest<Request>();
    const res = http.getResponse<Response>();
    const started = Date.now();
    const user = req.headers[USER_ID_HEADER] ?? '-';
    const line = (status: number) =>
      `${req.method} ${req.path} -> ${status} (${Date.now() - started}ms) user=${user}`;

    return next.handle().pipe(
      tap({
        next: () => this.logger.log(line(res.statusCode)),
        error: (err: { status?: number }) => this.logger.warn(line(err?.status ?? 500)),
      }),
    );
  }
}
