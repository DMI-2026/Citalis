# Citalis

> Reserva tu cita de belleza en segundos.

**Citalis** es una plataforma que conecta a clientes con negocios de belleza (peluquerías, spas, barberías, estudios de uñas y wellness) y ofrece a los propietarios herramientas para gestionar su agenda, su catálogo de servicios y sus clientes. La reserva se realiza en pocos clics desde la app móvil o escaneando un código QR en el local.

Este repositorio es un **monorepo** con dos subproyectos:

| Carpeta | Rol | Estado |
|---|---|---|
| [`citalis_app/`](citalis_app/) | Cliente Flutter multiplataforma (iOS, Android y Web) | En desarrollo activo |
| `citalis_api/` | Backend REST y persistencia | Próximamente |

---

## Visión del producto

Citalis atiende dos tipos de persona sobre una misma cuenta global:

- **Cliente** — explora negocios cercanos, consulta servicios y disponibilidad, reserva, guarda favoritos y lleva su historial de citas.
- **Propietario de negocio** — registra el perfil del negocio, publica su catálogo de servicios, define horarios semanales, administra la agenda del día, consulta el directorio de clientes vinculados y descarga un código QR único para captación en el local.

El detalle funcional de ambos roles vive en [`docs/historias-de-usuario.md`](docs/historias-de-usuario.md), que organiza los requerimientos en siete módulos: cuenta y seguridad, negocio y servicios, agenda y reservas, clientes y seguimiento, ubicación y descubrimiento, notificaciones y conectividad, y perfil y privacidad.

---

## Arquitectura

```
┌────────────────────────────┐          ┌───────────────────────────┐
│       citalis_app          │          │        citalis_api        │
│  Flutter · Material 3      │  HTTPS   │  NestJS · Prisma          │
│  iOS / Android / Web       │ ───────► │  PostgreSQL               │
└────────────┬───────────────┘          └─────────────┬─────────────┘
             │                                        │
             │  Auth · Push · Storage                 │  Admin SDK
             ▼                                        ▼
                 ┌─────────────────────────────┐
                 │          Firebase           │
                 │  Auth · FCM · Storage       │
                 └─────────────────────────────┘
```

Decisiones de stack previstas:

- **Frontend**: Flutter 3 (Dart) con Material 3, tipografía Fraunces + Inter, estado reactivo con `ChangeNotifier`.
- **Backend**: NestJS + Prisma + PostgreSQL (managed en Supabase o Neon).
- **Servicios externos**: Firebase Auth para login y gestión de sesión, Firebase Cloud Messaging para notificaciones push, Firebase Storage para imágenes de negocios.
- **Hosting demo del frontend web**: Vercel.

---

## Demo en vivo

El prototipo del frontend está desplegado en:

**https://citalis.vercel.app**

La demo trabaja con datos semilla en memoria; aún no está conectada al backend.

---

## Puesta en marcha rápida

Cada subproyecto tiene su propio README con instrucciones específicas. Para el frontend:

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
├── README.md                 # Este archivo — visión general del producto
├── docs/
│   └── historias-de-usuario.md
├── citalis_app/              # Frontend Flutter
│   ├── lib/
│   ├── test/
│   ├── pubspec.yaml
│   └── README.md
└── citalis_api/              # Backend NestJS (próximamente)
```

---

## Flujo de contribución

- Rama por tarea sobre `main`, con prefijo `feat/`, `fix/`, `refactor/`, `docs/` o `chore/`.
- Un solo PR por tarea, con descripción clara del cambio y referencia al requerimiento que atiende (ej. `Req 3.4`).
- Al menos un revisor del team antes del merge.
- Mensajes de commit en español, en imperativo y usando prefijos por área (ejemplo: `feat(booking): slot picker con días disabled`).

Antes de abrir un PR del frontend verifica que `flutter analyze` esté limpio.

---

## Equipo

Proyecto académico desarrollado por el **Team 3** del grupo **DMI-2026** · 10mo cuatrimestre · Universidad Tecnológica Emiliano Zapata del Estado de Morelos (UTEZ).

---

## Licencia

Uso académico. Todos los derechos reservados por los autores.
