# Citalis

> Reserva tu cita de belleza en segundos.

**Citalis** es una plataforma que conecta a clientes con negocios de belleza (peluquerías, spas, barberías, estudios de uñas y wellness) y ofrece a los propietarios herramientas para gestionar su agenda, su catálogo de servicios y sus clientes. La reserva se realiza en pocos clics desde la app móvil o escaneando un código QR en el local.

Este repositorio es un **monorepo** con dos aplicaciones y su documentación:

| Carpeta | Rol | Estado |
|---|---|---|
| [`citalis_app/`](citalis_app/) | Cliente Flutter multiplataforma (iOS, Android y Web) | En desarrollo activo (prototipo con datos semilla) |
| [`citalis_back/`](citalis_back/) | Backend: API Gateway + 6 microservicios NestJS, Prisma y PostgreSQL, con Firebase Auth | **Estructura inicial lista**: conexión a BD, endpoint de prueba por servicio, Docker y CI. Lógica de negocio en construcción |
| [`docs/`](docs/) | Historias de usuario, modelo de datos, guía de trabajo del backend y documentos de la rúbrica | Vigente |

---

## Visión del producto

Citalis atiende dos tipos de persona sobre una misma cuenta global:

- **Cliente** — explora negocios cercanos, consulta servicios y disponibilidad, reserva, guarda favoritos y lleva su historial de citas.
- **Propietario de negocio** — registra el perfil del negocio, publica su catálogo de servicios, define horarios semanales, administra la agenda del día, consulta el directorio de clientes vinculados y descarga un código QR único para captación en el local.

El detalle funcional de ambos roles vive en [`docs/historias-de-usuario.md`](docs/historias-de-usuario.md), que organiza los requerimientos en siete módulos: cuenta y seguridad, negocio y servicios, agenda y reservas, clientes y seguimiento, ubicación y descubrimiento, notificaciones y conectividad, y perfil y privacidad.

---

## Arquitectura

```
┌────────────────────────────┐   HTTPS · Bearer <token ID Firebase>   ┌─────────────────────────────────────┐
│        citalis_app         │ ─────────────────────────────────────► │      citalis_back / gateway :3000   │
│  Flutter · Material 3      │                                        │  verifica token · CORS · rate limit │
│  iOS / Android / Web       │                                        └───┬────┬────┬────┬────┬─────────────┘
└─────────────┬──────────────┘                                            ▼    ▼    ▼    ▼    ▼    ▼
              │                                              auth  negocios agenda clientes descub. notif.
              │  Auth · Push (FCM) · Storage                  :3001  :3002   :3003  :3004    :3005  :3006
              ▼                                                  └────┴──────┴──────┴─────────┴──────┘
   ┌─────────────────────────────┐                                              │
   │          Firebase           │◄───── Admin SDK (verificar tokens, FCM) ─────┤
   │  Auth · FCM · Storage       │                                              ▼
   └─────────────────────────────┘                          PostgreSQL · una base, un schema por servicio
```

Decisiones de stack:

- **Frontend**: Flutter 3 (Dart) con Material 3, tipografía Fraunces + Inter, estado reactivo con `ChangeNotifier`.
- **Backend**: monorepo **pnpm + Turborepo** de microservicios **NestJS 10** con **Prisma 5** sobre **PostgreSQL**, detrás de un API Gateway. Misma estructura y tecnologías que el backend de nómina del equipo (`RH-Nomina`).
- **Control de acceso**: **Firebase Authentication**. La app inicia sesión con Firebase; el gateway verifica el token y reenvía la identidad a los servicios.
- **Servicios externos**: Firebase Auth (login y sesión), Firebase Cloud Messaging (push) y Firebase Storage (imágenes de negocios); PostgreSQL gestionado en Supabase o Neon.
- **Hosting demo del frontend web**: Vercel.

### Módulos y microservicios

