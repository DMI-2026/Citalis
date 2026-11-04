import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsOptional, IsString, Matches, MaxLength, MinLength } from 'class-validator';

const trim = ({ value }: { value: unknown }) => (typeof value === 'string' ? value.trim() : value);

/**
 * Datos del registro (Req 1.1). El correo y la contraseña NO viajan aquí: la cuenta ya fue
 * creada en Firebase Auth por la app y el correo se toma del token verificado por el gateway.
 */
export class RegisterDto {
  @ApiProperty({ example: 'María García', minLength: 2, maxLength: 120 })
  @Transform(trim)
  @IsString()
  @MinLength(2)
  @MaxLength(120)
  @Matches(/^[\p{L}\p{M}][\p{L}\p{M}' .-]*$/u, { message: 'name contiene caracteres no válidos' })
  name!: string;

  @ApiPropertyOptional({ example: '+52 777 234 5678' })
  @IsOptional()
  @Transform(trim)
  @IsString()
  @Matches(/^\+?[0-9 ()-]{7,20}$/, { message: 'phone no es un teléfono válido' })
  phone?: string;
}
