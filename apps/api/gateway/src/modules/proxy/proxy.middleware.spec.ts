import { ForbiddenException, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { ProxyMiddleware } from './proxy.middleware';

const proxyHandler = jest.fn();
jest.mock('http-proxy-middleware', () => ({ createProxyMiddleware: () => proxyHandler }));

function makeRequest(path: string, headers: Record<string, string> = {}) {
  return { path, headers: { ...headers } } as any;
}

describe('ProxyMiddleware', () => {
  const firebase = { verifyIdToken: jest.fn() };
  const users = { findUserId: jest.fn() };
  const middleware = new ProxyMiddleware(firebase as any, users as any);
  const res = {} as any;
  const next = jest.fn();

  beforeEach(() => {
    process.env.INTERNAL_API_TOKEN = 'secreto-interno';
    firebase.verifyIdToken.mockResolvedValue({ firebaseUid: 'uid1', email: 'ana@correo.com' });
    users.findUserId.mockResolvedValue('user-1');
  });

  it('responde 404 en /internal/* y en rutas desconocidas', async () => {
    await expect(
      middleware.use(makeRequest('/internal/users/1'), res, next),
    ).rejects.toBeInstanceOf(NotFoundException);
    await expect(middleware.use(makeRequest('/nada'), res, next)).rejects.toBeInstanceOf(
      NotFoundException,
    );
  });

  it('exige Bearer token en rutas protegidas', async () => {
    await expect(middleware.use(makeRequest('/reservations'), res, next)).rejects.toBeInstanceOf(
      UnauthorizedException,
    );
    expect(proxyHandler).not.toHaveBeenCalled();
  });

  it('descarta cabeceras de identidad falsificadas en rutas públicas', async () => {
    const req = makeRequest('/auth/test', { 'x-user-id': 'falso', 'x-internal-token': 'falso' });
    await middleware.use(req, res, next);
    expect(req.headers['x-user-id']).toBeUndefined();
    expect(req.headers['x-internal-token']).toBeUndefined();
    expect(proxyHandler).toHaveBeenCalled();
  });

  it('inyecta identidad verificada y token interno, pisando lo que mande el cliente', async () => {
    const req = makeRequest('/reservations', { authorization: 'Bearer abc', 'x-user-id': 'falso' });
    await middleware.use(req, res, next);
    expect(firebase.verifyIdToken).toHaveBeenCalledWith('abc');
    expect(req.headers).toMatchObject({
      'x-user-id': 'user-1',
      'x-firebase-uid': 'uid1',
      'x-user-email': 'ana@correo.com',
      'x-internal-token': 'secreto-interno',
    });
  });

  it('rechaza (403) a un usuario Firebase aún no registrado, salvo en /auth/register', async () => {
    users.findUserId.mockResolvedValue(null);
    const blocked = makeRequest('/reservations', { authorization: 'Bearer abc' });
    await expect(middleware.use(blocked, res, next)).rejects.toBeInstanceOf(ForbiddenException);

    const register = makeRequest('/auth/register', { authorization: 'Bearer abc' });
    await middleware.use(register, res, next);
    expect(register.headers['x-user-id']).toBeUndefined();
    expect(register.headers['x-firebase-uid']).toBe('uid1');
  });
});
