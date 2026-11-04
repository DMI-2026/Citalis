import { bootstrapService } from '@backend/utils';
import { AppModule } from './app.module';

void bootstrapService({
  module: AppModule,
  name: 'negocios-service',
  description:
    'Perfil del negocio, catálogo de servicios, imágenes, código QR/deep link y catálogos (categorías y municipios).',
});
