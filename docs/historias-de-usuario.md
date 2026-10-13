# Citalis

### Módulo 1. Cuenta y seguridad

**Requerimiento 1.1 — Registro de usuario (Cliente/Propietario)**

- **Descripción:** El sistema deberá permitir que cualquier persona se registre por sí misma para crear una cuenta global de usuario en Citalis. Esta cuenta servirá tanto para clientes que desean reservar como para usuarios que posteriormente deseen dar de alta un negocio.
- **Datos de entrada:**
    - Nombre.
    - Correo electrónico.
    - Contraseña.
    - Confirmación de contraseña.
- **Datos de salida:**
    - Cuenta creada correctamente.
    - Mensaje de confirmación.
    - Mensaje de error en caso de datos inválidos o correo existente.
- **Reglas de negocio:**
    - El usuario (cliente) se da de alta a sí mismo; el negocio no crea cuentas de clientes.
    - El correo electrónico debe ser único.
    - La contraseña debe cumplir con las reglas de seguridad establecidas.
    - La información deberá almacenarse mediante el servicio de autenticación remoto.
    - Los datos sensibles no deberán almacenarse en almacenamiento local inseguro.
- **Criterios de aplicación:**
    - El usuario puede completar el formulario de registro.
    - El sistema valida los datos antes de enviarlos.
    - El sistema informa si el registro fue exitoso o si ocurrió un error.
    - Un correo que ya pertenece a una cuenta no puede registrarse nuevamente.

**Requerimiento 1.2 — Inicio de sesión**

- **Descripción:** El sistema deberá permitir que un usuario autenticado acceda a su cuenta mediante sus credenciales.
- **Datos de entrada:**
    - Correo electrónico.
    - Contraseña.
- **Datos de salida:**
    - Sesión iniciada y acceso a la aplicación.
    - Mensaje de error si las credenciales son incorrectas.
- **Reglas de negocio:**
    - Sólo se permitirá el acceso con credenciales válidas.
    - La sesión deberá manejarse mediante el servicio de autenticación remoto.
    - El token o sesión deberá almacenarse de forma segura.
- **Criterios de aplicación:**
    - El usuario puede iniciar sesión con credenciales válidas y acceder a sus funciones.
    - Las credenciales incorrectas generan un mensaje de error.

**Requerimiento 1.3 — Cierre y restauración de sesión**

- **Descripción:** El sistema deberá permitir cerrar sesión y restaurar una sesión válida cuando el usuario vuelva a abrir la aplicación.
- **Datos de entrada:**
    - Acción de cerrar sesión.
    - Token o sesión previamente válida.
- **Datos de salida:**
    - Sesión cerrada o sesión restaurada.
    - Redirección a la pantalla correspondiente.
- **Reglas de negocio:**
    - Una sesión cerrada no podrá utilizarse para acceder a información protegida.
    - Una sesión válida podrá restaurarse al reabrir la aplicación.
- **Criterios de aplicación:**
    - Al reabrir la aplicación con una sesión válida, el usuario no necesita iniciar sesión nuevamente.
    - Después de cerrar sesión debe solicitarse nuevamente la autenticación.

**Requerimiento 1.4 — Recuperación de contraseña**

- **Descripción:** El sistema deberá permitir al usuario recuperar el acceso a su cuenta mediante su correo electrónico.
- **Datos de entrada:**
    - Correo electrónico registrado.
- **Datos de salida:**
    - Solicitud de recuperación enviada.
    - Mensaje de confirmación o error.
- **Reglas de negocio:**
    - La recuperación deberá realizarse mediante el servicio de autenticación remoto.
    - El usuario deberá demostrar control sobre el correo asociado a la cuenta.
- **Criterios de aplicación:**
    - El usuario puede solicitar la recuperación y establecer una nueva contraseña.

### Módulo 2. Negocio y servicios

**Requerimiento 2.1 — Registro del perfil del negocio**

- **Descripción:** El sistema deberá permitir a un usuario autenticado registrar la información de su negocio de belleza, separando lógicamente su cuenta personal del perfil de la empresa.
- **Datos de entrada:**
    - Nombre del negocio.
    - Descripción, Categoría, Teléfono, Dirección, Municipio, Imagen del negocio.
