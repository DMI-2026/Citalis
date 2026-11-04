import '../../../data/repositories/clients/clients_repository.dart';
import '../../../data/repositories/my_business/my_business_repository.dart';
import '../../../data/repositories/reservation/reservation_repository.dart';
import '../../../domain/models/my_business.dart';
import '../../../domain/models/reservation.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

/// Pestaña "Mi negocio": perfil, métricas, horarios y QR (Req 2.2, 2.5, 3.1).
class BusinessProfileViewModel extends ViewModel {
  BusinessProfileViewModel({
    required this._myBusinessRepository,
    required this._clientsRepository,
    required this._reservationRepository,
  }) {
    _myBusinessRepository.addListener(load);
    _reservationRepository.addListener(load);
  }

  final MyBusinessRepository _myBusinessRepository;
  final ClientsRepository _clientsRepository;
  final ReservationRepository _reservationRepository;

  bool _isLoading = false;
  String? _errorMessage;
  MyBusiness? _business;
  int _clientCount = 0;
  int _upcomingCount = 0;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MyBusiness? get business => _business;
  int get clientCount => _clientCount;
  int get upcomingCount => _upcomingCount;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final results = await (
      _myBusinessRepository.getMyBusiness(),
      _clientsRepository.getClients(),
      _reservationRepository.getBusinessReservations(
        from: today,
        to: today.add(const Duration(days: 365)),
      ),
    ).wait;

    switch (results) {
      case (Ok(value: final b), Ok(value: final clients), Ok(value: final rs)):
        _business = b;
        _clientCount = clients.length;
        _upcomingCount = rs
            .where((r) => r.status == ReservationStatus.upcoming)
            .length;
        _errorMessage = null;
      case (Failure(:final error), _, _):
      case (_, Failure(:final error), _):
      case (_, _, Failure(:final error)):
        _errorMessage = error.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _myBusinessRepository.removeListener(load);
    _reservationRepository.removeListener(load);
    super.dispose();
  }
}
