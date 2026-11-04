# apps/mobile · App Flutter de Citalis

Cliente Flutter de **Citalis** para iOS, Android y Web. Vive en `apps/mobile/` dentro del monorepo, junto al backend en [`apps/api/`](../api/). Para la visión general del producto revisa el [README raíz](../../README.md).

El paquete Dart se llama `citalis_app` (los imports son `package:citalis_app/...`); la carpeta y el paquete no tienen que coincidir.

---

## Demo

Despliegue web público (producción):

**https://citalis.vercel.app**

---

## Alcance del prototipo

El proyecto implementa dos roles operando sobre una misma cuenta de usuario, siguiendo las historias de usuario definidas en [`docs/historias-de-usuario.md`](../../docs/historias-de-usuario.md):

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

La app sigue **MVVM** (guía oficial de arquitectura de Flutter, decisión A-02 en [`docs/04-arquitectura.md`](../../docs/04-arquitectura.md)): pantallas → ViewModels (`ChangeNotifier`) → repositorios. Hoy los repositorios son *fake* (datos semilla en memoria con 200 ms de latencia simulada); al integrar el backend se escriben las implementaciones remotas y se registran en `lib/config/dependencies.dart` sin cambiar pantallas ni ViewModels. Los endpoints que necesita cada repositorio están en [`docs/backend/endpoints-app.md`](../../docs/backend/endpoints-app.md).

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
| Arquitectura | MVVM · `provider` (inyección de dependencias) · `ChangeNotifier` |
| Hosting demo | Vercel (SPA estática) |

Backend: **NestJS + Prisma + PostgreSQL + Firebase** (Auth, FCM, Storage) en [`apps/api/`](../api/README.md). La app todavía no se conecta a él: trabaja con repositorios fake y datos semilla.

---

## Puesta en marcha

### Requisitos
- Flutter SDK estable (probado con 3.47.2)
- Dart `^3.13.2`
- Para iOS: Xcode y CocoaPods
- Para Android: Android Studio con un emulador configurado
- Para Web: Chrome

### Instalación

```bash
git clone https://github.com/DMI-2026/Citalis.git
cd Citalis/apps/mobile
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

### Verificación (antes de cada commit)

```bash
flutter analyze
flutter test
```

Las dos deben terminar sin errores. Las reglas del analizador están en `analysis_options.yaml`.

Las pruebas viven en `test/`. Como en `flutter test` no hay red, las pruebas desactivan la descarga de Google Fonts (`GoogleFonts.config.allowRuntimeFetching = false`) y las imágenes de red caen al fallback de `BusinessImage`. Si cambias un texto de una pantalla, actualiza su prueba en el mismo commit; no la borres para que pase.

---

## Estructura del proyecto (MVVM)

```
lib/
├── main.dart                     # Entry point: registra los repositorios (provider) y arranca la app
├── config/dependencies.dart      # Qué implementación de cada repositorio se usa (hoy: fake)
├── routing/app_router.dart       # Rutas por URL (deep links / web)
├── domain/models/                # Modelos inmutables: Business, Service, Reservation, MyBusiness…
├── data/
│   ├── repositories/<dominio>/   # <x>_repository.dart (interfaz) + <x>_repository_fake.dart
│   └── fake/                     # FakeStore (backend en memoria) y datos semilla
├── utils/result.dart             # Result<T> = Ok | Failure(AppException{code, message})
└── ui/
    ├── core/                     # theme, ViewModel base, widgets (BusinessImage, Loading/ErrorView), utils
    └── <feature>/                # auth, home, explore, business_detail, booking, reservations,
        ├── view_models/          #   favorites, profile, settings, legal, business_owner
        └── widgets/              # pantallas (solo pintan y delegan en su ViewModel)

test/
├── widget_test.dart              # Pantalla de bienvenida
└── ui/view_models_test.dart      # ViewModels de favoritos, reservas y reserva (anti doble reserva)
```

**Reglas de la arquitectura:**

- **Pantalla** = `StatelessWidget` público que crea su ViewModel con `ChangeNotifierProvider(create: ...)` y una vista privada que lo lee con `context.watch`. Solo guarda estado efímero de UI (controladores de texto, tab seleccionado).
- **ViewModel** = extiende `ViewModel` (`ui/core/view_model.dart`); expone `isLoading`, `errorMessage` y datos; las acciones devuelven `Future<String?>` (mensaje de error o `null`) o un `Result`. Nunca importa widgets ni `BuildContext`.
- **Repositorio** = única fuente de datos. Devuelve `Result<T>` (no lanza excepciones). Los que tienen datos que cambian extienden `ChangeNotifier` y notifican tras cada escritura; los ViewModels interesados se suscriben y recargan.
- Las pantallas **no** importan repositorios fake ni `FakeStore`.

Documentación auxiliar (en la raíz del monorepo):

- [`docs/historias-de-usuario.md`](../../docs/historias-de-usuario.md) · historias de usuario y requerimientos en 7 módulos.
- [`docs/02-prd.md`](../../docs/02-prd.md) · producto (PRD).
- [`docs/06-convenciones.md`](../../docs/06-convenciones.md) · convenciones del equipo.

---

## Navegación interna

La aplicación usa rutas nombradas con `onGenerateRoute` para habilitar deep links. Rutas disponibles:

| Ruta | Pantalla |
|---|---|
| `/` o `/welcome` | Bienvenida |
| `/login`, `/register` | Autenticación |
| `/home`, `/reservations`, `/favorites`, `/profile` | Tabs cliente |
| `/business?id={businessId}` | Detalle de negocio |
| `/booking?id={businessId}&service={serviceId}` | Flujo de reserva |
| `/confirmation?id={reservationId}` | Confirmación |
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

Usamos git flow: cada tarea en una rama `feature/<tema>` que sale de `develop` y vuelve a `develop` por PR, con al menos un revisor del equipo. Nunca se hace push directo a `main` ni a `develop`. Detalle en el [README raíz](../../README.md#flujo-de-contribución).

---

## Equipo

Proyecto desarrollado por el **Team 3** del grupo DMI-2026 · 10mo cuatrimestre · UTEZ.

---

## Licencia

Uso académico — Universidad Tecnológica Emiliano Zapata del Estado de Morelos. Todos los derechos reservados por los autores.
