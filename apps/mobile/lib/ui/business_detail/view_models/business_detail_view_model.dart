import '../../../data/repositories/business/business_repository.dart';
import '../../../data/repositories/favorites/favorites_repository.dart';
import '../../../domain/models/business.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

class BusinessDetailViewModel extends ViewModel {
  BusinessDetailViewModel({
    required this.businessId,
    required this._businessRepository,
    required this._favoritesRepository,
  }) {
    _favoritesRepository.addListener(_refreshFavorite);
  }

  final String businessId;
  final BusinessRepository _businessRepository;
  final FavoritesRepository _favoritesRepository;

  bool _isLoading = false;
  String? _errorMessage;
  Business? _business;
  bool _isFavorite = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Business? get business => _business;
  bool get isFavorite => _isFavorite;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    switch (await _businessRepository.getById(businessId)) {
      case Ok(:final value):
        _business = value;
      case Failure(:final error):
        _errorMessage = error.message;
    }
    await _refreshFavorite();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _refreshFavorite() async {
    if (await _favoritesRepository.isFavorite(businessId) case Ok(
      :final value,
    )) {
      _isFavorite = value;
      notifyListeners();
    }
  }

  /// Cambio optimista: se marca de inmediato y se revierte si falla.
  /// Devuelve el mensaje de error, o `null` si salió bien.
  Future<String?> toggleFavorite() async {
    final wasFavorite = _isFavorite;
    _isFavorite = !wasFavorite;
    notifyListeners();

    final result = wasFavorite
        ? await _favoritesRepository.remove(businessId)
        : await _favoritesRepository.add(businessId);
    if (result case Failure(:final error)) {
      _isFavorite = wasFavorite;
      notifyListeners();
      return error.message;
    }
    return null;
  }

  @override
  void dispose() {
    _favoritesRepository.removeListener(_refreshFavorite);
    super.dispose();
  }
}
