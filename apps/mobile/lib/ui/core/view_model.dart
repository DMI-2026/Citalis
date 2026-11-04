import 'package:flutter/foundation.dart';

/// Base de todos los ViewModels.
///
/// Es un `ChangeNotifier` que ignora `notifyListeners()` después de `dispose()`:
/// una carga asíncrona puede terminar cuando la pantalla ya se cerró.
abstract class ViewModel extends ChangeNotifier {
  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
