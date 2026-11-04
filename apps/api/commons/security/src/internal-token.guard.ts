import { timingSafeEqual } from 'crypto';
import { CanActivate, ExecutionContext, Injectable, UnauthorizedException } from '@nestjs/common';
import { INTERNAL_TOKEN_HEADER } from '@backend/contracts';

/** Comparación en tiempo constante del secreto interno. */
export function isValidInternalToken(received: unknown): boolean {
  const expected = process.env.INTERNAL_API_TOKEN;
  if (!expected || typeof received !== 'string') return false;
  const a = Buffer.from(received);
  const b = Buffer.from(expected);
  return a.length === b.length && timingSafeEqual(a, b);
}

/** Protege `/internal/*`: exige `x-internal-token` igual a `INTERNAL_API_TOKEN`. */
@Injectable()
export class InternalTokenGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const req = context.switchToHttp().getRequest<{ headers: Record<string, unknown> }>();
    if (!isValidInternalToken(req.headers[INTERNAL_TOKEN_HEADER])) {
      throw new UnauthorizedException('INVALID_INTERNAL_TOKEN');
    }
    return true;
  }
}
