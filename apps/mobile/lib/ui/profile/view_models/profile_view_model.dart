import '../../../data/repositories/auth/auth_repository.dart';
import '../../../data/repositories/favorites/favorites_repository.dart';
import '../../../data/repositories/my_business/my_business_repository.dart';
import '../../../data/repositories/profile/profile_repository.dart';
import '../../../data/repositories/reservation/reservation_repository.dart';
import '../../../domain/models/my_business.dart';
import '../../../domain/models/reservation.dart';
import '../../../domain/models/user_profile.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

class ProfileViewModel extends ViewModel {
  ProfileViewModel({
    required this._authRepository,
    required this._profileRepository,
    required this._favoritesRepository,
    required this._reservationRepository,
    required this._myBusinessRepository,
  }) {
    // Perfil, contadores y banner dependen de lo que cambie en otras pantallas.
    _profileRepository.addListener(load);
    _favoritesRepository.addListener(load);
    _reservationRepository.addListener(load);
    _myBusinessRepository.addListener(load);
  }

  final AuthRepository _authRepository;
  final ProfileRepository _profileRepository;
  final FavoritesRepository _favoritesRepository;
  final ReservationRepository _reservationRepository;
  final MyBusinessRepository _myBusinessRepository;

  bool _isLoading = false;
  String? _errorMessage;
  UserProfile? _profile;
  MyBusiness? _myBusiness;
  int _upcomingCount = 0;
  int _completedCount = 0;
  int _favoritesCount = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserProfile? get profile => _profile;
  MyBusiness? get myBusiness => _myBusiness;
  bool get hasBusiness => _myBusiness != null;
  int get upcomingCount => _upcomingCount;
  int get completedCount => _completedCount;
  int get favoritesCount => _favoritesCount;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    // Las cuatro consultas salen en paralelo.
    final profileFuture = _profileRepository.getProfile();
    final reservationsFuture = _reservationRepository.getMyReservations();
    final favoritesFuture = _favoritesRepository.getFavorites();
    final businessFuture = _myBusinessRepository.getMyBusiness();

    String? error;
    switch (await profileFuture) {
      case Ok(:final value):
        _profile = value;
      case Failure(error: final e):
        error = e.message;
    }
    switch (await reservationsFuture) {
      case Ok(:final value):
        _upcomingCount = value
            .where((r) => r.status == ReservationStatus.upcoming)
            .length;
        _completedCount = value
            .where((r) => r.status == ReservationStatus.completed)
            .length;
      case Failure(error: final e):
        error ??= e.message;
    }
    switch (await favoritesFuture) {
      case Ok(:final value):
        _favoritesCount = value.length;
      case Failure(error: final e):
        error ??= e.message;
    }
    switch (await businessFuture) {
      case Ok(:final value):
        _myBusiness = value;
      case Failure(error: final e):
        error ??= e.message;
    }

    _errorMessage = error;
    _isLoading = false;
    notifyListeners();
  }

  /// Devuelve el mensaje de error, o `null` si cerró sesión.
  Future<String?> logout() async {
    final result = await _authRepository.logout();
    return result is Failure<void> ? result.error.message : null;
  }

  @override
  void dispose() {
    _profileRepository.removeListener(load);
    _favoritesRepository.removeListener(load);
    _reservationRepository.removeListener(load);
    _myBusinessRepository.removeListener(load);
    super.dispose();
  }
}
