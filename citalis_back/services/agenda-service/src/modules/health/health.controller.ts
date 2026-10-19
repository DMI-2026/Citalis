import { Controller, Get, Res } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import type { Response } from 'express';
import { Public } from '@backend/security';
import { buildHealthReport, reportStatusCode } from '@backend/utils';
import { PrismaService } from '../../config/prisma.service';

@ApiTags('health')
@Controller('health')
export class HealthController {
  constructor(private readonly prisma: PrismaService) {}

  @Get()
  @Public()
  @ApiOperation({ summary: 'Liveness del servicio y ping a la base de datos' })
  @ApiResponse({ status: 200, description: 'Servicio y base de datos operativos' })
  @ApiResponse({ status: 503, description: 'Base de datos no disponible' })
  async check(@Res({ passthrough: true }) res: Response) {
    const report = await buildHealthReport('agenda-service', () => this.prisma.$queryRaw`SELECT 1`);
    res.status(reportStatusCode(report));
    return report;
  }
}
