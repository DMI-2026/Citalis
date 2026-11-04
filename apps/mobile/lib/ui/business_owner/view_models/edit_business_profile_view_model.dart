import '../../../data/repositories/catalog/catalog_repository.dart';
import '../../../data/repositories/my_business/my_business_repository.dart';
import '../../../domain/models/my_business.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

/// Edición del perfil del negocio (Req 2.2).
class EditBusinessProfileViewModel extends ViewModel {
  EditBusinessProfileViewModel({
    required this._myBusinessRepository,
    required this._catalogRepository,
    required this.business,
  }) : _category = business.category,
       _municipality = business.municipality;

  final MyBusinessRepository _myBusinessRepository;
  final CatalogRepository _catalogRepository;

  /// Valores actuales con los que se llena el formulario.
  final MyBusiness business;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<String> _categories = const [];
  List<String> _municipalities = const [];
  String _category;
  String _municipality;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  List<String> get categories => _categories;
  List<String> get municipalities => _municipalities;
  String get category => _category;
  String get municipality => _municipality;

  set category(String v) {
    _category = v;
    notifyListeners();
  }

  set municipality(String v) {
    _municipality = v;
    notifyListeners();
  }

  /// Carga los catálogos de los dropdowns.
  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final results = await (
      _catalogRepository.getCategories(),
      _catalogRepository.getMunicipalities(),
    ).wait;
    switch (results) {
      case (Ok(value: final cats), Ok(value: final munis)):
        _categories = _withCurrent(cats, _category);
        _municipalities = _withCurrent(munis, _municipality);
        _errorMessage = null;
      case (Failure(:final error), _):
      case (_, Failure(:final error)):
        _errorMessage = error.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// El valor actual siempre debe estar entre las opciones del dropdown.
  static List<String> _withCurrent(List<String> options, String current) =>
      options.contains(current) ? options : [current, ...options];

  /// Devuelve el mensaje de error, o `null` si se guardó correctamente.
  Future<String?> save({
    required String name,
    required String description,
    required String phone,
    required String address,
  }) async {
    _isSaving = true;
    notifyListeners();

    final result = await _myBusinessRepository.updateProfile(
      name: name.trim(),
      description: description.trim(),
      phone: phone.trim(),
      address: address.trim(),
      category: _category,
      municipality: _municipality,
    );

    _isSaving = false;
    notifyListeners();
    return result is Failure<MyBusiness> ? result.error.message : null;
  }
}
