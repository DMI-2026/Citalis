# Estado del proyecto

Seguimiento de requisitos del proyecto integrador. Se actualiza en cada PR que cambia el estado de algo. Leyenda: ✅ listo · 🟡 parcial · ⏳ pendiente · — no aplica a esa capa.

_Última actualización: 2026-10-19._

## Requisitos funcionales (enunciado §2)

| ID | Requisito | Backend | App | Notas |
|---|---|---|---|---|
| F1 | Autenticación remota (registro, inicio/cierre, restauración, recuperación) | 🟡 Gateway verifica Firebase; `POST /auth/register`, `GET /users/me` | ⏳ | Firebase Auth gestiona credenciales |
| F2 | ≥ 2 entidades con CRUD en la nube, una del usuario, con reglas de acceso | ⏳ | ⏳ | Candidatas: Negocio/Servicio y Reserva (**H3, 30 oct**) |
| F3 | ≥ 1 API de terceros con timeout, errores y credencial fuera del repo | 🟡 `ResilientHttpClient` listo | ⏳ | Falta elegir proveedor de geocodificación |
| F4 | ≥ 6 pantallas con navegación coherente | — | 🟡 Prototipo con datos semilla | Falta conectar al backend |
| F5 | Formularios validados en cliente y servidor | 🟡 `ValidationPipe` estricto + DTOs | ⏳ | |
| F6 | Estados cargando/datos/error/vacío | — | ⏳ | |
| F7 | Sin conexión: detecta, indica y reintenta | 🟡 Reintento seguro (idempotencia) pendiente en reservas | ⏳ | |

## Seguridad (enunciado §3)

| ID | Estado | Evidencia / pendiente |
|---|---|---|
| S1 Almacenamiento seguro de token | ⏳ | App: `flutter_secure_storage` |
| S2 HTTPS | ⏳ | Definir hosting con TLS (guía §15) |
| S3 Cero secretos en el repo | ✅ | `.env` ignorado, `.env.example`, validación de variables al arrancar |
| S4 Reglas restringidas a la identidad, probadas | 🟡 | Gateway + guard global; faltan reglas por recurso y `storage.rules` con pruebas |
| S5 Logs sin tokens ni datos personales | ✅ (base) | `JsonLogger`, `maskSensitiveFields`, Swagger/`/test` apagables |
| S6 Inventario de datos y aviso de privacidad | ⏳ | |
| S7 Validación de entradas y respuestas de API | 🟡 | Entradas ✅; respuestas de terceros al integrar la API |
| S8 Dependencias vigentes | ⏳ | `pnpm outdated`/`audit` antes de H4 |

## Capacidades del dispositivo (enunciado §4)

| ID | Capacidad | Responsable | Estado | Evidencia en dispositivo físico |
|---|---|---|---|---|
| P1 | Cámara / galería | _(asignar)_ | ⏳ | ⏳ |
| P2 | Ubicación en primer plano | _(asignar)_ | ⏳ | ⏳ |
| P3 | Notificaciones | _(asignar)_ | ⏳ | — |
| Optativas | _(elegir antes de H3; ver `docs/permisos.md`)_ | | ⏳ | |

## Backend por servicio

| Servicio | Estructura | Conexión a BD + `/test` | Lógica de negocio |
|---|---|---|---|
| gateway | ✅ | ✅ (`/health` agregado) | ✅ Auth Firebase, proxy, límites |
| auth-service | ✅ | ✅ | 🟡 Registro, perfil y consulta interna |
| negocios-service | ✅ | ✅ | ⏳ |
| agenda-service | ✅ | ✅ | ⏳ (anti-traslape ya en la BD) |
| clientes-service | ✅ | ✅ | ⏳ |
| descubrimiento-service | ✅ | ✅ | ⏳ |
| notificaciones-service | ✅ | ✅ | ⏳ |