| Módulo (historias de usuario) | Servicio | Puerto | Schema |
|---|---|---|---|
| 1 · Cuenta y seguridad (+ 7.1 Perfil) | `auth-service` | 3001 | `auth` |
| 2 · Negocio y servicios | `negocios-service` | 3002 | `negocios` |
| 3 · Agenda y reservas | `agenda-service` | 3003 | `agenda` |
| 4 · Clientes y seguimiento | `clientes-service` | 3004 | `clientes` |
| 5 · Ubicación y descubrimiento | `descubrimiento-service` | 3005 | `descubrimiento` |
| 6 · Notificaciones y conectividad (+ 7.3 Permisos) | `notificaciones-service` | 3006 | `notificaciones` |
| Punto de entrada único | `gateway` | 3000 | — |

El módulo 7 se reparte: el perfil vive en `auth-service`, los permisos en `notificaciones-service` y la privacidad es contenido de la app. Detalle y reglas de arquitectura en la [guía de trabajo](docs/backend/guia-de-trabajo.md).

---

## Demo en vivo

El prototipo del frontend está desplegado en:

**https://citalis.vercel.app**

La demo trabaja con datos semilla en memoria; aún no está conectada al backend.

---

## Puesta en marcha rápida

Cada subproyecto tiene su propio README con el detalle.

**Backend** (requiere Node 20, pnpm 8.15 y Docker; ver [`citalis_back/README.md`](citalis_back/README.md)):

```bash
cd citalis_back
pnpm install
cp .env.example .env     # completa FIREBASE_PROJECT_ID y revisa DATABASE_URL
pnpm db:up               # PostgreSQL local en Docker (puerto 5433)
pnpm db:generate && pnpm db:migrate
pnpm dev                 # gateway + 6 microservicios
pnpm smoke               # valida que todo responde y que cada servicio ve su BD
```

**Frontend**:

```bash
cd citalis_app
flutter pub get
flutter run -d chrome --web-port=8080
```

Más detalle en [`citalis_app/README.md`](citalis_app/README.md).

---

## Estructura del monorepo

```
.
├── README.md                       # Este archivo — visión general y estructura
├── CLAUDE.md · AGENTS.md           # Instrucciones para las IA del equipo (apuntan a la guía de trabajo)
├── .github/workflows/
│   └── ci-backend.yml              # CI del backend: lint, build, pruebas, migraciones + smoke, Docker
├── docs/
│   ├── historias-de-usuario.md     # Requerimientos por módulo
│   ├── db/                         # Modelo de datos (modelo-datos.md, schema.sql, diagrama ER)
│   ├── backend/
│   │   └── guia-de-trabajo.md      # Guía normativa del backend (para el equipo y las IA)
│   ├── planeacion/                 # Documento de planeación (H1)
│   ├── estado.md                   # Estado de requisitos y seguridad
│   ├── permisos.md                 # Documento de permisos del dispositivo (H2–H6)
│   ├── pruebas.md                  # Evidencia de pruebas (H5)
│   ├── distribucion/               # Expediente de liberación (H7)
│   └── ia/bitacora.md              # Bitácora de uso de IA (Nivel 4)
├── citalis_app/                    # Frontend Flutter
│   ├── lib/ · test/ · pubspec.yaml
│   └── README.md
└── citalis_back/                   # Backend NestJS (monorepo pnpm + turbo)
    ├── gateway/                    # API Gateway: auth Firebase, proxy, límites
    ├── services/
    │   ├── auth-service/           # M1 · 7.1  — usuarios (schema auth)
    │   ├── negocios-service/       # M2        — negocios, servicios, catálogos
    │   ├── agenda-service/         # M3        — horarios, disponibilidad, reservas
    │   ├── clientes-service/       # M4        — vínculo, historial, valoraciones
    │   ├── descubrimiento-service/ # M5        — búsqueda, cercanía, favoritos, geocodificación
    │   └── notificaciones-service/ # M6 · 7.3  — preferencias, tokens FCM, recordatorios
    ├── commons/                    # Paquetes compartidos @backend/*
    │   ├── contracts/              # tipos, cabeceras y DTOs internos
    │   ├── security/               # guard global, decoradores de identidad
    │   ├── firebase/               # verificación de tokens (firebase-admin)
    │   ├── observability/          # logs JSON y enmascarado de datos personales
    │   └── utils/                  # bootstrap, errores, cliente HTTP, paginación, env
    ├── scripts/                    # prisma-cli.mjs (migraciones por servicio), smoke-test.mjs
    ├── Dockerfile · docker-compose.yml · docker-compose.db.yml
    └── README.md                   # Cómo ejecutar los microservicios
```

