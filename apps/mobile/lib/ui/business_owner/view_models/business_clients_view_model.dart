import '../../../data/repositories/clients/clients_repository.dart';
import '../../../data/repositories/reservation/reservation_repository.dart';
import '../../../domain/models/client_link.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

/// Directorio de clientes (Req 4.1). Se recarga cuando cambian las reservas,
/// porque de ellas se deriva el vínculo cliente-negocio.
class BusinessClientsViewModel extends ViewModel {
  BusinessClientsViewModel({
    required this._clientsRepository,
    required this._reservationRepository,
  }) {
    _reservationRepository.addListener(load);
  }

  final ClientsRepository _clientsRepository;
  final ReservationRepository _reservationRepository;

  bool _isLoading = false;
  bool _loadedOnce = false;
  String? _errorMessage;
  List<ClientLink> _all = const [];
  String _query = '';

  bool get isLoading => _isLoading;
  bool get hasLoaded => _loadedOnce;
  String? get errorMessage => _errorMessage;
  List<ClientLink> get allClients => _all;
  bool get hasQuery => _query.trim().isNotEmpty;

  /// Clientes filtrados por nombre o correo.
  List<ClientLink> get clients {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _all;
    return _all
        .where(
          (c) =>
              c.name.toLowerCase().contains(q) ||
              c.email.toLowerCase().contains(q),
        )
        .toList();
  }

  set query(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    switch (await _clientsRepository.getClients()) {
      case Ok(:final value):
        _all = value;
        _errorMessage = null;
        _loadedOnce = true;
      case Failure(:final error):
        _errorMessage = error.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _reservationRepository.removeListener(load);
    super.dispose();
  }
}
