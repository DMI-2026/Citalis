import { bootstrapService } from '@backend/utils';
import { AppModule } from './app.module';

void bootstrapService({
  module: AppModule,
  name: 'agenda-service',
  description:
    'Horarios del negocio, cálculo de disponibilidad y ciclo de vida de las reservas (sin traslapes).',
});