---

## Documentación

| Documento | Para qué |
|---|---|
| [`docs/historias-de-usuario.md`](docs/historias-de-usuario.md) | Qué hace la app, por módulo y requerimiento |
| [`docs/db/modelo-datos.md`](docs/db/modelo-datos.md) · [`schema.sql`](docs/db/schema.sql) | Modelo de datos lógico y decisiones de diseño |
| [`citalis_back/README.md`](citalis_back/README.md) | Cómo levantar y probar los microservicios |
| [`docs/backend/guia-de-trabajo.md`](docs/backend/guia-de-trabajo.md) | **Qué va en cada carpeta, qué hay en `commons`, flujo de trabajo y cumplimiento de la rúbrica** |
| [`docs/estado.md`](docs/estado.md) · [`permisos.md`](docs/permisos.md) · [`pruebas.md`](docs/pruebas.md) | Seguimiento y evidencias del proyecto integrador |
| [`docs/ia/bitacora.md`](docs/ia/bitacora.md) | Bitácora de uso de IA (Nivel 4) |

---

## Responsables por capacidad

Cada integrante es responsable de al menos una capacidad (base u optativa) o requisito, y su historial de commits lo demuestra. En la defensa cada integrante explica y modifica en vivo su parte.

| Capacidad / requisito | Responsable | Servicio o capa principal |
|---|---|---|
| F1 · Autenticación remota (Firebase) | _(asignar)_ | `auth-service`, gateway, app |
| F2 · Entidades con CRUD y reglas por usuario (negocios, servicios, reservas) | _(asignar)_ | `negocios-service`, `agenda-service` |
| F3 · API de terceros (geocodificación) | _(asignar)_ | `descubrimiento-service` |
| P1 · Cámara / galería | _(asignar)_ | app + `negocios-service` (imagen) |
| P2 · Ubicación en primer plano | _(asignar)_ | app + `descubrimiento-service` |
| P3 · Notificaciones | _(asignar)_ | app + `notificaciones-service` |
| Optativas elegidas (ver `docs/permisos.md`) | _(asignar)_ | _(según la optativa)_ |
| Pruebas, documentación y distribución | _(asignar)_ | transversal |

---

## Flujo de contribución

- Rama por tarea sobre `main`, con prefijo `feat/`, `fix/`, `refactor/`, `docs/`, `test/` o `chore/`.
- Un solo PR por tarea, con descripción clara del cambio (qué, por qué, cómo probarlo) y referencia al requerimiento que atiende (ej. `Req 3.4`).
- **Al menos una aprobación** de otro integrante antes del merge; el CI del backend debe estar en verde.
- Mensajes de commit en español, en imperativo y usando prefijos por área (ejemplo: `feat(booking): slot picker con días disabled`, `feat(agenda): calcular disponibilidad`).
- Backend: sigue la [guía de trabajo](docs/backend/guia-de-trabajo.md) (estructura, convenciones, migraciones y checklist de PR). Si usas una IA, indícale que la lea y registra la sesión en [`docs/ia/bitacora.md`](docs/ia/bitacora.md).
- Nunca subas secretos (`.env`, JSON de Firebase, claves, keystores): solo `.env.example`.

Antes de abrir un PR del frontend verifica que `flutter analyze` esté limpio. Antes de abrir uno del backend, desde `citalis_back/`: `pnpm lint && pnpm test && pnpm build`.

---

## Equipo

Proyecto académico desarrollado por el **Team 3** del grupo **DMI-2026** · 10mo cuatrimestre · Universidad Tecnológica Emiliano Zapata del Estado de Morelos (UTEZ).

| Integrante | Rol / capacidades |
|---|---|
| _(completar)_ | _(completar)_ |

---

## Licencia

Uso académico. Todos los derechos reservados por los autores.
