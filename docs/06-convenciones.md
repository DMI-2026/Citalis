# Convenciones de Citalis

## Tabla de decisiones

| # | Decisión | Alternativa descartada | Por qué | Fecha |
|---|---|---|---|---|
| C-01 | COMPLETA: flujo de ramas (git flow: main, develop, feature/*) | | | |
| C-02 | COMPLETA: formato de commits | | | |
| C-03 | COMPLETA: quién aprueba y quién fusiona | | | |
| C-04 | COMPLETA: comando de verificación | | | |
| C-05 | Estructura de `apps/mobile/lib`: `domain/models`, `data/repositories/<dominio>` (interfaz + fake), `ui/<feature>/{view_models,widgets}`, `config/`, `routing/` | Carpetas por tipo (`screens/`, `widgets/`, `data/`) con estado global | Cada pantalla tiene su ViewModel junto a ella y cada repositorio corresponde a endpoints del backend (A-02) | 2026-11-04 |

## Organización del repositorio

COMPLETA: árbol de dos niveles con una línea por carpeta.

## Patrones de diseño seleccionados

COMPLETA: patrones de la unidad I, dónde se usan y por qué.

## Patrones de código

### Flutter (apps/mobile)

MVVM (A-02, C-05). Detalle y árbol en [`apps/mobile/README.md`](../apps/mobile/README.md).

- **Pantalla:** `StatelessWidget` público que crea su ViewModel con `ChangeNotifierProvider(create: (context) => XViewModel(repo: context.read())..load())` y una vista privada que lo lee con `context.watch`. Solo guarda estado efímero (controladores de texto, tab seleccionado).
- **ViewModel:** extiende `ViewModel` (`lib/ui/core/view_model.dart`), expone `isLoading`, `errorMessage` y datos; las acciones devuelven `Future<String?>` (error o `null`) o un `Result`. No importa widgets ni `BuildContext`. Constructor con parámetros privados nombrados: `XViewModel({required this._repo})`.
- **Repositorio:** interfaz en `data/repositories/<dominio>/<x>_repository.dart` y una implementación por fuente (`_fake`, después `_remote`). Devuelve `Result<T>`; el error trae el `code` estable del backend. Si sus datos cambian, extiende `ChangeNotifier` y notifica tras cada escritura.
- **Estados (F6):** primera carga con `LoadingView`, error con `ErrorView` (botón "Reintentar"), vacío con el estado propio de la pantalla; errores de acciones con `showErrorSnackBar`.
- Las pantallas nunca importan `FakeStore` ni un repositorio concreto.

### Backend (apps/api)

COMPLETA:

## Estrategia de testing

COMPLETA: qué se prueba en cada app, con qué comando y qué pasa si falla. Un bug corregido llega con la prueba que lo habría detectado.

## Flujo de Git

COMPLETA: ramas, commits, PR y quién aprueba.

## Al clonar

COMPLETA: comandos exactos y probados.
