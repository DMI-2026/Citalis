import { NotFoundException } from '@nestjs/common';
import { buildHealthReport, buildTestReport, reportStatusCode } from './test-report';

describe('buildTestReport', () => {
  const base = { service: 'demo-service', schema: 'demo' };

  afterEach(() => {
    delete process.env.ENABLE_TEST_ENDPOINTS;
  });

  it('reporta ok con latencia y conteos cuando la BD responde', async () => {
    const report = await buildTestReport({
      ...base,
      ping: async () => 1,
      tables: { things: async () => 3 },
    });
    expect(report.status).toBe('ok');
    expect(report.database).toMatchObject({
      connected: true,
      schema: 'demo',
      tables: { things: 3 },
    });
    expect(report.database.latencyMs).toEqual(expect.any(Number));
    expect(reportStatusCode(report)).toBe(200);
  });

  it('reporta error (503) y no revela el motivo si la BD no responde', async () => {
    const report = await buildTestReport({
      ...base,
      ping: async () => {
        throw new Error('password authentication failed for user "x"');
      },
      tables: { things: async () => 3 },
    });
    expect(report.status).toBe('error');
    expect(report.database).toMatchObject({
      connected: false,
      latencyMs: null,
      tables: { things: null },
    });
    expect(JSON.stringify(report)).not.toContain('password');
    expect(reportStatusCode(report)).toBe(503);
  });

  it('reporta error si el schema no tiene la tabla (migración pendiente)', async () => {
    const report = await buildTestReport({
      ...base,
      ping: async () => 1,
      tables: {
        things: async () => {
          throw new Error('relation does not exist');
        },
      },
    });
    expect(report.status).toBe('error');
    expect(report.database.connected).toBe(true);
    expect(report.database.tables.things).toBeNull();
  });

  it('responde 404 si los endpoints de prueba están deshabilitados', async () => {
    process.env.ENABLE_TEST_ENDPOINTS = 'false';
    await expect(
      buildTestReport({ ...base, ping: async () => 1, tables: {} }),
    ).rejects.toBeInstanceOf(NotFoundException);
  });
});

describe('buildHealthReport', () => {
  it('marca database=down cuando el ping falla', async () => {
    const report = await buildHealthReport('demo-service', async () => {
      throw new Error('boom');
    });
    expect(report).toMatchObject({ status: 'error', checks: { database: 'down' } });
  });

  it('marca ok cuando el ping responde', async () => {
    const report = await buildHealthReport('demo-service', async () => 1);
    expect(report).toMatchObject({
      status: 'ok',
      service: 'demo-service',
      checks: { database: 'up' },
    });
  });
});
