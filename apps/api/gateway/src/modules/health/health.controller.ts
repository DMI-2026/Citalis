import { Controller, Get } from '@nestjs/common';
import { ApiOperation, ApiResponse, ApiTags } from '@nestjs/swagger';
import axios from 'axios';
import { SERVICE_PORTS, ServiceName } from '@backend/contracts';
import { serviceUrl } from '@backend/utils';

interface ServiceStatus {
  name: ServiceName;
  status: 'up' | 'down';
  latencyMs: number;
}

@ApiTags('health')
@Controller('health')
export class HealthController {
  @Get()
  @ApiOperation({ summary: 'Estado del gateway y de todos los microservicios' })
  @ApiResponse({
    status: 200,
    description: 'Gateway operativo (status "degraded" si algún servicio cae)',
  })
  async getAggregatedHealth() {
    const names = Object.keys(SERVICE_PORTS) as ServiceName[];
    const services: ServiceStatus[] = await Promise.all(
      names.map(async (name) => {
        const started = Date.now();
        try {
          await axios.get(`${serviceUrl(name)}/health`, { timeout: 3000 });
          return { name, status: 'up' as const, latencyMs: Date.now() - started };
        } catch {
          return { name, status: 'down' as const, latencyMs: Date.now() - started };
        }
      }),
    );

    return {
      status: services.every((service) => service.status === 'up') ? 'ok' : 'degraded',
      service: 'gateway',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      services,
    };
  }
}
