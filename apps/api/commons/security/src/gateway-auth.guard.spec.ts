import 'reflect-metadata';
import { ExecutionContext, ForbiddenException, UnauthorizedException } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { GatewayAuthGuard } from './gateway-auth.guard';
import { AllowUnregistered, Public } from './decorators';

class SampleController {
  @Public()
  open() {}

  @AllowUnregistered()
  register() {}

  protectedRoute() {}
}

function ctx(handler: () => void, headers: Record<string, string>) {
  const req: any = { headers };
  const context = {
    getHandler: () => handler,
    getClass: () => SampleController,
    switchToHttp: () => ({ getRequest: () => req }),
  } as unknown as ExecutionContext;
  return { context, req };
}

describe('GatewayAuthGuard', () => {
  const guard = new GatewayAuthGuard(new Reflector());
  const proto = SampleController.prototype;
  const full = {
    'x-internal-token': 'secreto-interno',
    'x-firebase-uid': 'uid1',
    'x-user-id': 'u-1',
    'x-user-email': 'a@b.com',
  };

  beforeEach(() => {
    process.env.INTERNAL_API_TOKEN = 'secreto-interno';
  });

  it('deja pasar los endpoints @Public sin cabeceras', () => {
    expect(guard.canActivate(ctx(proto.open, {}).context)).toBe(true);
  });

  it('rechaza (401) si falta o es incorrecto el token interno', () => {
    const wrong = ctx(proto.protectedRoute, { ...full, 'x-internal-token': 'otro' });
    expect(() => guard.canActivate(wrong.context)).toThrow(UnauthorizedException);
    expect(() => guard.canActivate(ctx(proto.protectedRoute, {}).context)).toThrow(
      UnauthorizedException,
    );
  });

  it('rechaza (401) si no hay identidad Firebase', () => {
    const headers: Record<string, string> = { ...full };
    delete headers['x-firebase-uid'];
    expect(() => guard.canActivate(ctx(proto.protectedRoute, headers).context)).toThrow(
      UnauthorizedException,
    );
  });

  it('puebla request.user con la identidad del gateway', () => {
    const { context, req } = ctx(proto.protectedRoute, full);
    expect(guard.canActivate(context)).toBe(true);
    expect(req.user).toEqual({ firebaseUid: 'uid1', email: 'a@b.com', userId: 'u-1' });
  });

  it('rechaza (403) a un usuario no registrado salvo @AllowUnregistered', () => {
    const headers: Record<string, string> = { ...full };
    delete headers['x-user-id'];
    expect(() => guard.canActivate(ctx(proto.protectedRoute, headers).context)).toThrow(
      ForbiddenException,
    );
    const { context, req } = ctx(proto.register, headers);
    expect(guard.canActivate(context)).toBe(true);
    expect(req.user).toBeUndefined();
    expect(req.identity.firebaseUid).toBe('uid1');
  });
});
