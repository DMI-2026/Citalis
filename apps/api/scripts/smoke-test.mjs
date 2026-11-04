#!/usr/bin/env node
/**
 * Smoke test del backend: comprueba que el gateway y los 6 microservicios responden y que
 * cada uno está conectado a su schema de la base de datos.
 *
 *   pnpm smoke                                   # contra http://localhost:3000 (gateway)
 *   GATEWAY_URL=https://api.citalis.app pnpm smoke
 *
 * Por cada servicio llama a `GET /<prefijo>/test` A TRAVÉS DEL GATEWAY (valida también el
 * ruteo) y exige: status "ok", base conectada y todas sus tablas legibles.
 * Termina con código 1 si algo falla (útil en CI).
 */
const gateway = (process.env.GATEWAY_URL ?? 'http://localhost:3000').replace(/\/$/, '');

const SERVICES = [
  ['auth-service', 'auth'],
  ['negocios-service', 'businesses'],
  ['agenda-service', 'reservations'],
  ['clientes-service', 'clients'],
  ['descubrimiento-service', 'discover'],
  ['notificaciones-service', 'notifications'],
];

async function get(path) {
  const started = Date.now();
  try {
    const response = await fetch(`${gateway}${path}`, { signal: AbortSignal.timeout(8000) });
    const body = await response.json().catch(() => null);
    return { http: response.status, body, ms: Date.now() - started };
  } catch (error) {
    return {
      http: 0,
      body: null,
      ms: Date.now() - started,
      error: error.cause?.code ?? error.message,
    };
  }
}

const results = [];

const health = await get('/health');
results.push({
  name: 'gateway /health',
  ok: health.http === 200 && health.body?.status === 'ok',
  detail: health.body
    ? `${health.body.status} (${health.body.services.filter((s) => s.status === 'up').length}/${health.body.services.length} servicios up)`
    : (health.error ?? 'sin respuesta'),
  ms: health.ms,
});

for (const [service, prefix] of SERVICES) {
  const { http, body, ms, error } = await get(`/${prefix}/test`);
  const tables = body?.database?.tables ?? {};
  const ok =
    http === 200 &&
    body?.status === 'ok' &&
    body.database?.connected === true &&
    Object.values(tables).every((count) => typeof count === 'number');
  const counts = Object.entries(tables)
    .map(([table, count]) => `${table}=${count ?? '✗'}`)
    .join(' ');
  results.push({
    name: `${service} /${prefix}/test`,
    ok,
    detail: body
      ? `HTTP ${http} · schema ${body.database?.schema} · ${counts}`
      : `HTTP ${http} ${error ?? ''}`,
    ms,
  });
}

const width = Math.max(...results.map((r) => r.name.length));
for (const r of results) {
  console.log(
    `${r.ok ? '✔' : '✘'} ${r.name.padEnd(width)}  ${String(r.ms).padStart(4)} ms  ${r.detail}`,
  );
}
const failed = results.filter((r) => !r.ok).length;
console.log(failed === 0 ? '\nTodo operativo.' : `\n${failed} comprobación(es) fallida(s).`);
process.exit(failed === 0 ? 0 : 1);
