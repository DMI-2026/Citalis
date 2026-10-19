import { Logger } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import { NestExpressApplication } from '@nestjs/platform-express';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import helmet from 'helmet';
import { rateLimit } from 'express-rate-limit';
import { JsonLogger } from '@backend/observability';
import {
  GlobalHttpExceptionFilter,
  assertRequiredEnv,
  assertStrongSecret,
  isSwaggerEnabled,
  loadRootEnv,
} from '@backend/utils';
import { AppModule } from './app.module';

async function bootstrap() {
  loadRootEnv();
  assertRequiredEnv('gateway', ['INTERNAL_API_TOKEN', 'FIREBASE_PROJECT_ID']);
  assertStrongSecret('gateway', 'INTERNAL_API_TOKEN');

  const production = process.env.NODE_ENV === 'production';

  // bodyParser: false — el gateway es un proxy puro. Si Nest parsea el body, el stream
  // queda consumido y http-proxy-middleware no puede reenviarlo al microservicio.
  const app = await NestFactory.create<NestExpressApplication>(AppModule, {
    bodyParser: false,
    ...(production ? { logger: new JsonLogger('gateway') } : {}),
  });

  // Detrás de un balanceador/Nginx con TLS (rúbrica S2) hay que confiar en X-Forwarded-*.
  if (process.env.TRUST_PROXY) app.set('trust proxy', Number(process.env.TRUST_PROXY));

  // Swagger UI necesita scripts inline: solo se relaja el CSP cuando /docs está activo.
  app.use(helmet({ contentSecurityPolicy: isSwaggerEnabled() ? false : undefined }));

  // Rate limiting sobre TODO el tráfico que pasa por el proxy (los guards de Nest no
  // alcanzan a las rutas atendidas por middleware, por eso se usa express-rate-limit).
  app.use(
    rateLimit({
      windowMs: Number(process.env.THROTTLE_TTL ?? 60) * 1000,
      limit: Number(process.env.THROTTLE_LIMIT ?? 200),
      standardHeaders: 'draft-7',
      legacyHeaders: false,
      message: {
        statusCode: 429,
        code: 'TOO_MANY_REQUESTS',
        message: 'Demasiadas solicitudes, intenta de nuevo en unos minutos',
      },
    }),
  );

  // CORS con lista blanca (solo aplica a Flutter Web; la app móvil no usa CORS).
  const origins = (process.env.CORS_ORIGINS ?? 'http://localhost:8080')
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean);
  app.enableCors({
    origin: origins,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Authorization', 'Content-Type', 'Idempotency-Key'],
  });

  app.useGlobalFilters(new GlobalHttpExceptionFilter());
  app.enableShutdownHooks();

  if (isSwaggerEnabled()) {
    const config = new DocumentBuilder()
      .setTitle('Citalis API Gateway')
      .setVersion('1.0')
      .setDescription(
        'Punto de entrada único del backend de Citalis. Verifica el token de Firebase y enruta ' +
          'a los microservicios. Swagger de cada servicio: http://localhost:300N/docs ' +
          '(auth 3001, negocios 3002, agenda 3003, clientes 3004, descubrimiento 3005, notificaciones 3006).',
      )
      .addBearerAuth()
      .build();
    SwaggerModule.setup('docs', app, SwaggerModule.createDocument(app, config));
  }

  const port = Number(process.env.PORT ?? 3000);
  await app.listen(port);
  new Logger('Bootstrap').log(`gateway escuchando en el puerto ${port}`);
}

void bootstrap();
