import { Controller, Get, Res } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import type { Response } from 'express';
import { SERVICE_ROUTE_PREFIX } from '@backend/contracts';
import { Public } from '@backend/security';
import { buildTestReport, reportStatusCode } from '@backend/utils';
import { PrismaService } from '../../config/prisma.service';

/**
 * Endpoint de prueba: `GET /auth/test`.
 * Confirma que el servicio responde, que la BD es alcanzable y que el schema `auth`
 * existe con sus tablas (migraciones aplicadas). Se desactiva en producción con
 * `ENABLE_TEST_ENDPOINTS=false`.
 */
@ApiTags('test')
@Controller(`${SERVICE_ROUTE_PREFIX['auth-service']}/test`)
export class TestController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @Public()
  @ApiOperation({ summary: 'Prueba de conexión a la BD y de respuesta del servicio' })
  @ApiResponse({ status: 200, description: 'Servicio y BD operativos' })
  @ApiResponse({ status: 503, description: 'BD no disponible o migraciones pendientes' })
  @ApiResponse({ status: 404, description: 'Endpoints de prueba deshabilitados' })
  async test(@Res({ passthrough: true }) res: Response) {
    const report = await buildTestReport({
      service: 'auth-service',
      schema: 'auth',
      ping: () => this.prisma.$queryRaw`SELECT 1`,
      tables: {
        users: () => this.prisma.user.count(),
        audit_log: () => this.prisma.auditLog.count(),
      },
    });
    res.status(reportStatusCode(report));
    return report;
  }
}
