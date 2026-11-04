import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { GatewayAuthGuard } from './gateway-auth.guard';

/** Importar UNA vez en el `AppModule` de cada servicio: activa el guard global. */
@Module({ providers: [{ provide: APP_GUARD, useClass: GatewayAuthGuard }] })
export class SecurityModule {}
