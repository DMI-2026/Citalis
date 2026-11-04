import { bootstrapService } from '@backend/utils';
import { AppModule } from './app.module';

void bootstrapService({
  module: AppModule,
  name: 'clientes-service',
  description: 'Directorio de clientes por negocio, historial de citas y valoraciones.',
});
