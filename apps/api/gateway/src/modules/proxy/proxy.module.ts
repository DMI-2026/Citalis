import { MiddlewareConsumer, Module, NestModule, RequestMethod } from '@nestjs/common';
import { ProxyMiddleware } from './proxy.middleware';
import { UserDirectoryService } from './user-directory.service';

@Module({ providers: [ProxyMiddleware, UserDirectoryService] })
export class ProxyModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(ProxyMiddleware)
      // /health lo atiende el HealthController del propio gateway (estado agregado).
      .exclude({ path: 'health', method: RequestMethod.ALL })
      .forRoutes({ path: '*', method: RequestMethod.ALL });
  }
}
