import '../../../data/repositories/business/business_repository.dart';
import '../../../data/repositories/catalog/catalog_repository.dart';
import '../../../domain/models/business.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

class ExploreViewModel extends ViewModel {
  ExploreViewModel({
    required this._businessRepository,
    required this._catalogRepository,
  });

  static const allCategories = 'Todos';

  final BusinessRepository _businessRepository;
  final CatalogRepository _catalogRepository;

  bool _isLoading = false;
  bool _isSearching = false;
  String? _errorMessage;
  List<String> _categories = const [allCategories];
  List<Business> _nearby = const [];
  List<Business> _results = const [];
  String _selectedCategory = allCategories;
  String _query = '';
  int _searchRequest = 0;

  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  List<String> get categories => _categories;
  List<Business> get nearby => _nearby;
  List<Business> get results => _results;
  String get selectedCategory => _selectedCategory;
  String get query => _query;

  /// Carga inicial: categorías, "cerca de ti" y el primer listado.
  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final categories = await _catalogRepository.getCategories();
    final nearby = await _businessRepository.getNearby();

    switch (categories) {
      case Ok(:final value):
        _categories = [allCategories, ...value];
      case Failure(:final error):
        _errorMessage = error.message;
    }
    switch (nearby) {
      case Ok(:final value):
        _nearby = value;
      case Failure(:final error):
        _errorMessage = error.message;
    }

    _isLoading = false;
    notifyListeners();
    if (_errorMessage == null) await _search();
  }

  void selectCategory(String category) {
    if (category == _selectedCategory) return;
    _selectedCategory = category;
    notifyListeners();
    _search();
  }

  void setQuery(String query) {
    _query = query;
    notifyListeners();
    _search();
  }

  Future<void> _search() async {
    // Si el usuario sigue escribiendo, solo la última búsqueda cuenta.
    final request = ++_searchRequest;
    _isSearching = true;
    notifyListeners();

    final result = await _businessRepository.search(
      query: _query,
      category: _selectedCategory == allCategories ? null : _selectedCategory,
    );
    if (request != _searchRequest) return;

    switch (result) {
      case Ok(:final value):
        _results = value;
        _errorMessage = null;
      case Failure(:final error):
        _errorMessage = error.message;
    }
    _isSearching = false;
    notifyListeners();
  }
}
