# Distribución

Expediente de liberación (enunciado §6, hito H7 · 7–11 dic). El keystore y sus contraseñas **nunca** van al repositorio.

| Modo | Qué se entrega | Estado |
|---|---|---|
| **Artefactos** | AAB y APK de release **firmados**, con versión SemVer + número de build | ⏳ |
| **Interna** | Instalación del APK en un dispositivo limpio, con hash y versión registrados, o Firebase App Distribution | ⏳ |
| **Privada** | Pista de pruebas internas/cerradas de Google Play si hay cuenta; si no, procedimiento documentado | ⏳ |
| **Pública** | Expediente listo para enviar: ficha, descripción, ícono, capturas, clasificación de contenido, formulario de Seguridad de los datos coherente con `docs/permisos.md` y URL de la política de privacidad. iOS y AppGallery se documentan | ⏳ |

## Registro de versiones

| Versión | Build | Fecha | SHA-256 del APK | Notas |
|---|---|---|---|---|
| _(0.1.0)_ | _(1)_ | | | |

## Backend en producción

Despliegue (hosting con HTTPS, rúbrica S2) y variables de entorno requeridas: ver [`citalis_back/README.md`](../../citalis_back/README.md) y [`docs/backend/guia-de-trabajo.md`](../backend/guia-de-trabajo.md#15-decisiones-pendientes). _(Completar con la plataforma elegida.)_
