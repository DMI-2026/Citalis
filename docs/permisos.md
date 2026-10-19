# Documento de permisos

Evidencia de la Unidad III (enunciado §4.5). **Se inicia en la semana 7 con la base obligatoria (P1–P3) y se completa en la semana 14.** Una fila por permiso o capacidad. Cada permiso debe respetar las reglas de §4.2: mínimo privilegio, solicitud en contexto, tres estados manejados (concedido, denegado, denegado permanentemente), degradación funcional, detección de servicios del sistema apagados, textos de propósito específicos y **en español**, datos y privacidad, transparencia en uso y prueba en dispositivo físico (P1 y P2).

> Las columnas ya conocidas del enunciado están prellenadas. **El responsable de cada capacidad completa el resto.** Los permisos prohibidos o restringidos (§4.4) no se usan sin aprobación del docente.

## Base obligatoria

| Capacidad | Permiso Android (tipo) | Clave iOS (`Info.plist`) | Historia de usuario | Momento de la solicitud | Si se niega | Dato, finalidad y retención | Evidencia (3 estados) |
|---|---|---|---|---|---|---|---|
| **P1** Cámara / galería | Sin permisos de almacenamiento: en Android 13+ se usa el selector de fotos del sistema (`CAMERA` solo si se captura directo) | `NSCameraUsageDescription` · `NSPhotoLibraryUsageDescription` | _Como propietario quiero subir la foto de mi negocio…_ (Req 2.3) | _Al tocar «Agregar foto»_ | _Elige otra imagen / captura manual_ | _Foto reducida (`maxWidth`/`imageQuality`) ligada al negocio; en Firebase Storage con acceso restringido al propietario; vive mientras exista el negocio_ | _(capturas + prueba en dispositivo)_ |
| **P2** Ubicación en primer plano | `ACCESS_COARSE_LOCATION` (ejecución); `ACCESS_FINE_LOCATION` solo si se justifica la precisión | `NSLocationWhenInUseUsageDescription` | _Como cliente quiero ver negocios cercanos…_ (Req 5.3) · _como propietario quiero ubicar mi negocio…_ (Req 5.2) | _Al tocar «Cerca de mí» / «Usar mi ubicación»_ | _Elige municipio o zona de una lista (alternativa manual)_ | _Coordenadas aproximadas; se usan para ordenar por cercanía y no se guardan en la cuenta del cliente; la ubicación del negocio sí se guarda mientras exista_ | _(capturas + prueba en dispositivo)_ |
| **P3** Notificaciones | `POST_NOTIFICATIONS` (Android 13+, en tiempo de ejecución) | Solicitud de autorización de notificaciones (push remoto requiere la capability correspondiente) | _Como cliente quiero un recordatorio de mi cita…_ (Req 6.1) | _Tras confirmar la primera reserva_ | _La app sigue usable; el recordatorio se ve solo en la pantalla de reservas_ | _Token FCM por dispositivo y preferencias (`notification_tokens`, `notification_preferences`); se borra al cerrar sesión o desactivar_ | _(capturas + prueba)_ |

## Capacidades optativas elegidas

Mínimo **5 puntos con 5 integrantes y 6 con 6**, de **al menos 2 capacidades distintas** (solo una de 3 puntos cuenta para el mínimo y requiere aprobación docente antes de la semana 7). Se puede cambiar una optativa hasta el hito H3 avisándolo en el PR de este documento.

| ID | Capacidad | Pts | Responsable | Permiso Android · Clave iOS | Historia de usuario | Momento / Si se niega | Dato, finalidad y retención | Evidencia |
|---|---|---|---|---|---|---|---|---|
| _(O#)_ | _(p. ej. O6 Push remoto segmentado)_ | | | | | | | |

## Permisos que NO se usan (declaración)

La app no solicita `READ_EXTERNAL_STORAGE`, `WRITE_EXTERNAL_STORAGE`, `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_CONTACTS`, SMS/llamadas, `ACCESS_BACKGROUND_LOCATION`, rastreo publicitario ni servicios de accesibilidad. _(Confirmar contra el `AndroidManifest.xml` fusionado de la versión release antes de H6.)_
