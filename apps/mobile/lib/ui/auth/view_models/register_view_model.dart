import '../../../data/repositories/auth/auth_repository.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

class RegisterViewModel extends ViewModel {
  RegisterViewModel({required this._authRepository});

  final AuthRepository _authRepository;

  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  /// Devuelve el mensaje de error, o `null` si se creó la cuenta.
  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _isSubmitting = true;
    notifyListeners();

    final result = await _authRepository.register(
      name: name.trim(),
      email: email.trim(),
      password: password,
    );

    _isSubmitting = false;
    notifyListeners();
    return result is Failure<void> ? result.error.message : null;
  }
}
