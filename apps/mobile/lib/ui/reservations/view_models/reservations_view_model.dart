import '../../../data/repositories/reservation/reservation_repository.dart';
import '../../../domain/models/reservation.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

class ReservationsViewModel extends ViewModel {
  ReservationsViewModel({required this._reservationRepository}) {
    _reservationRepository.addListener(load);
  }

  final ReservationRepository _reservationRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Reservation> _upcoming = const [];
  List<Reservation> _history = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Próximas, de la más cercana a la más lejana.
  List<Reservation> get upcoming => _upcoming;

  /// Completadas y canceladas, de la más reciente a la más antigua.
  List<Reservation> get history => _history;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    switch (await _reservationRepository.getMyReservations()) {
      case Ok(:final value):
        _upcoming =
            value.where((r) => r.status == ReservationStatus.upcoming).toList()
              ..sort((a, b) => a.when.compareTo(b.when));
        _history =
            value.where((r) => r.status != ReservationStatus.upcoming).toList()
              ..sort((a, b) => b.when.compareTo(a.when));
        _errorMessage = null;
      case Failure(:final error):
        _errorMessage = error.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Devuelve el mensaje de error, o `null` si se canceló.
  Future<String?> cancel(String reservationId) async {
    final result = await _reservationRepository.cancel(reservationId);
    return result is Failure<void> ? result.error.message : null;
  }

  @override
  void dispose() {
    _reservationRepository.removeListener(load);
    super.dispose();
  }
}
