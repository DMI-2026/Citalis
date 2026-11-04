# citalis_app · Frontend Flutter

Cliente Flutter de **Citalis** para iOS, Android y Web. Esta carpeta es uno de los dos subproyectos del monorepo; para la visión general del producto y el estado del backend, revisa el [README raíz](../README.md).

---

## Demo

Despliegue web público (producción):

**https://citalis.vercel.app**

---

## Alcance del prototipo

El proyecto implementa dos roles operando sobre una misma cuenta de usuario, siguiendo las historias de usuario definidas en [`docs/historias-de-usuario.md`](../docs/historias-de-usuario.md):

**Modo Cliente**
- Exploración de negocios con sección "Cerca de ti" y filtros por categoría.
- Detalle de negocio con galería, servicios, horario y acciones (llamar, abrir en mapa).
- Flujo de reserva (día + horario) y confirmación con ticket editorial.
- Favoritos y gestión de reservas (próximas, historial, cancelación).
- Perfil personal: edición de datos, seguridad, notificaciones, pagos, ubicación por defecto, aviso de privacidad, términos y centro de ayuda.

**Modo Empresa** (desbloqueable al registrar un negocio desde el perfil)
- Agenda diaria con indicadores de disponibilidad por día.
- Catálogo de servicios con CRUD completo (crear, editar, eliminar).
- Directorio de clientes vinculados por reservas, con historial y stats por cliente.
- Perfil del negocio editable: información, horarios semanales por día, código QR único con enlace profundo y descarga.

El estado se mantiene en memoria (`AppState` basado en `ChangeNotifier`) con datos semilla; cuando se integre el backend, estas lecturas se moverán a servicios HTTP sin cambiar los widgets.

---

## Stack

| Capa | Tecnología |
|---|---|
| UI | Flutter 3 · Material 3 |
| Lenguaje | Dart `^3.13.2` |
| Tipografía | Fraunces (display) + Inter (texto) vía `google_fonts` |
| Imágenes de red | `Image.network` con fallback editorial |
| Enlaces externos | `url_launcher` |
| Códigos QR | `qr_flutter` |
| Hosting demo | Vercel (SPA estática) |

Backend previsto: **NestJS + Prisma + PostgreSQL + Firebase** (Auth, FCM, Storage). Ver el repositorio `citalis-api` cuando esté publicado.

---

## Puesta en marcha

### Requisitos
- Flutter SDK `>=3.13`
- Dart `^3.13.2`
- Para iOS: Xcode y CocoaPods
- Para Android: Android Studio con un emulador configurado
- Para Web: Chrome

### Instalación

```bash
git clone https://github.com/DMI-2026/Citalis.git
cd Citalis/citalis_app
flutter pub get
```

### Correr en desarrollo

```bash
# Chrome (web)
flutter run -d chrome --web-port=8080

# iOS Simulator
flutter run -d iphone

# Android Emulator
flutter run -d emulator-5554
```

### Build de producción (web)

```bash
flutter build web --release --base-href "/"
# Salida: build/web
```

### Análisis estático

```bash
flutter analyze
```

El proyecto debe pasar `flutter analyze` sin errores. Las reglas están declaradas en `analysis_options.yaml`.

---

## Estructura del proyecto

```
lib/
├── main.dart                # Entry point y routing por URL
├── theme/
│   └── app_theme.dart       # Tokens de diseño (color, tipografía, radios)
├── data/
│   └── mock_data.dart       # Modelos y AppState con datos semilla
├── widgets/
│   └── business_image.dart  # Image.network con fallback + helpers de enlaces
└── screens/
    ├── welcome_screen.dart
    ├── login_screen.dart
    ├── register_screen.dart
    ├── home_screen.dart           # Scaffold cliente con 4 tabs
    ├── business_detail_screen.dart
    ├── booking_screen.dart
    ├── booking_confirmation_screen.dart
    ├── reservations_screen.dart
    ├── favorites_screen.dart
    ├── profile_screen.dart        # Perfil + switch de modo
    ├── settings_screens.dart      # Edit perfil, contraseña, notif, pagos, ubicación
    ├── legal_screens.dart         # Privacidad, términos, ayuda
    ├── register_business_screen.dart
    └── business/
        ├── business_home_screen.dart   # Scaffold empresa con 4 tabs
        ├── business_agenda_tab.dart    # Req 3.4
        ├── business_services_tab.dart  # Req 2.4
        ├── business_clients_tab.dart   # Req 4.1, 4.2
        └── business_profile_tab.dart   # Req 2.2, 2.3, 2.5, 3.1
```

Documentación auxiliar (en la raíz del monorepo):

- [`../docs/historias-de-usuario.md`](../docs/historias-de-usuario.md) — Historias de usuario y requerimientos funcionales organizados en 7 módulos.

---

## Navegación interna

La aplicación usa rutas nombradas con `onGenerateRoute` para habilitar deep links. Rutas disponibles:

| Ruta | Pantalla |
|---|---|
| `/` o `/welcome` | Bienvenida |
| `/login`, `/register` | Autenticación |
| `/home`, `/reservations`, `/favorites`, `/profile` | Tabs cliente |
| `/business?id={id}` | Detalle de negocio |
| `/booking?id={id}&s={idx}` | Flujo de reserva |
| `/confirmation?id={id}` | Confirmación |
| `/register-business` | Onboarding de negocio |
| `/business-home` | Dashboard empresa |
| `/edit-profile`, `/change-password`, `/notifications`, `/payments`, `/location` | Configuración de cuenta |
| `/privacy`, `/terms`, `/help` | Legales y ayuda |

---

## Convenciones de código

- **Formato**: `dart format .` antes de cada commit.
- **Lints**: `flutter analyze` debe salir limpio.
- **Nombres**: `snake_case` para archivos, `PascalCase` para clases, `camelCase` para miembros.
- **Theme**: nunca hardcodear colores o fuentes; usar `AppTheme.*`.
- **Imágenes**: siempre usar el widget `BusinessImage` para fotos de negocio (cae a un placeholder editorial si la URL falla).

### Commits

Mensajes en imperativo y en español, prefijo opcional por área:

```
feat(booking): slot picker con días disabled
fix(home): overflow 48px en carrusel "Cerca de ti"
refactor(theme): extraer tokens de spacing
docs(readme): documentar rutas internas
chore(deps): bump qr_flutter a 4.1.0
```

Rama por tarea sobre `main`, PR hacia `main` con al menos un revisor del equipo.

---

## Equipo

Proyecto desarrollado por el **Team 3** del grupo DMI-2026 · 10mo cuatrimestre · UTEZ.

---

## Licencia

Uso académico — Universidad Tecnológica Emiliano Zapata del Estado de Morelos. Todos los derechos reservados por los autores.
