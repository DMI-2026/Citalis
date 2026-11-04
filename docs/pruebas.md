# Pruebas

Evidencia de pruebas del proyecto (enunciado §5, hito H5 · 27 nov). Las pruebas deben ejecutarse **con un solo comando**.

## Mínimos exigidos para la app (Flutter)

| Tipo | Mínimo | Comando | Estado |
|---|---|---|---|
| Unitarias (lógica y view models) | 8 | `flutter test` | ⏳ |
| De widget (incluye pantalla de permiso denegado y una con estados de carga y error) | 4 | `flutter test` | ⏳ |
| De integración (flujo principal) | 1 | `flutter test integration_test` | ⏳ |

## Backend (`apps/api/`)

| Tipo | Cobertura | Comando | Estado |
|---|---|---|---|
| Unitarias (Jest) | Guard de identidad, filtro de errores, cliente HTTP (timeout, reintento, datos inválidos), reporte de BD, middleware del gateway y ruteo, registro de usuario (idempotencia, 409, 400), endpoint `/test` de cada servicio | `pnpm test` (desde `apps/api/`) | ✅ 60 pruebas pasando (2026-10-19) |
| Humo del sistema (gateway + servicios + BD real) | `GET /health` y `GET /<prefijo>/test` de los 7 procesos | `pnpm smoke` | ✅ |
| Análisis estático | ESLint + Prettier | `pnpm lint` · `pnpm format:check` | ✅ |
| Reglas de acceso por usuario (S4) | Una prueba por regla de la guía §8.3 al implementar cada módulo | `pnpm test` | ⏳ |

## Evidencia en dispositivo físico (P1 y P2)

El emulador **no** basta para P1 y P2: se requiere evidencia en un teléfono real con los tres estados de cada permiso.

| Capacidad | Dispositivo (modelo, SO) | Concedido | Denegado | Denegado permanentemente |
|---|---|---|---|---|
| P1 Cámara / galería | _(completar)_ | _(captura)_ | _(captura)_ | _(captura)_ |
| P2 Ubicación | _(completar)_ | _(captura)_ | _(captura)_ | _(captura)_ |

## Builds

| Build | Resultado | Fecha |
|---|---|---|
| Debug | _(completar)_ | |
| Release (manifiesto fusionado sin información sensible) | _(completar)_ | |
