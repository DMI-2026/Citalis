import '../../../data/repositories/auth/auth_repository.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

class LoginViewModel extends ViewModel {
  LoginViewModel({required this._authRepository});

  final AuthRepository _authRepository;

  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  /// Devuelve el mensaje de error, o `null` si inició sesión.
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    final result = await _authRepository.login(
      email: email.trim(),
      password: password,
    );

    _isSubmitting = false;
    notifyListeners();
    return result is Failure<void> ? result.error.message : null;
  }

  /// Devuelve el mensaje de error, o `null` si se envió el correo.
  Future<String?> sendPasswordReset(String email) async {
    final result = await _authRepository.sendPasswordReset(email.trim());
    return result is Failure<void> ? result.error.message : null;
  }
}
