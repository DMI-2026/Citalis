import '../../../data/repositories/auth/auth_repository.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

class ChangePasswordViewModel extends ViewModel {
  ChangePasswordViewModel({required this._authRepository});

  final AuthRepository _authRepository;

  bool _isSubmitting = false;

  bool get isSubmitting => _isSubmitting;

  /// Devuelve el mensaje de error, o `null` si se actualizó.
  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  }) async {
    if (newPassword != confirmation) {
      return 'Las contraseñas nuevas no coinciden';
    }

    _isSubmitting = true;
    notifyListeners();

    final result = await _authRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    _isSubmitting = false;
    notifyListeners();
    return result is Failure<void> ? result.error.message : null;
  }
}
