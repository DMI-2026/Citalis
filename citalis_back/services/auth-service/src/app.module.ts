import { Module } from '@nestjs/common';
import { SecurityModule } from '@backend/security';
import { PrismaModule } from './prisma.module';
import { HealthModule } from './modules/health/health.module';
import { UsersModule } from './modules/users/presentation/users.module';

// HealthModule va ANTES de los módulos de dominio: `GET /auth/test` debe resolverse
// antes que cualquier ruta con parámetro (`/auth/:id`).
@Module({
  imports: [SecurityModule, PrismaModule, HealthModule, UsersModule],
})
export class AppModule {}
