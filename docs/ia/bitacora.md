# Bitácora de uso de IA

Uso de IA **Nivel 4 — IA completa** (enunciado del proyecto integrador): se permite el uso libre de asistentes **con bitácora de prompts** y **declaración en cada entrega**. Cada integrante debe poder explicar y modificar en vivo el código que entrega; la defensa oral certifica el logro.

**Reglas:** registra aquí cada sesión relevante (nueva funcionalidad, refactor, diagnóstico). No pegues credenciales, llaves, `.env` ni datos personales reales en una herramienta de IA. Una entrada por sesión, la más reciente arriba.

## Plantilla

```
### AAAA-MM-DD · <integrante> · <herramienta y modelo>
- **Tarea / requisito:** (Req o rúbrica, p. ej. Req 3.3 · F2)
- **Prompt (resumen):** qué pediste, con el contexto que diste
- **Resultado:** qué generó (archivos o decisiones)
- **Qué revisé / cambié:** correcciones, partes rechazadas, cómo lo verifiqué (pruebas, ejecución)
- **Entendimiento:** lo que puedo explicar y modificar en vivo de este cambio
```

## Declaración de uso de IA por entrega

| Entrega | Fecha | Declaración |
|---|---|---|
| H1 · Planeación | 25 sep | _(completar)_ |
| H2 · Esqueleto + F1 + P1 | 16 oct | _(completar)_ |
| H3 · F2 + P2 + P3 | 30 oct | _(completar)_ |
| H4 · App funcional | 12 nov | _(completar)_ |
| H5 · Reporte de pruebas | 27 nov | _(completar)_ |
| H6 · Documento de permisos | 4 dic | _(completar)_ |
| H7 · Entrega final y defensa | 7–11 dic | _(completar)_ |

---

## Sesiones

### 2026-11-04 · _(integrante: completar)_ · Claude Code (Claude Opus 5.5)
- **Tarea / requisito:** refactor del frontend (`apps/mobile/`) a arquitectura MVVM y contrato de endpoints para el backend · apoyo a F2, F4, F6, F7.
- **Prompt (resumen):** "Haz el refactor del frontend a una arquitectura MVVM y genera un documento con los endpoints que necesita el front para funcionar, para que sea más rápido avanzar en el back". Contexto: el código de la app, `docs/backend/guia-de-trabajo.md`, `docs/db/modelo-datos.md`, `@backend/contracts` y las rutas del gateway.
- **Resultado:** `lib/` reorganizado en `domain/models`, `data/repositories` (9 interfaces + implementaciones fake sobre un `FakeStore` en memoria), `ui/<feature>/{view_models,widgets}`, `config/dependencies.dart` (provider) y `routing/`; se eliminó `AppState`/`mock_data.dart`. Estados cargando/error/vacío con `LoadingView`/`ErrorView`. Pruebas de ViewModels. Documento [`docs/backend/endpoints-app.md`](../backend/endpoints-app.md) con 32 endpoints (método, ruta, servicio, request/response, errores, reglas de acceso, endpoints internos y orden de implementación).
- **Qué revisé / cambié:** `flutter analyze` sin issues, `flutter test` en verde (la prueba de bienvenida ahora inyecta los repositorios fake), y una prueba de humo temporal que recorrió login → explorar → detalle → reservar → reservas → perfil → registrar negocio → tabs de empresa sin excepciones. Cambios de comportamiento: deep links `/booking` usan `service={serviceId}`; `/business` y `/confirmation` sin `id` llevan a bienvenida; los chips de Explorar salen del catálogo (incluye Masajes y Depilación); cambiar contraseña valida que coincidan.
- **Entendimiento:** _(cada integrante completa lo que puede explicar: flujo pantalla → ViewModel → repositorio, cómo cambiar un repositorio fake por uno remoto y qué endpoint usa cada pantalla)_

### 2026-10-19 · _(integrante: completar)_ · Claude Code (Claude Sonnet 5.5)
- **Tarea / requisito:** estructura inicial del backend (`apps/api/`), conexión a la BD, endpoint de prueba por microservicio, guía de trabajo y READMEs · apoyo a F1, F5, S2–S5, S7.
- **Prompt (resumen):** se entregaron como contexto el modelo de datos (`docs/db/modelo-datos.md`), las historias de usuario, el backend de nómina (`RH-Nomina`) como estructura objetivo y la rúbrica del integrador; se pidió armar gateway, servicios y commons con las mismas tecnologías (NestJS, Prisma, PostgreSQL), Firebase para el control de acceso, un endpoint de prueba por servicio y documentación para que el equipo trabaje con una sola arquitectura.
- **Resultado:** monorepo `apps/api/` (gateway + 6 servicios + 5 paquetes `commons`), migraciones por servicio, Dockerfile/compose, `README`s, `docs/backend/guia-de-trabajo.md`, `CLAUDE.md`/`AGENTS.md`, documentos de la rúbrica y corrección de `docs/db/schema.sql`.
- **Qué revisé / cambié:** ejecuté contra un PostgreSQL real (instalación, migraciones desde cero, `pnpm test`, `pnpm lint`, `pnpm build`, `pnpm dev`, stack en Docker y `pnpm smoke`); probé el anti-traslape de reservas, los `CHECK` y el flujo de autenticación con tokens de prueba. La verificación detectó dos errores del `schema.sql` original (orden de la extensión `pg_trgm` y `EXCLUDE` no inmutable) que se corrigieron.
- **Entendimiento:** _(cada integrante completa lo que pudo explicar de este cambio antes de la defensa)_
