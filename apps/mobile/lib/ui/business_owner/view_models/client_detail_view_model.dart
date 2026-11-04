import '../../../data/repositories/clients/clients_repository.dart';
import '../../../domain/models/client_link.dart';
import '../../../domain/models/reservation.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

/// Historial de citas de un cliente en mi negocio (Req 4.2).
class ClientDetailViewModel extends ViewModel {
  ClientDetailViewModel({
    required this._clientsRepository,
    required this.client,
  });

  final ClientsRepository _clientsRepository;
  final ClientLink client;

  bool _isLoading = false;
  String? _errorMessage;
  List<Reservation> _history = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Reservation> get history => _history;

  String get initials => client.name
      .split(' ')
      .where((s) => s.isNotEmpty)
      .take(2)
      .map((s) => s[0])
      .join();

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    switch (await _clientsRepository.getClientHistory(client.clientId)) {
      case Ok(:final value):
        _history = value;
        _errorMessage = null;
      case Failure(:final error):
        _errorMessage = error.message;
    }

    _isLoading = false;
    notifyListeners();
  }
}
