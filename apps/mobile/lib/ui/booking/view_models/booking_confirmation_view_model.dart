import '../../../data/repositories/reservation/reservation_repository.dart';
import '../../../domain/models/reservation.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

class BookingConfirmationViewModel extends ViewModel {
  BookingConfirmationViewModel({
    required this.reservationId,
    required this._reservationRepository,
    Reservation? initial,
  }) : _reservation = initial;

  final String reservationId;
  final ReservationRepository _reservationRepository;

  bool _isLoading = false;
  String? _errorMessage;
  Reservation? _reservation;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Reservation? get reservation => _reservation;

  /// Solo consulta al repositorio si no recibimos la reserva ya creada
  /// (p. ej. al abrir `/confirmation?id=…` desde un enlace).
  Future<void> load() async {
    if (_reservation != null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    switch (await _reservationRepository.getById(reservationId)) {
      case Ok(:final value):
        _reservation = value;
      case Failure(:final error):
        _errorMessage = error.message;
    }

    _isLoading = false;
    notifyListeners();
  }
}
