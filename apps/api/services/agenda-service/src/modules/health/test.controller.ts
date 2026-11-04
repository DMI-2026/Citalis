import { Controller, Get, Res } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import type { Response } from 'express';
import { SERVICE_ROUTE_PREFIX } from '@backend/contracts';
import { Public } from '@backend/security';
import { buildTestReport, reportStatusCode } from '@backend/utils';
import { PrismaService } from '../../config/prisma.service';

/**
 * Endpoint de prueba: `GET /reservations/test`.
 * Confirma que el servicio responde, que la BD es alcanzable y que el schema `agenda`
 * existe con sus tablas (migraciones aplicadas). Se desactiva en producción con
 * `ENABLE_TEST_ENDPOINTS=false`.
 */
@ApiTags('test')
@Controller(`${SERVICE_ROUTE_PREFIX['agenda-service']}/test`)
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
      service: 'agenda-service',
      schema: 'agenda',
      ping: () => this.prisma.$queryRaw`SELECT 1`,
      tables: {
        reservations: () => this.prisma.reservation.count(),
        business_hours: () => this.prisma.businessHour.count(),
        business_hour_exceptions: () => this.prisma.businessHourException.count(),
      },
    });
    res.status(reportStatusCode(report));
    return report;
  }
}
