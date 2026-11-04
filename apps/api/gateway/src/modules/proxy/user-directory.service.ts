import { Injectable } from '@nestjs/common';
import type { InternalUserDto } from '@backend/contracts';
import { InternalServiceClient, serviceUrl } from '@backend/utils';

const MAX_CACHE_ENTRIES = 5000;

/**
 * Traduce el UID de Firebase al id interno del usuario consultando a auth-service
 * (dueño de `auth.users`). Solo se cachean los usuarios encontrados, durante
 * `USER_CACHE_TTL_MS` (30 s por defecto): así un registro recién hecho se reconoce
 * de inmediato y una baja deja de funcionar en cuanto expira la entrada.
 */
@Injectable()
export class UserDirectoryService {
  private readonly cache = new Map<string, { userId: string; expiresAt: number }>();
  private client?: InternalServiceClient;

  async findUserId(firebaseUid: string): Promise<string | null> {
    const hit = this.cache.get(firebaseUid);
    if (hit && hit.expiresAt > Date.now()) return hit.userId;

    this.client ??= new InternalServiceClient('auth-service', serviceUrl('auth-service'));
    const user = await this.client.getOrNull<InternalUserDto>(
      `/internal/users/by-firebase-uid/${encodeURIComponent(firebaseUid)}`,
    );
    if (!user) {
      this.cache.delete(firebaseUid);
      return null;
    }

    if (this.cache.size >= MAX_CACHE_ENTRIES) this.cache.clear();
    const ttl = Number(process.env.USER_CACHE_TTL_MS ?? 30_000);
    this.cache.set(firebaseUid, { userId: user.id, expiresAt: Date.now() + ttl });
    return user.id;
  }
}