- **Datos de salida:**
    - Perfil del negocio creado y asociado a la cuenta del usuario.
    - Mensaje de confirmación o error.
- **Reglas de negocio:**
    - El negocio deberá estar asociado al usuario autenticado (quien se convierte en propietario).
    - Sólo el propietario podrá modificar su información.
- **Criterios de aplicación:**
    - El usuario registra el negocio y el sistema valida los campos obligatorios.

**Requerimiento 2.2 — Administración del perfil del negocio**

- **Descripción:** El sistema deberá permitir al propietario consultar, editar y actualizar la información de su negocio.
- **Datos de entrada:** Datos actualizados del negocio.
- **Datos de salida:** Información actualizada.
- **Reglas de negocio:** Sólo el propietario puede modificar el perfil tras la validación de cambios.
- **Criterios de aplicación:** Los cambios se reflejan al volver a consultar el perfil.

**Requerimiento 2.3 — Imagen del negocio**

- **Descripción:** El sistema deberá permitir seleccionar o capturar una imagen para asociarla al perfil del negocio.
- **Datos de entrada:** Fotografía de la cámara o imagen de la galería.
- **Datos de salida:** Imagen almacenada y asociada al negocio.
- **Reglas de negocio:** Solicitar permisos solo al momento de uso, reducir tamaño de imagen antes de subirla.
- **Criterios de aplicación:** Manejo correcto de estados de permisos de dispositivo.

**Requerimiento 2.4 — Administración de servicios**

- **Descripción:** El sistema deberá permitir al propietario crear, consultar, editar y eliminar los servicios.
- **Datos de entrada:** Nombre del servicio, Descripción, Duración, Precio.
- **Datos de salida:** Servicio modificado y catálogo actualizado.
- **Reglas de negocio:** La duración y el precio deberán ser válidos. Sólo el propietario los administra.
- **Criterios de aplicación:** Los cambios se reflejan inmediatamente en el catálogo.

**Requerimiento 2.5 — Generación de Código QR del Negocio** 

- **Descripción:** El sistema generará automáticamente un código QR único para cada negocio registrado, el cual el propietario podrá descargar, imprimir o compartir.
- **Datos de entrada:** Identificador único del negocio.
- **Datos de salida:** Imagen del código QR.
- **Reglas de negocio:**
    - El código QR deberá contener un enlace dinámico (Deep Link/Universal Link).
- **Criterios de aplicación:**
    - El propietario puede visualizar y descargar el QR de su negocio desde la sección de administración.

### Módulo 3. Agenda y reservas

**Requerimiento 3.1 — Configuración de horarios**

- **Descripción:** El sistema deberá permitir al propietario configurar los días y horarios en los que el negocio ofrece sus servicios.
- **Datos de entrada:** Días de atención, hora de apertura, hora de cierre, periodos no disponibles.
- **Datos de salida:** Horario de atención guardado.
- **Reglas de negocio:** La hora de cierre deberá ser posterior a la de apertura.
- **Criterios de aplicación:** El sistema impide traslapes u horarios inválidos.

**Requerimiento 3.2 — Consulta de disponibilidad**

- **Descripción:** El sistema deberá mostrar al cliente los horarios disponibles para reservar un servicio.
- **Datos de entrada:** Negocio, Servicio, Fecha seleccionada.
- **Datos de salida:** Lista de horarios disponibles.
- **Reglas de negocio:** Se restan los horarios ocupados y se calcula según la duración del servicio.
- **Criterios de aplicación:** Los horarios ocupados no pueden seleccionarse.

**Requerimiento 3.3 — Creación de reserva**

- **Descripción:** El sistema deberá permitir al cliente reservar un servicio en un horario disponible.
- **Datos de entrada:** Negocio, Servicio, Fecha, Hora, Usuario/cliente autenticado.
- **Datos de salida:** Reserva creada y agenda actualizada.
- **Reglas de negocio:** No se permiten traslapes. La reserva queda asociada al cliente que la generó y al negocio.
- **Criterios de aplicación:** El horario deja de estar disponible y el propietario ve la nueva cita.

