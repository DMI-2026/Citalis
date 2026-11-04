import '../../../data/repositories/my_business/my_business_repository.dart';
import '../../../domain/models/service.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

class BusinessServicesViewModel extends ViewModel {
  BusinessServicesViewModel({required this._myBusinessRepository}) {
    _myBusinessRepository.addListener(load);
  }

  final MyBusinessRepository _myBusinessRepository;

  bool _isLoading = false;
  bool _loadedOnce = false;
  String? _errorMessage;
  List<Service> _services = const [];

  bool get isLoading => _isLoading;
  bool get hasLoaded => _loadedOnce;
  String? get errorMessage => _errorMessage;
  List<Service> get services => _services;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    switch (await _myBusinessRepository.getMyBusiness()) {
      case Ok(:final value):
        _services = value?.services ?? const [];
        _errorMessage = null;
        _loadedOnce = true;
      case Failure(:final error):
        _errorMessage = error.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Devuelve el mensaje de error, o `null` si se eliminó correctamente.
  Future<String?> delete(String serviceId) async {
    final result = await _myBusinessRepository.deleteService(serviceId);
    return result is Failure<void> ? result.error.message : null;
  }

  @override
  void dispose() {
    _myBusinessRepository.removeListener(load);
    super.dispose();
  }
}
