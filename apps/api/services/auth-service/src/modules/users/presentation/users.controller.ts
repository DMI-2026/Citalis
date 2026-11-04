import { Controller, Get } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import type { RequestUser } from '@backend/contracts';
import { CurrentUser } from '@backend/security';
import { UserResponseDto } from '../application/dto/user-response.dto';
import { UsersService } from '../application/use-cases/users.service';

@ApiTags('users')
@ApiBearerAuth()
@Controller('users')
export class UsersController {
  constructor(private readonly users: UsersService) {}

  @Get('me')
  @ApiOperation({
    summary: 'Perfil del usuario autenticado; también restaura la sesión (Req 1.3, 7.1)',
  })
  @ApiResponse({ status: 200, type: UserResponseDto })
  @ApiResponse({ status: 401, description: 'Token ausente, inválido o expirado' })
  @ApiResponse({ status: 403, description: 'Token válido pero el usuario no está registrado' })
  async me(@CurrentUser() user: RequestUser): Promise<UserResponseDto> {
    return UserResponseDto.from(await this.users.getProfile(user.userId));
  }
}