**Requerimiento 3.4 — Administración de reservas**

- **Descripción:** El sistema deberá permitir consultar, modificar, cancelar y actualizar el estado de una reserva.
- **Datos de entrada:** Identificador de reserva, Nueva fecha/hora, Nuevo estado.
- **Datos de salida:** Reserva actualizada/cancelada y agenda liberada.
- **Reglas de negocio:** Una reserva cancelada libera el horario para otros usuarios.
- **Criterios de aplicación:** Cliente o propietario pueden gestionar según corresponda.

**Requerimiento 3.5 — Reserva eficiente mediante código QR** 

- **Descripción:** El sistema deberá permitir flujos rápidos de captación y reserva de citas al escanear el código QR del negocio.
- **Datos de entrada:** Escaneo del código QR del negocio por parte del cliente.
- **Datos de salida:**
    - Redirección a la App Store / Play Store (si no tiene la app).
    - Apertura directa del perfil del negocio dentro de la app (si ya la tiene instalada).
- **Reglas de negocio:**
    - El cliente podrá iniciar el flujo de reserva con un par de clics tras escanear el QR.
- **Criterios de aplicación:**
    - Si el usuario no tiene cuenta, se le pedirá registrarse (Req 1.1) y tras el registro se le redirigirá al negocio que escaneó.
    - Si ya tiene la app y sesión iniciada, entrará directamente a seleccionar servicio y horario.

### Módulo 4. Clientes y seguimiento

**Requerimiento 4.1 — Vinculación y registro de clientes** 

- **Descripción:** El sistema no requerirá que el negocio dé de alta manualmente a sus clientes. En su lugar, el sistema vinculará la información de la cuenta del cliente al negocio automáticamente cuando éste realice su primera reserva.
- **Datos de entrada:** Creación de una reserva por parte de un cliente.
- **Datos de salida:** El cliente aparece en el catálogo o lista de clientes del negocio.
- **Reglas de negocio:**
    - El cliente administra su propia cuenta desde su perfil.
    - El negocio únicamente tendrá acceso de lectura a los datos necesarios (nombre, teléfono, correo) para la gestión de las citas.
    - Un negocio no puede consultar clientes que no hayan reservado al menos una vez en su establecimiento.
- **Criterios de aplicación:**
    - El propietario puede consultar el directorio de clientes que han interactuado con su negocio.
    - Una misma cuenta de cliente puede estar vinculada a varios negocios de manera independiente.

**Requerimiento 4.2 — Historial de citas**

- **Descripción:** El sistema deberá permitir consultar el historial de citas de un cliente dentro de un negocio.
- **Datos de entrada:** Identificador del cliente, Identificador del negocio.
- **Datos de salida:** Lista de citas anteriores, Servicios realizados, Fechas y estados.
- **Reglas de negocio:** El historial sólo deberá mostrar citas correspondientes a esa relación Cliente-Negocio.
- **Criterios de aplicación:** Un usuario no autorizado no puede acceder al historial.

**Requerimiento 4.3 — Valoración del servicio**

- **Descripción:** El sistema deberá permitir al cliente valorar un servicio recibido tras concluir la cita.
- **Datos de entrada:** Cita realizada, Calificación, Comentario opcional.
- **Datos de salida:** Valoración registrada.
- **Reglas de negocio:** Sólo podrá valorarse un servicio efectivamente prestado (estado completado).
- **Criterios de aplicación:** La valoración queda asociada al servicio y es visible para el negocio.

### Módulo 5. Ubicación y descubrimiento

**Requerimiento 5.1 — Búsqueda de negocios**

- **Descripción:** El sistema deberá permitir al usuario buscar negocios de belleza disponibles en Citalis.
- **Datos de entrada:** Nombre del negocio, Categoría, Municipio o zona.
- **Datos de salida:** Lista de negocios coincidentes.
- **Reglas de negocio:** La búsqueda podrá realizarse mediante nombre, categoría o ubicación.
- **Criterios de aplicación:** El usuario puede seleccionar un negocio para consultar su información.

