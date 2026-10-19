import { bootstrapService } from '@backend/utils';
import { AppModule } from './app.module';

void bootstrapService({
  module: AppModule,
  name: 'descubrimiento-service',
  description:
    'Búsqueda de negocios, cercanía/geolocalización, API de terceros de geocodificación y favoritos.',
});
