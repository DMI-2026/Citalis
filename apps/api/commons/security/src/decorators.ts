import {
  ExecutionContext,
  ForbiddenException,
  SetMetadata,
  UseGuards,
  applyDecorators,
  createParamDecorator,
} from '@nestjs/common';
import type { FirebaseIdentity, RequestUser } from '@backend/contracts';
import { InternalTokenGuard } from './internal-token.guard';

export const IS_PUBLIC_KEY = 'isPublic';
export const ALLOW_UNREGISTERED_KEY = 'allowUnregistered';

/** Endpoint sin autenticación (health, test, docs). */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);

/**
 * Endpoint que exige token Firebase válido pero NO que el usuario ya exista en
 * `auth.users`. Solo para el registro (`POST /auth/register`).
 */
export const AllowUnregistered = () => SetMetadata(ALLOW_UNREGISTERED_KEY, true);

/**
 * Ruta `/internal/*` de servicio a servicio: no lleva usuario, solo el
 * `x-internal-token`. El gateway nunca la expone al exterior.
 */
export const InternalOnly = () => applyDecorators(Public(), UseGuards(InternalTokenGuard));

/** Usuario autenticado y registrado: `@CurrentUser() user: RequestUser`. */
export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): RequestUser => {
    const request = ctx.switchToHttp().getRequest<{ user?: RequestUser }>();
    if (!request.user) throw new ForbiddenException('USER_NOT_REGISTERED');
    return request.user;
  },
);

/** Identidad Firebase (aunque el usuario no esté registrado): `@CurrentIdentity()`. */
export const CurrentIdentity = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): FirebaseIdentity => {
    const request = ctx.switchToHttp().getRequest<{ identity?: FirebaseIdentity }>();
    if (!request.identity) throw new ForbiddenException('IDENTITY_REQUIRED');
    return request.identity;
  },
);
