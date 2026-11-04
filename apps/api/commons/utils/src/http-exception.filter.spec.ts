import {
  ArgumentsHost,
  BadRequestException,
  ConflictException,
  ForbiddenException,
  NotFoundException,
} from '@nestjs/common';
import { GlobalHttpExceptionFilter } from './http-exception.filter';

function run(exception: unknown) {
  const json = jest.fn();
  const status = jest.fn((_code: number) => ({ json }));
  const host = {
    switchToHttp: () => ({
      getResponse: () => ({ status }),
      getRequest: () => ({ originalUrl: '/reservations?token=abc' }),
    }),
  } as unknown as ArgumentsHost;
  new GlobalHttpExceptionFilter().catch(exception, host);
  return { status: status.mock.calls[0][0], body: json.mock.calls[0][0] };
}

describe('GlobalHttpExceptionFilter', () => {
  it('usa el code propio de la excepción y quita la query string del path', () => {
    const { status, body } = run(
      new ConflictException({ code: 'RESERVATION_OVERLAP', message: 'Horario ocupado' }),
    );
    expect(status).toBe(409);
    expect(body).toMatchObject({
      statusCode: 409,
      code: 'RESERVATION_OVERLAP',
      message: 'Horario ocupado',
      path: '/reservations',
    });
    expect(body.timestamp).toEqual(expect.any(String));
  });

  it('deriva el code del status cuando no hay uno propio', () => {
    expect(run(new NotFoundException()).body.code).toBe('NOT_FOUND');
  });

  it('usa mensajes en MAYÚSCULAS_CON_GUION como code', () => {
    expect(run(new ForbiddenException('USER_NOT_REGISTERED')).body.code).toBe(
      'USER_NOT_REGISTERED',
    );
  });

  it('agrupa errores de validación en VALIDATION_ERROR', () => {
    const { body } = run(new BadRequestException(['name must be a string', 'phone is too long']));
    expect(body.code).toBe('VALIDATION_ERROR');
    expect(body.message).toBe('name must be a string, phone is too long');
  });

  it('responde 500 genérico ante errores inesperados, sin filtrar el detalle', () => {
    const { status, body } = run(new Error('connection string postgres://u:p@host'));
    expect(status).toBe(500);
    expect(body.code).toBe('INTERNAL_SERVER_ERROR');
    expect(JSON.stringify(body)).not.toContain('postgres://');
  });
});