**Requerimiento 5.2 — Consulta de ubicación**

- **Descripción:** El sistema deberá permitir consultar la ubicación de un negocio y utilizar servicios de mapas o geolocalización.
- **Datos de entrada:** Dirección del negocio, Ubicación actual del usuario (si la otorga).
- **Datos de salida:** Ubicación del negocio en mapa, distancia (si aplica).
- **Reglas de negocio:** Si el usuario niega el permiso de ubicación, deberá existir una alternativa manual.
- **Criterios de aplicación:** La aplicación maneja errores y tiempos de espera del mapa/API de terceros.

**Requerimiento 5.3 — Negocios cercanos**

- **Descripción:** El sistema deberá permitir consultar negocios cercanos a la ubicación del usuario.
- **Datos de entrada:** Ubicación actual del usuario, Categoría seleccionada.
- **Datos de salida:** Lista de negocios ordenados por proximidad.
- **Reglas de negocio:** La ubicación deberá solicitarse únicamente al ejecutar la función.
- **Criterios de aplicación:** Funciona con GPS o entrada manual de zona.

### Módulo 6. Notificaciones y conectividad

**Requerimiento 6.1 — Recordatorios de citas**

- **Descripción:** El sistema deberá enviar al usuario recordatorios (Push/Email) relacionados con sus citas.
- **Datos de entrada:** Datos de la reserva y preferencias del usuario.
- **Datos de salida:** Notificación de recordatorio enviada.
- **Reglas de negocio:** El usuario deberá autorizar las notificaciones y podrá desactivarlas.
- **Criterios de aplicación:** El sistema alerta antes de la cita según el tiempo preconfigurado.

**Requerimiento 6.2 — Detección de conexión**

- **Descripción:** El sistema deberá detectar y advertir cuando el dispositivo pierde la conexión a internet.
- **Datos de entrada:** Estado de red.
- **Datos de salida:** Indicador visual de desconexión.
- **Reglas de negocio:** La aplicación no deberá cerrarse por falta de conexión, pero bloqueará operaciones que requieran la nube.
- **Criterios de aplicación:** El usuario ve un aviso claro si intenta reservar sin internet.

**Requerimiento 6.3 — Reintento de operaciones**

- **Descripción:** El sistema deberá permitir reintentar una operación que haya fallado debido a red.
- **Datos de entrada:** Acción fallida.
- **Datos de salida:** Operación exitosa tras reintento, o nuevo error.
- **Reglas de negocio:** Evitar registros duplicados (doble reserva) en los reintentos.
- **Criterios de aplicación:** Botón de "Reintentar" disponible en alertas de error de red.

### Módulo 7. Perfil, privacidad y configuración

**Requerimiento 7.1 — Administración del perfil de usuario**

- **Descripción:** El sistema deberá permitir al usuario consultar y modificar su información personal base.
- **Datos de entrada:** Nombre, Teléfono, Contraseña.
- **Datos de salida:** Perfil actualizado.
- **Reglas de negocio:** Los datos modificados por el cliente se actualizarán automáticamente para los negocios donde ya es cliente.
- **Criterios de aplicación:** Validación de datos correcta.

**Requerimiento 7.2 — Configuración de privacidad**

- **Descripción:** El sistema deberá proporcionar información sobre los datos recopilados y su fin.
- **Datos de entrada:** Interacción con menú de privacidad.
- **Datos de salida:** Pantallas de términos, condiciones y aviso de privacidad.
- **Reglas de negocio:** Estar apegado a las normas locales de protección de datos (Ej. ARCO).
- **Criterios de aplicación:** Textos accesibles y claros desde la app.

**Requerimiento 7.3 — Administración de permisos**

- **Descripción:** El sistema deberá permitir gestionar preferencias de cámara, ubicación y notificaciones.
- **Datos de entrada:** Estado actual de permisos del SO.
- **Datos de salida:** Interfaz de activación o redirección a ajustes.
- **Reglas de negocio:** Explicar en español el motivo del permiso antes de lanzarlo (Prominente).
- **Criterios de aplicación:** Manejo amigable de permisos denegados (Graceful degradation).