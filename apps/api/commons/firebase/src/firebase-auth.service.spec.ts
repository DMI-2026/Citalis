import { UnauthorizedException } from '@nestjs/common';
import { FirebaseAuthService } from './firebase-auth.service';

const verifyIdToken = jest.fn();

jest.mock('firebase-admin/app', () => ({
  getApps: () => [{}],
  initializeApp: jest.fn(),
  cert: jest.fn(),
  applicationDefault: jest.fn(),
}));
jest.mock('firebase-admin/auth', () => ({
  getAuth: () => ({ verifyIdToken, revokeRefreshTokens: jest.fn() }),
}));

describe('FirebaseAuthService', () => {
  const service = new FirebaseAuthService();

  it('devuelve la identidad de un token válido', async () => {
    verifyIdToken.mockResolvedValue({ uid: 'abc', email: 'ana@correo.com' });
    await expect(service.verifyIdToken('t')).resolves.toEqual({
      firebaseUid: 'abc',
      email: 'ana@correo.com',
    });
  });

  it('traduce cualquier fallo del SDK a 401 sin revelar el motivo', async () => {
    verifyIdToken.mockRejectedValue(new Error('auth/id-token-expired: detalle interno'));
    await expect(service.verifyIdToken('t')).rejects.toBeInstanceOf(UnauthorizedException);
    await expect(service.verifyIdToken('t')).rejects.toThrow('Token inválido o expirado');
  });
});
