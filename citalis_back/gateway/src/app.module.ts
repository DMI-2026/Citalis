import { Module } from '@nestjs/common';
import { FirebaseModule } from '@backend/firebase';
import { HealthModule } from './modules/health/health.module';
import { ProxyModule } from './modules/proxy/proxy.module';

@Module({
  imports: [FirebaseModule, HealthModule, ProxyModule],
})
export class AppModule {}
