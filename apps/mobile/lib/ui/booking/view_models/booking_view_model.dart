import '../../../data/repositories/business/business_repository.dart';
import '../../../data/repositories/reservation/reservation_repository.dart';
import '../../../domain/models/business.dart';
import '../../../domain/models/reservation.dart';
import '../../../domain/models/service.dart';
import '../../../domain/models/time_slot.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

class BookingViewModel extends ViewModel {
  BookingViewModel({
    required this.businessId,
    required this.serviceId,
    required this._businessRepository,
    required this._reservationRepository,
  }) {
    final today = DateTime.now();
    days = List.generate(
      14,
      (i) => DateTime(today.year, today.month, today.day + i),
    );
  }

  final String businessId;
  final String serviceId;
  final BusinessRepository _businessRepository;
  final ReservationRepository _reservationRepository;

  /// Los próximos 14 días a partir de hoy.
  late final List<DateTime> days;

  bool _isLoading = false;
  bool _isLoadingSlots = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  Business? _business;
  Service? _service;
  int _selectedDay = 1;
  List<TimeSlot> _slots = const [];
  int? _selectedSlot;

  bool get isLoading => _isLoading;
  bool get isLoadingSlots => _isLoadingSlots;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  Business? get business => _business;
  Service? get service => _service;
  int get selectedDay => _selectedDay;
  List<TimeSlot> get slots => _slots;
  int? get selectedSlot => _selectedSlot;
  bool get canConfirm => _selectedSlot != null && !_isSubmitting;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    switch (await _businessRepository.getById(businessId)) {
      case Ok(:final value):
        _business = value;
        final matches = value.services.where((s) => s.id == serviceId);
        if (matches.isEmpty) {
          _errorMessage = 'No encontramos este servicio';
        } else {
          _service = matches.first;
        }
      case Failure(:final error):
        _errorMessage = error.message;
    }

    _isLoading = false;
    notifyListeners();
    if (_service != null) await _loadSlots();
  }

  void selectDay(int index) {
    if (index == _selectedDay) return;
    _selectedDay = index;
    _selectedSlot = null;
    notifyListeners();
    _loadSlots();
  }

  void selectSlot(int index) {
    if (!_slots[index].available) return;
    _selectedSlot = index;
    notifyListeners();
  }

  Future<void> _loadSlots() async {
    final day = _selectedDay;
    _isLoadingSlots = true;
    _slots = const [];
    notifyListeners();

    final result = await _reservationRepository.getAvailability(
      businessId: businessId,
      serviceId: serviceId,
      date: days[day],
    );
    if (day != _selectedDay) return; // el usuario ya eligió otro día

    switch (result) {
      case Ok(:final value):
        _slots = value;
      case Failure(:final error):
        _errorMessage = error.message;
    }
    _isLoadingSlots = false;
    notifyListeners();
  }

  /// Crea la reserva. Devuelve `Ok(reserva)` o `Failure` con el mensaje;
  /// si el horario se ocupó mientras tanto, recarga la disponibilidad.
  Future<Result<Reservation>> confirm() async {
    final slot = _selectedSlot;
    if (slot == null) {
      return const Failure(
        AppException('VALIDATION_ERROR', 'Selecciona un horario'),
      );
    }
    _isSubmitting = true;
    notifyListeners();

    final result = await _reservationRepository.create(
      businessId: businessId,
      serviceId: serviceId,
      scheduledAt: _slots[slot].start,
    );

    _isSubmitting = false;
    if (result case Failure(:final error)
        when error.code == 'RESERVATION_OVERLAP') {
      _selectedSlot = null;
      await _loadSlots();
    }
    notifyListeners();
    return result;
  }
}
