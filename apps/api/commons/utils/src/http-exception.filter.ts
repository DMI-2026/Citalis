import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import type { ApiErrorResponse } from '@backend/contracts';

const CODE_PATTERN = /^[A-Z][A-Z0-9_]+$/;

/**
 * Filtro global: TODA respuesta de error de la API tiene el formato `ApiErrorResponse`.
 *
 * Cómo lanzar errores de negocio con código propio:
 *   throw new ConflictException({ code: 'RESERVATION_OVERLAP', message: 'Horario ocupado' });
 * Las excepciones sin `code` reciben el nombre del status (`NOT_FOUND`, `FORBIDDEN`...).
 * Los errores inesperados responden 500 genérico: el detalle solo va al log (rúbrica S5).
 */
@Catch()
export class GlobalHttpExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalHttpExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost): void {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let code = 'INTERNAL_SERVER_ERROR';
    let message = 'Error interno del servidor';

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      code = HttpStatus[status] ?? 'ERROR';
      const body = exception.getResponse();

      if (typeof body === 'string') {
        message = body;
        if (CODE_PATTERN.test(body)) code = body;
      } else {
        const resp = body as { message?: string | string[]; code?: string };
        if (Array.isArray(resp.message)) {
          message = resp.message.join(', ');
          code = 'VALIDATION_ERROR';
        } else if (resp.message) {
          message = resp.message;
          if (!resp.code && CODE_PATTERN.test(resp.message)) code = resp.message;
        }
        if (resp.code) code = resp.code;
      }
    } else {
      this.logger.error(
        'Excepción no controlada',
        exception instanceof Error ? exception.stack : String(exception),
      );
    }

    const payload: ApiErrorResponse = {
      statusCode: status,
      code,
      message,
      timestamp: new Date().toISOString(),
      path: (request.originalUrl ?? request.url ?? '').split('?')[0],
    };
    response.status(status).json(payload);
  }
}
