import { Injectable } from '@nestjs/common';
import { withNotDeleted } from '@backend/utils';
import { PrismaService } from '../../../../config/prisma.service';
import {
  CreateUserData,
  UserAlreadyExistsError,
  UserEntity,
} from '../../domain/entities/user.entity';
import { IUserRepository } from '../../domain/repositories/user.repository.interface';

/** Prisma unique constraint violation. */
const UNIQUE_VIOLATION = 'P2002';

@Injectable()
export class PrismaUserRepository implements IUserRepository {
  constructor(private readonly prisma: PrismaService) {}

  findById(id: string): Promise<UserEntity | null> {
    return this.prisma.user.findFirst({ where: { id, ...withNotDeleted() } });
  }

  findByFirebaseUid(firebaseUid: string): Promise<UserEntity | null> {
    return this.prisma.user.findFirst({ where: { firebaseUid, ...withNotDeleted() } });
  }

  findByEmail(email: string): Promise<UserEntity | null> {
    return this.prisma.user.findFirst({ where: { email, ...withNotDeleted() } });
  }

  async create(data: CreateUserData): Promise<UserEntity> {
    try {
      return await this.prisma.user.create({ data });
    } catch (error) {
      if ((error as { code?: string }).code === UNIQUE_VIOLATION)
        throw new UserAlreadyExistsError();
      throw error;
    }
  }
}
