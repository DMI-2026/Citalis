import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import {
  FIREBASE_UID_HEADER,
  FirebaseIdentity,
  INTERNAL_TOKEN_HEADER,
  RequestUser,
  USER_EMAIL_HEADER,
  USER_ID_HEADER,
} from '@backend/contracts';
import { ALLOW_UNREGISTERED_KEY, IS_PUBLIC_KEY } from './decorators';
import { isValidInternalToken } from './internal-token.guard';

type Req = {
  headers: Record<string, string | undefined>;
  user?: RequestUser;
  identity?: FirebaseIdentity;
};

/**
 * Guard global de TODOS los servicios (se registra con `SecurityModule`).
 *
 * Los servicios no validan Firebase: confían en el gateway, que ya verificó el
 * token y reenvía la identidad en cabeceras `x-*`. Para que nadie pueda falsificar
 * esas cabeceras saltándose el gateway, exigimos además `x-internal-token`.
 *
 *  - `@Public()`            → pasa sin identidad.
 *  - `@AllowUnregistered()` → basta la identidad Firebase (registro).
 *  - resto                  → exige identidad + usuario registrado (`x-user-id`).
 */
@Injectable()
export class GatewayAuthGuard implements CanActivate {
  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const targets = [context.getHandler(), context.getClass()];
    if (this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, targets)) return true;

    const req = context.switchToHttp().getRequest<Req>();
    if (!isValidInternalToken(req.headers[INTERNAL_TOKEN_HEADER])) {
      throw new UnauthorizedException('Acceso solo a través del gateway');
    }

    const firebaseUid = req.headers[FIREBASE_UID_HEADER];
    if (!firebaseUid) throw new UnauthorizedException('Token de acceso requerido');
    req.identity = { firebaseUid, email: req.headers[USER_EMAIL_HEADER] ?? null };

    const userId = req.headers[USER_ID_HEADER];
    if (userId) {
      req.user = { ...req.identity, userId };
      return true;
    }
    if (this.reflector.getAllAndOverride<boolean>(ALLOW_UNREGISTERED_KEY, targets)) return true;
    throw new ForbiddenException('USER_NOT_REGISTERED');
  }
}
