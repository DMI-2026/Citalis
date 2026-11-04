import { TestController } from './test.controller';

describe('TestController (negocios-service)', () => {
  const makeRes = () => ({ status: jest.fn() }) as any;
  const prismaOk = {
    $queryRaw: jest.fn().mockResolvedValue([{ '?column?': 1 }]),
    business: { count: jest.fn().mockResolvedValue(2) },
    service: { count: jest.fn().mockResolvedValue(2) },
    businessCategory: { count: jest.fn().mockResolvedValue(2) },
  } as any;

  it('responde 200 con status ok cuando la BD y el schema están disponibles', async () => {
    const res = makeRes();
    const report = await new TestController(prismaOk).test(res);
    expect(report).toMatchObject({
      service: 'negocios-service',
      status: 'ok',
      database: { connected: true, schema: 'negocios' },
    });
    expect(res.status).toHaveBeenCalledWith(200);
  });

  it('responde 503 cuando la BD no está disponible', async () => {
    const res = makeRes();
    const prismaDown = { ...prismaOk, $queryRaw: jest.fn().mockRejectedValue(new Error('down')) };
    const report = await new TestController(prismaDown).test(res);
    expect(report.status).toBe('error');
    expect(report.database.connected).toBe(false);
    expect(res.status).toHaveBeenCalledWith(503);
  });
});
