import axios, { AxiosAdapter, AxiosError, AxiosResponse, InternalAxiosRequestConfig } from 'axios';
import { ExternalServiceException, ResilientHttpClient } from './http-client';

type Step = (config: InternalAxiosRequestConfig) => AxiosResponse | AxiosError;

function clientWith(steps: Step[], retries = 1) {
  const calls: InternalAxiosRequestConfig[] = [];
  const adapter: AxiosAdapter = async (config) => {
    calls.push(config);
    const result = (steps[calls.length - 1] ?? steps[steps.length - 1])(config);
    if (result instanceof Error) throw result;
    return result;
  };
  const http = axios.create({ baseURL: 'http://api.test', adapter });
  return {
    client: new ResilientHttpClient({ name: 'geocoding', baseUrl: 'x', retries }, http),
    calls,
  };
}

const ok =
  (data: unknown): Step =>
  (config) => ({ data, status: 200, statusText: 'OK', headers: {}, config });
const status =
  (code: number): Step =>
  (config) =>
    new AxiosError('fail', 'ERR_BAD_RESPONSE', config, null, {
      data: { secret: 'no-debe-filtrarse' },
      status: code,
      statusText: '',
      headers: {},
      config,
    });
const timeout: Step = (config) => new AxiosError('timeout', 'ECONNABORTED', config);
const networkDown: Step = (config) => new AxiosError('down', 'ECONNREFUSED', config);

async function failureOf(promise: Promise<unknown>): Promise<ExternalServiceException> {
  try {
    await promise;
  } catch (error) {
    return error as ExternalServiceException;
  }
  throw new Error('se esperaba que la llamada fallara');
}

describe('ResilientHttpClient', () => {
  it('devuelve el cuerpo de una respuesta exitosa', async () => {
    const { client } = clientWith([ok({ lat: 18.9 })]);
    await expect(client.get('/geo')).resolves.toEqual({ lat: 18.9 });
  });

  it('reintenta un GET tras un timeout y se recupera', async () => {
    const { client, calls } = clientWith([timeout, ok({ done: true })]);
    await expect(client.get('/geo')).resolves.toEqual({ done: true });
    expect(calls).toHaveLength(2);
  });

  it('lanza 504 cuando se agota el tiempo en todos los intentos', async () => {
    const { client } = clientWith([timeout]);
    await expect(client.get('/geo')).rejects.toMatchObject({ failure: 'timeout' });
    await expect(client.get('/geo')).rejects.toBeInstanceOf(ExternalServiceException);
  });

  it('lanza 502 si el servicio no está disponible', async () => {
    const { client } = clientWith([networkDown], 0);
    const error = await failureOf(client.get('/geo'));
    expect(error.getStatus()).toBe(502);
    expect(error.failure).toBe('unavailable');
  });

  it('no reintenta ante 4xx (datos inválidos) y no filtra el cuerpo del upstream', async () => {
    const { client, calls } = clientWith([status(400)]);
    const error = await failureOf(client.get('/geo'));
    expect(calls).toHaveLength(1);
    expect(error.upstreamStatus).toBe(400);
    expect(JSON.stringify(error.getResponse())).not.toContain('no-debe-filtrarse');
  });

  it('no reintenta POST aunque falle (evita duplicar escrituras)', async () => {
    const { client, calls } = clientWith([timeout]);
    await expect(client.post('/reservations', {})).rejects.toBeInstanceOf(ExternalServiceException);
    expect(calls).toHaveLength(1);
  });

  it('getOrNull devuelve null ante un 404', async () => {
    const { client } = clientWith([status(404)]);
    await expect(client.getOrNull('/users/x')).resolves.toBeNull();
  });
});
