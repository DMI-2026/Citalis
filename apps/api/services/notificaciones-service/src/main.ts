import { bootstrapService } from '@backend/utils';
import { AppModule } from './app.module';

void bootstrapService({
  module: AppModule,
  name: 'notificaciones-service',
  description:
    'Preferencias de notificación, tokens FCM por dispositivo y envío de recordatorios de citas.',
});
