import { Injectable, Logger, UnauthorizedException } from '@nestjs/common';
import { App, applicationDefault, cert, getApps, initializeApp } from 'firebase-admin/app';
import { Auth, getAuth } from 'firebase-admin/auth';
import type { FirebaseIdentity } from '@backend/contracts';

/**
 * Único punto de contacto del backend con Firebase Auth (rúbrica F1 y S3).
 *
 * Credenciales (NUNCA en el repositorio, solo variables de entorno):
 *  1. `FIREBASE_CLIENT_EMAIL` + `FIREBASE_PRIVATE_KEY` (+ `FIREBASE_PROJECT_ID`) → cuenta de servicio.
 *  2. `GOOGLE_APPLICATION_CREDENTIALS` → ruta (fuera del repo) al JSON de la cuenta de servicio.
 *  3. Solo `FIREBASE_PROJECT_ID` → suficiente para VERIFICAR tokens ID (usa las claves públicas
 *     de Google); no permite operaciones administrativas (revocar sesiones, enviar push).
 *  Con `FIREBASE_AUTH_EMULATOR_HOST` el SDK usa el emulador local sin credenciales.
 */
@Injectable()
export class FirebaseAuthService {
  private readonly logger = new Logger(FirebaseAuthService.name);
  private authInstance?: Auth;

  private get auth(): Auth {
    if (!this.authInstance) this.authInstance = getAuth(this.app());
    return this.authInstance;
  }

  private app(): App {
    const existing = getApps()[0];
    if (existing) return existing;

    const projectId = process.env.FIREBASE_PROJECT_ID;
    if (!projectId) {
      throw new Error('FIREBASE_PROJECT_ID no está definido (ver .env.example).');
    }
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
    const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');

    if (clientEmail && privateKey) {
      return initializeApp({ credential: cert({ projectId, clientEmail, privateKey }), projectId });
    }
    if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
      return initializeApp({ credential: applicationDefault(), projectId });
    }
    this.logger.warn('Firebase sin cuenta de servicio: solo se podrán verificar tokens ID.');
    return initializeApp({ projectId });
  }

  /** Verifica un token ID de Firebase. Lanza 401 si es inválido, expirado o revocado. */
  async verifyIdToken(idToken: string): Promise<FirebaseIdentity> {
    try {
      const decoded = await this.auth.verifyIdToken(idToken);
      return { firebaseUid: decoded.uid, email: decoded.email ?? null };
    } catch {
      // No filtramos el motivo técnico al cliente (rúbrica S5).
      throw new UnauthorizedException('Token inválido o expirado');
    }
  }

  /** Cierra todas las sesiones del usuario (requiere cuenta de servicio). */
  async revokeSessions(firebaseUid: string): Promise<void> {
    await this.auth.revokeRefreshTokens(firebaseUid);
  }
}
