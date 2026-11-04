/** Entidad de dominio: TypeScript puro, sin decoradores ni dependencias de Prisma. */
export interface UserEntity {
  id: string;
  email: string;
  firebaseUid: string | null;
  name: string;
  phone: string | null;
  defaultCity: string | null;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateUserData {
  email: string;
  firebaseUid: string;
  name: string;
  phone?: string | null;
}

/** El correo o el UID de Firebase ya pertenecen a otra cuenta. */
export class UserAlreadyExistsError extends Error {
  constructor() {
    super('USER_ALREADY_EXISTS');
  }
}
