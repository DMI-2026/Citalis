import { bootstrapService } from '@backend/utils';
import { AppModule } from './app.module';

void bootstrapService({
  module: AppModule,
  name: 'auth-service',
  description:
    'Identidad de usuarios sobre Firebase Auth: registro en Citalis, perfil y consulta interna para el gateway.',
});
