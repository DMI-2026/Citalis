import { Body, Controller, Post, Res } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import type { Response } from 'express';
import type { FirebaseIdentity } from '@backend/contracts';
import { AllowUnregistered, CurrentIdentity } from '@backend/security';
import { RegisterDto } from '../application/dto/register.dto';
import { UserResponseDto } from '../application/dto/user-response.dto';
import { UsersService } from '../application/use-cases/users.service';

@ApiTags('auth')
@ApiBearerAuth()
@Controller('auth')
export class AuthController {
  constructor(private readonly users: UsersService) {}

  @Post('register')
  @AllowUnregistered()
  @ApiOperation({
    summary: 'Registra en Citalis al usuario ya creado en Firebase Auth (Req 1.1)',
    description:
      'Requiere el token ID de Firebase. Es idempotente: si el usuario ya existe responde 200 con sus datos.',
  })
  @ApiResponse({ status: 201, type: UserResponseDto, description: 'Cuenta creada' })
  @ApiResponse({
    status: 200,
    type: UserResponseDto,
    description: 'La cuenta ya estaba registrada',
  })
  @ApiResponse({ status: 400, description: 'Datos inválidos' })
  @ApiResponse({ status: 401, description: 'Token ausente, inválido o expirado' })
  @ApiResponse({ status: 409, description: 'Ya existe una cuenta con ese correo' })
  async register(
    @CurrentIdentity() identity: FirebaseIdentity,
    @Body() dto: RegisterDto,
    @Res({ passthrough: true }) res: Response,
  ): Promise<UserResponseDto> {
    const { user, created } = await this.users.register(identity, dto);
    res.status(created ? 201 : 200);
    return UserResponseDto.from(user);
  }
}
