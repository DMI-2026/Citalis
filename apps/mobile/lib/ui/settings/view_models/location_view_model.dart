import '../../../data/repositories/catalog/catalog_repository.dart';
import '../../../data/repositories/profile/profile_repository.dart';
import '../../../domain/models/user_profile.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

class LocationViewModel extends ViewModel {
  LocationViewModel({
    required this._profileRepository,
    required this._catalogRepository,
  });

  final ProfileRepository _profileRepository;
  final CatalogRepository _catalogRepository;

  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _profile;
  List<String> _municipalities = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get municipalities => _municipalities;
  String? get selectedCity => _profile?.defaultCity;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final profileFuture = _profileRepository.getProfile();
    final municipalitiesFuture = _catalogRepository.getMunicipalities();

    String? error;
    switch (await profileFuture) {
      case Ok(:final value):
        _profile = value;
      case Failure(error: final e):
        error = e.message;
    }
    switch (await municipalitiesFuture) {
      case Ok(:final value):
        _municipalities = value;
      case Failure(error: final e):
        error ??= e.message;
    }

    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  /// Guarda la ciudad por defecto de forma optimista. Devuelve el mensaje de
  /// error, o `null` si se guardó.
  Future<String?> selectCity(String city) async {
    final previous = _profile;
    if (previous == null || previous.defaultCity == city) return null;

    _profile = previous.copyWith(defaultCity: city);
    notifyListeners();

    final result = await _profileRepository.updateProfile(_profile!);
    if (result case Failure(:final error)) {
      _profile = previous;
      notifyListeners();
      return error.message;
    }
    return null;
  }
}
