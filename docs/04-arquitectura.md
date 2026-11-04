# Arquitectura de Citalis

## Tabla de decisiones

| # | Decisión | Alternativa descartada | Por qué | Fecha |
|---|---|---|---|---|
| A-01 | COMPLETA: | | | |
| A-02 | La app Flutter usa **MVVM** (guía oficial de Flutter): pantallas → ViewModels (`ChangeNotifier`) → repositorios con interfaz, inyectados con `provider`; hoy con implementación fake en memoria | Estado global único (`AppState` singleton) leído directo por los widgets; BLoC/Riverpod | Separa UI de datos: el backend se conecta cambiando solo `lib/config/dependencies.dart`; los ViewModels se prueban sin widgets; `provider` + `ChangeNotifier` es lo mínimo que el equipo puede explicar en la defensa. Contrato de endpoints en [`backend/endpoints-app.md`](backend/endpoints-app.md) | 2026-11-04 |

## Cómo se compone

```mermaid
flowchart LR
  %% COMPLETA: máximo 8 nodos
```

COMPLETA: una frase por componente.

## Cómo escala

COMPLETA: primer cuello de botella, qué harían y qué no optimizan todavía.

## Cómo se aísla

COMPLETA: autenticación y autorización, secretos, datos personales y separación entre negocios.
