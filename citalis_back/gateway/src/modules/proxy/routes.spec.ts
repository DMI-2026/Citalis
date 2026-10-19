import { allowsUnregistered, isBlockedPath, isPublicPath, resolveService } from './routes';

describe('routes', () => {
  afterEach(() => {
    delete process.env.ENABLE_TEST_ENDPOINTS;
  });

  it('enruta cada prefijo a su microservicio', () => {
    expect(resolveService('/auth/register')).toBe('auth-service');
    expect(resolveService('/businesses/123/services')).toBe('negocios-service');
    expect(resolveService('/reservations')).toBe('agenda-service');
    expect(resolveService('/clients')).toBe('clientes-service');
    expect(resolveService('/discover/nearby')).toBe('descubrimiento-service');
    expect(resolveService('/notifications/preferences')).toBe('notificaciones-service');
  });

  it('no confunde prefijos parecidos ni rutas desconocidas', () => {
    expect(resolveService('/authentic')).toBeUndefined();
    expect(resolveService('/businesses-secret')).toBeUndefined();
    expect(resolveService('/nada')).toBeUndefined();
  });

  it('bloquea /internal/*', () => {
    expect(isBlockedPath('/internal/users/1')).toBe(true);
    expect(isBlockedPath('/internals')).toBe(false);
  });

  it('marca como públicas solo health, docs y los endpoints de prueba exactos', () => {
    expect(isPublicPath('/health')).toBe(true);
    expect(isPublicPath('/docs')).toBe(true);
    expect(isPublicPath('/auth/test')).toBe(true);
    expect(isPublicPath('/businesses/test')).toBe(true);
    expect(isPublicPath('/businesses/test/otra')).toBe(false);
    expect(isPublicPath('/reservations')).toBe(false);
  });

  it('cierra los endpoints de prueba cuando están deshabilitados', () => {
    process.env.ENABLE_TEST_ENDPOINTS = 'false';
    expect(isPublicPath('/auth/test')).toBe(false);
    expect(isPublicPath('/health')).toBe(true);
  });

  it('solo el registro admite usuarios no registrados', () => {
    expect(allowsUnregistered('/auth/register')).toBe(true);
    expect(allowsUnregistered('/users/me')).toBe(false);
  });
});
