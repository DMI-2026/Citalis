import '../../../data/repositories/catalog/catalog_repository.dart';
import '../../../data/repositories/my_business/my_business_repository.dart';
import '../../../domain/models/my_business.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

/// Alta de negocio (Req 2.1).
class RegisterBusinessViewModel extends ViewModel {
  RegisterBusinessViewModel({
    required this._myBusinessRepository,
    required this._catalogRepository,
  });

  final MyBusinessRepository _myBusinessRepository;
  final CatalogRepository _catalogRepository;

  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;
  List<String> _categories = const [];
  List<String> _municipalities = const [];
  String _category = 'Peluquería';
  String _municipality = 'Cuernavaca';

  // Valores de demostración con los que arranca el formulario.
  String name = 'Estudio María';
  String description = 'Peluquería y color editorial con enfoque natural.';
  String phone = '+52 777 456 7890';
  String address = 'Av. Álvaro Obregón 320';

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

  /// Llamar tras cambiar un campo de texto para reevaluar [canSubmit].
  void fieldsChanged() => notifyListeners();

  bool get canSubmit =>
      !_isSaving &&
      name.trim().isNotEmpty &&
      description.trim().isNotEmpty &&
      phone.trim().isNotEmpty &&
      address.trim().isNotEmpty;

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
        _categories = cats;
        _municipalities = munis;
        if (!cats.contains(_category) && cats.isNotEmpty) {
          _category = cats.first;
        }
        if (!munis.contains(_municipality) && munis.isNotEmpty) {
          _municipality = munis.first;
        }
        _errorMessage = null;
      case (Failure(:final error), _):
      case (_, Failure(:final error)):
        _errorMessage = error.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Devuelve el mensaje de error, o `null` si se registró correctamente.
  Future<String?> submit() async {
    if (!canSubmit) return null;
    _isSaving = true;
    notifyListeners();

    final result = await _myBusinessRepository.register(
      name: name.trim(),
      category: _category,
      description: description.trim(),
      phone: phone.trim(),
      address: address.trim(),
      municipality: _municipality,
    );

    _isSaving = false;
    notifyListeners();
    return result is Failure<MyBusiness> ? result.error.message : null;
  }
}
