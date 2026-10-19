import { Controller, Get, Param } from '@nestjs/common';
import { ApiExcludeController } from '@nestjs/swagger';
import type { InternalUserDto } from '@backend/contracts';
import { InternalOnly } from '@backend/security';
import { UsersService } from '../application/use-cases/users.service';

/**
 * Rutas `/internal/*`: solo servicio a servicio (exigen `x-internal-token`).
 * El gateway las bloquea hacia el exterior y no aparecen en Swagger.
 */
@ApiExcludeController()
@InternalOnly()
@Controller('internal/users')
export class InternalUsersController {
  constructor(private readonly users: UsersService) {}

  /** Lo consume el gateway para traducir el UID de Firebase al id interno. */
  @Get('by-firebase-uid/:firebaseUid')
  async byFirebaseUid(@Param('firebaseUid') firebaseUid: string): Promise<InternalUserDto> {
    const user = await this.users.findByFirebaseUid(firebaseUid);
    return {
      id: user.id,
      firebaseUid: user.firebaseUid,
      email: user.email,
      name: user.name,
      phone: user.phone,
    };
  }
}
