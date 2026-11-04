import '../../../data/repositories/favorites/favorites_repository.dart';
import '../../../domain/models/business.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

class FavoritesViewModel extends ViewModel {
  FavoritesViewModel({required this._favoritesRepository}) {
    // Si se agrega/quita un favorito desde otra pantalla, recargamos.
    _favoritesRepository.addListener(load);
  }

  final FavoritesRepository _favoritesRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Business> _favorites = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Business> get favorites => _favorites;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    switch (await _favoritesRepository.getFavorites()) {
      case Ok(:final value):
        _favorites = value;
        _errorMessage = null;
      case Failure(:final error):
        _errorMessage = error.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Devuelve el mensaje de error, o `null` si se quitó correctamente.
  Future<String?> remove(String businessId) async {
    final result = await _favoritesRepository.remove(businessId);
    return result is Failure<void> ? result.error.message : null;
  }

  @override
  void dispose() {
    _favoritesRepository.removeListener(load);
    super.dispose();
  }
}
