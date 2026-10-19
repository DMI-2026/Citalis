import { Module } from '@nestjs/common';
import { SecurityModule } from '@backend/security';
import { PrismaModule } from './prisma.module';
import { HealthModule } from './modules/health/health.module';

// HealthModule va ANTES de los módulos de dominio: `GET /businesses/test` debe resolverse
// antes que cualquier ruta con parámetro (`/businesses/:id`).
@Module({
  imports: [SecurityModule, PrismaModule, HealthModule],
})
export class AppModule {}
