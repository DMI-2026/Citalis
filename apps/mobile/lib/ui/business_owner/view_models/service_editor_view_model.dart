import '../../../data/repositories/my_business/my_business_repository.dart';
import '../../../domain/models/service.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

/// Formulario para crear o editar un servicio (Req 2.4).
class ServiceEditorViewModel extends ViewModel {
  ServiceEditorViewModel({required this._myBusinessRepository, this.service})
    : _name = service?.name ?? '',
      _description = service?.description ?? '',
      _duration = service?.durationMinutes.toString() ?? '45',
      _price = service?.price.toStringAsFixed(0) ?? '';

  final MyBusinessRepository _myBusinessRepository;

  /// `null` si es un servicio nuevo.
  final Service? service;

  String _name;
  String _description;
  String _duration;
  String _price;
  bool _isSaving = false;

  bool get isNew => service == null;
  bool get isSaving => _isSaving;
  String get name => _name;
  String get description => _description;
  String get duration => _duration;
  String get price => _price;

  set name(String v) => _set(() => _name = v);
  set description(String v) => _set(() => _description = v);
  set duration(String v) => _set(() => _duration = v);
  set price(String v) => _set(() => _price = v);

  void _set(void Function() change) {
    change();
    notifyListeners();
  }

  int? get _parsedDuration => int.tryParse(_duration.trim());
  double? get _parsedPrice => double.tryParse(_price.trim());

  bool get isValid {
    final d = _parsedDuration;
    final p = _parsedPrice;
    return _name.trim().isNotEmpty && d != null && d > 0 && p != null && p > 0;
  }

  /// Devuelve el mensaje de error, o `null` si se guardó correctamente.
  Future<String?> save() async {
    if (!isValid || _isSaving) return null;
    _isSaving = true;
    notifyListeners();

    final s = service;
    final Result<Service> result = s == null
        ? await _myBusinessRepository.addService(
            name: _name.trim(),
            description: _description.trim(),
            durationMinutes: _parsedDuration!,
            price: _parsedPrice!,
          )
        : await _myBusinessRepository.updateService(
            s.copyWith(
              name: _name.trim(),
              description: _description.trim(),
              durationMinutes: _parsedDuration!,
              price: _parsedPrice!,
            ),
          );

    _isSaving = false;
    notifyListeners();
    return result is Failure<Service> ? result.error.message : null;
  }
}
