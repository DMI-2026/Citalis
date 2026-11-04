/// Resultado de una operación de repositorio: `Ok` con el valor o `Failure`
/// con el error. Los repositorios nunca lanzan excepciones hacia la UI.
///
/// Uso típico en un ViewModel:
/// ```dart
/// switch (await _repository.getFavorites()) {
///   case Ok(:final value):
///     _favorites = value;
///   case Failure(:final error):
///     _errorMessage = error.message;
/// }
/// ```
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.error);
  final AppException error;
}

/// Error de la app. `code` sigue el formato estable del backend
/// (`RESERVATION_OVERLAP`, `NOT_FOUND`, `NETWORK_ERROR`…) y `message` ya está
/// listo para mostrarse al usuario.
class AppException implements Exception {
  const AppException(this.code, this.message);

  final String code;
  final String message;

  @override
  String toString() => 'AppException($code): $message';
}
