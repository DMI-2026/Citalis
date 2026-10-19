import { HttpException, Logger } from '@nestjs/common';
import axios, { AxiosError, AxiosInstance, AxiosRequestConfig } from 'axios';
import { INTERNAL_TOKEN_HEADER } from '@backend/contracts';

export type ExternalFailure = 'timeout' | 'unavailable' | 'bad_response';

/**
 * Falla de un servicio vecino o de una API de terceros.
 * 504 si se agotó el tiempo, 502 en cualquier otro caso. El mensaje es genérico:
 * nunca incluye URLs, claves ni cuerpos del upstream (rúbricas F3 y S5).
 */
export class ExternalServiceException extends HttpException {
  constructor(
    readonly target: string,
    readonly failure: ExternalFailure,
    readonly upstreamStatus?: number,
  ) {
    super(
      {
        code: failure === 'timeout' ? 'EXTERNAL_SERVICE_TIMEOUT' : 'EXTERNAL_SERVICE_ERROR',
        message: `El servicio externo "${target}" no respondió correctamente`,
      },
      failure === 'timeout' ? 504 : 502,
    );
  }
}

export interface HttpClientOptions {
  /** Nombre lógico para logs y errores (`geocoding`, `negocios-service`...). */
  name: string;
  baseUrl: string;
  /** Tiempo máximo por intento. Por defecto 5 s. */
  timeoutMs?: number;
  /** Reintentos SOLO para GET ante timeout, red caída o 5xx. Por defecto 1. */
  retries?: number;
  /** Cabeceras fijas (ej. `User-Agent`). Las credenciales van en `dynamicHeaders`. */
  headers?: Record<string, string>;
  /** Cabeceras calculadas en cada request (ej. API key leída de variables de entorno). */
  dynamicHeaders?: () => Record<string, string>;
}

/**
 * Cliente HTTP base para TODO lo que salga del servicio: APIs de terceros (F3) y
 * llamadas a otros microservicios. Aporta timeout, reintento controlado y
 * traducción de errores. Los http-clients de cada servicio lo ENVUELVEN
 * (`infrastructure/http-clients/*.http-client.ts`); no se usa axios directo.
 */
export class ResilientHttpClient {
  private readonly logger: Logger;
  private readonly http: AxiosInstance;
  private readonly retries: number;

  constructor(
    private readonly options: HttpClientOptions,
    http?: AxiosInstance,
  ) {
    this.logger = new Logger(`HttpClient:${options.name}`);
    this.retries = options.retries ?? 1;
    this.http =
      http ??
      axios.create({
        baseURL: options.baseUrl,
        timeout: options.timeoutMs ?? 5000,
        headers: options.headers,
      });
    if (options.dynamicHeaders) {
      this.http.interceptors.request.use((config) => {
        for (const [key, value] of Object.entries(options.dynamicHeaders?.() ?? {})) {
          config.headers.set(key, value);
        }
        return config;
      });
    }
  }

  get<T>(path: string, config?: AxiosRequestConfig): Promise<T> {
    return this.send<T>({ ...config, method: 'GET', url: path }, this.retries);
  }

  /** Como `get`, pero devuelve `null` si el upstream responde 404. */
  async getOrNull<T>(path: string, config?: AxiosRequestConfig): Promise<T | null> {
    try {
      return await this.get<T>(path, config);
    } catch (error) {
      if (error instanceof ExternalServiceException && error.upstreamStatus === 404) return null;
      throw error;
    }
  }

  post<T>(path: string, body?: unknown, config?: AxiosRequestConfig): Promise<T> {
    return this.send<T>({ ...config, method: 'POST', url: path, data: body }, 0);
  }

  patch<T>(path: string, body?: unknown, config?: AxiosRequestConfig): Promise<T> {
    return this.send<T>({ ...config, method: 'PATCH', url: path, data: body }, 0);
  }

  delete<T>(path: string, config?: AxiosRequestConfig): Promise<T> {
    return this.send<T>({ ...config, method: 'DELETE', url: path }, 0);
  }

  private async send<T>(config: AxiosRequestConfig, retriesLeft: number): Promise<T> {
    try {
      const response = await this.http.request<T>(config);
      return response.data;
    } catch (error) {
      const failure = this.classify(error);
      const retryable = failure.failure !== 'bad_response' || (failure.upstreamStatus ?? 0) >= 500;
      if (retriesLeft > 0 && retryable) return this.send<T>(config, retriesLeft - 1);
      // Solo método y tipo de fallo: jamás la URL completa (podría llevar claves).
      this.logger.warn(
        `${config.method} falló: ${failure.failure}${failure.upstreamStatus ? ` (${failure.upstreamStatus})` : ''}`,
      );
      throw failure;
    }
  }

  private classify(error: unknown): ExternalServiceException {
    const name = this.options.name;
    if (axios.isAxiosError(error)) {
      const axiosError = error as AxiosError;
      if (axiosError.response) {
        return new ExternalServiceException(name, 'bad_response', axiosError.response.status);
      }
      if (axiosError.code === 'ECONNABORTED' || axiosError.code === 'ETIMEDOUT') {
        return new ExternalServiceException(name, 'timeout');
      }
    }
    return new ExternalServiceException(name, 'unavailable');
  }
}

/**
 * Cliente hacia otro microservicio de Citalis: añade `x-internal-token` y consume
 * rutas `/internal/*`. Uso: `new InternalServiceClient('negocios-service', process.env.NEGOCIOS_SERVICE_URL ?? 'http://localhost:3002')`.
 */
export class InternalServiceClient extends ResilientHttpClient {
  constructor(name: string, baseUrl: string, timeoutMs = 5000) {
    super({
      name,
      baseUrl,
      timeoutMs,
      dynamicHeaders: () => ({ [INTERNAL_TOKEN_HEADER]: process.env.INTERNAL_API_TOKEN ?? '' }),
    });
  }
}
