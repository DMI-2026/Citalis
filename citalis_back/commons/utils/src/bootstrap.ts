import { Logger, Type, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { SERVICE_PORTS, ServiceName } from '@backend/contracts';
import { JsonLogger, RequestLoggingInterceptor } from '@backend/observability';
import { assertRequiredEnv, assertStrongSecret, isSwaggerEnabled, loadRootEnv } from './env';
import { GlobalHttpExceptionFilter } from './http-exception.filter';

export interface BootstrapOptions {
  module: Type<unknown>;
  name: ServiceName;
  /** Descripción que aparece en Swagger. */
  description: string;
  /** Variables extra obligatorias además de DATABASE_URL e INTERNAL_API_TOKEN. */
  requiredEnv?: string[];
}

/**
 * Arranque ÚNICO de todos los microservicios (`main.ts` solo llama a esta función).
 * Garantiza que todos tengan el mismo comportamiento: .env raíz, variables obligatorias,
 * ValidationPipe estricto, formato de error estándar, logs sin datos sensibles, Swagger
 * solo en desarrollo y cierre ordenado.
 *
 * Regla: ningún módulo lee `process.env` al importarse; solo dentro de providers o funciones.
 */
export async function bootstrapService(options: BootstrapOptions): Promise<void> {
  loadRootEnv();
  assertRequiredEnv(options.name, [
    'DATABASE_URL',
    'INTERNAL_API_TOKEN',
    ...(options.requiredEnv ?? []),
  ]);
  assertStrongSecret(options.name, 'INTERNAL_API_TOKEN');

  const production = process.env.NODE_ENV === 'production';
  const app = await NestFactory.create(
    options.module,
    production ? { logger: new JsonLogger(options.name) } : {},
  );

  app.useGlobalPipes(
    new ValidationPipe({ whitelist: true, forbidNonWhitelisted: true, transform: true }),
  );
  app.useGlobalFilters(new GlobalHttpExceptionFilter());
  app.useGlobalInterceptors(new RequestLoggingInterceptor());
  app.enableShutdownHooks();

  if (isSwaggerEnabled()) {
    const config = new DocumentBuilder()
      .setTitle(options.name)
      .setDescription(options.description)
      .setVersion('1.0')
      .addBearerAuth()
      .build();
    SwaggerModule.setup('docs', app, SwaggerModule.createDocument(app, config));
  }

  const port = Number(process.env.PORT ?? SERVICE_PORTS[options.name]);
  await app.listen(port);
  new Logger('Bootstrap').log(`${options.name} escuchando en el puerto ${port}`);
}
