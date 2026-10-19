import {
  ForbiddenException,
  Injectable,
  NestMiddleware,
  NotFoundException,
  UnauthorizedException,
} from '@nestjs/common';
import type { NextFunction, Request, Response } from 'express';
import { createProxyMiddleware } from 'http-proxy-middleware';
import {
  FIREBASE_UID_HEADER,
  INTERNAL_TOKEN_HEADER,
  USER_EMAIL_HEADER,
  USER_ID_HEADER,
} from '@backend/contracts';
import { FirebaseAuthService } from '@backend/firebase';
import { serviceUrl } from '@backend/utils';
import { allowsUnregistered, isBlockedPath, isPublicPath, resolveService } from './routes';
import { UserDirectoryService } from './user-directory.service';

type Proxy = ReturnType<typeof createProxyMiddleware<Request, Response>>;

/** Cabeceras que solo el gateway puede escribir: se borran SIEMPRE de lo que envía el cliente. */
const TRUSTED_HEADERS = [
  USER_ID_HEADER,
  FIREBASE_UID_HEADER,
  USER_EMAIL_HEADER,
  INTERNAL_TOKEN_HEADER,
];

/**
 * Único middleware del gateway:
 *   1. bloquea `/internal/*`;
 *   2. descarta cabeceras de identidad falsificadas por el cliente;
 *   3. en rutas protegidas verifica el token ID de Firebase y resuelve el usuario interno;
 *   4. reenvía al microservicio con la identidad en cabeceras `x-*` + `x-internal-token`.
 *
 * Sin lógica de negocio: solo enruta, autentica y observa (regla de arquitectura).
 */
@Injectable()
export class ProxyMiddleware implements NestMiddleware {
  /** Una instancia de http-proxy-middleware por destino, reutilizada entre requests. */
  private readonly proxies = new Map<string, Proxy>();

  constructor(
    private readonly firebase: FirebaseAuthService,
    private readonly users: UserDirectoryService,
  ) {}

  async use(req: Request, res: Response, next: NextFunction): Promise<void> {
    const path = req.path;
    if (isBlockedPath(path)) throw new NotFoundException();

    for (const header of TRUSTED_HEADERS) delete req.headers[header];

    const service = resolveService(path);
    if (!service) throw new NotFoundException();

    if (!isPublicPath(path)) {
      const authorization = req.headers.authorization;
      if (!authorization?.startsWith('Bearer ')) {
        throw new UnauthorizedException('Token de acceso requerido');
      }
      const identity = await this.firebase.verifyIdToken(authorization.substring(7));
      const userId = await this.users.findUserId(identity.firebaseUid);
      if (!userId && !allowsUnregistered(path)) throw new ForbiddenException('USER_NOT_REGISTERED');

      req.headers[FIREBASE_UID_HEADER] = identity.firebaseUid;
      if (identity.email) req.headers[USER_EMAIL_HEADER] = identity.email;
      if (userId) req.headers[USER_ID_HEADER] = userId;
      req.headers[INTERNAL_TOKEN_HEADER] = process.env.INTERNAL_API_TOKEN ?? '';
    }

    this.proxyFor(serviceUrl(service))(req, res, next);
  }

  private proxyFor(target: string): Proxy {
    let proxy = this.proxies.get(target);
    if (!proxy) {
      proxy = createProxyMiddleware<Request, Response>({
        target,
        changeOrigin: true,
        on: {
          error: (_error, _req, res) => {
            (res as Response).status(503).json({
              statusCode: 503,
              code: 'SERVICE_UNAVAILABLE',
              message: 'Servicio no disponible, intenta de nuevo en unos segundos',
              timestamp: new Date().toISOString(),
            });
          },
        },
      });
      this.proxies.set(target, proxy);
    }
    return proxy;
  }
}
