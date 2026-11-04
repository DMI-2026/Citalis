import '../../../data/repositories/profile/profile_repository.dart';
import '../../../domain/models/user_profile.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

class EditProfileViewModel extends ViewModel {
  EditProfileViewModel({required this._profileRepository});

  final ProfileRepository _profileRepository;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  UserProfile? _profile;

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  UserProfile? get profile => _profile;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    switch (await _profileRepository.getProfile()) {
      case Ok(:final value):
        _profile = value;
        _errorMessage = null;
      case Failure(:final error):
        _errorMessage = error.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Devuelve el mensaje de error, o `null` si se guardó.
  Future<String?> save({
    required String name,
    required String email,
    required String phone,
  }) async {
    final current = _profile;
    if (current == null) return 'El perfil aún no se ha cargado';

    _isSubmitting = true;
    notifyListeners();

    final result = await _profileRepository.updateProfile(
      current.copyWith(
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
      ),
    );

    String? error;
    switch (result) {
      case Ok(:final value):
        _profile = value;
      case Failure(error: final e):
        error = e.message;
    }

    _isSubmitting = false;
    notifyListeners();
    return error;
  }
}
