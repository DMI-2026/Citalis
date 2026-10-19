import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { UserEntity } from '../../domain/entities/user.entity';

export class UserResponseDto {
  @ApiProperty({ format: 'uuid' })
  id!: string;

  @ApiProperty({ example: 'maria@correo.com' })
  email!: string;

  @ApiProperty({ example: 'María García' })
  name!: string;

  @ApiPropertyOptional({ nullable: true })
  phone!: string | null;

  @ApiPropertyOptional({ nullable: true })
  defaultCity!: string | null;

  @ApiProperty()
  createdAt!: Date;

  static from(user: UserEntity): UserResponseDto {
    return {
      id: user.id,
      email: user.email,
      name: user.name,
      phone: user.phone,
      defaultCity: user.defaultCity,
      createdAt: user.createdAt,
    };
  }
}
