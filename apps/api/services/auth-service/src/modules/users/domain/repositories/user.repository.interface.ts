import { CreateUserData, UserEntity } from '../entities/user.entity';

/**
 * Contrato de acceso a datos. El caso de uso depende de esta interfaz (inyectada por el
 * token `USER_REPOSITORY`), nunca de Prisma: así se puede sustituir por una falsa en pruebas.
 */
export interface IUserRepository {
  findById(id: string): Promise<UserEntity | null>;
  findByFirebaseUid(firebaseUid: string): Promise<UserEntity | null>;
  findByEmail(email: string): Promise<UserEntity | null>;
  /** Lanza `UserAlreadyExistsError` si el correo o el UID ya existen. */
  create(data: CreateUserData): Promise<UserEntity>;
}

export const USER_REPOSITORY = Symbol('USER_REPOSITORY');
