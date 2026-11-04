import { Module } from '@nestjs/common';
import { UsersService } from '../application/use-cases/users.service';
import { USER_REPOSITORY } from '../domain/repositories/user.repository.interface';
import { PrismaUserRepository } from '../infrastructure/persistence/prisma-user.repository';
import { AuthController } from './auth.controller';
import { InternalUsersController } from './internal-users.controller';
import { UsersController } from './users.controller';

@Module({
  controllers: [AuthController, UsersController, InternalUsersController],
  providers: [UsersService, { provide: USER_REPOSITORY, useClass: PrismaUserRepository }],
  exports: [UsersService],
})
export class UsersModule {}
