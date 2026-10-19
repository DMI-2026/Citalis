import {
  BadRequestException,
  ConflictException,
  Inject,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import type { FirebaseIdentity } from '@backend/contracts';
import { UserAlreadyExistsError, UserEntity } from '../../domain/entities/user.entity';
import {
  IUserRepository,
  USER_REPOSITORY,
} from '../../domain/repositories/user.repository.interface';
import { RegisterDto } from '../dto/register.dto';

export interface RegisterResult {
  user: UserEntity;
  /** `false` cuando el usuario ya estaba registrado (reintento idempotente, Req 6.3). */
  created: boolean;
}

@Injectable()
export class UsersService {
  constructor(@Inject(USER_REPOSITORY) private readonly users: IUserRepository) {}

  /**
   * Alta del usuario en Citalis a partir de una identidad Firebase ya verificada (Req 1.1).
   * Idempotente: si ese UID ya está registrado devuelve el usuario existente, de modo que
   * reintentar tras un corte de red nunca duplica ni falla.
   */
  async register(identity: FirebaseIdentity, dto: RegisterDto): Promise<RegisterResult> {
    if (!identity.email) {
      throw new BadRequestException({
        code: 'EMAIL_REQUIRED',
        message: 'La cuenta de Firebase no tiene un correo asociado',
      });
    }

    const existing = await this.users.findByFirebaseUid(identity.firebaseUid);
    if (existing) return { user: existing, created: false };

    // Un correo no puede pertenecer a dos cuentas (regla de negocio 1.1).
    if (await this.users.findByEmail(identity.email)) throw this.alreadyExists();

    try {
      const user = await this.users.create({
        email: identity.email,
        firebaseUid: identity.firebaseUid,
        name: dto.name,
        phone: dto.phone ?? null,
      });
      return { user, created: true };
    } catch (error) {
      if (error instanceof UserAlreadyExistsError) throw this.alreadyExists();
      throw error;
    }
  }

  async getProfile(userId: string): Promise<UserEntity> {
    const user = await this.users.findById(userId);
    if (!user)
      throw new NotFoundException({ code: 'USER_NOT_FOUND', message: 'Usuario no encontrado' });
    return user;
  }

  /** Consulta interna del gateway: ¿qué usuario es este UID de Firebase? */
  async findByFirebaseUid(firebaseUid: string): Promise<UserEntity> {
    const user = await this.users.findByFirebaseUid(firebaseUid);
    if (!user)
      throw new NotFoundException({ code: 'USER_NOT_FOUND', message: 'Usuario no encontrado' });
    return user;
  }

  private alreadyExists() {
    return new ConflictException({
      code: 'ACCOUNT_ALREADY_EXISTS',
      message: 'Ya existe una cuenta con ese correo',
    });
  }
}
