import '../../../data/repositories/reservation/reservation_repository.dart';
import '../../../domain/models/reservation.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

/// Agenda del negocio: carga las reservas de los próximos 14 días y las
/// agrupa por día.
class BusinessAgendaViewModel extends ViewModel {
  BusinessAgendaViewModel({required this._reservationRepository}) {
    final now = DateTime.now();
    final base = DateTime(now.year, now.month, now.day);
    _days = List.generate(14, (i) => base.add(Duration(days: i)));
    _selectedDay = base;
    _reservationRepository.addListener(load);
  }

  final ReservationRepository _reservationRepository;

  late final List<DateTime> _days;
  late DateTime _selectedDay;
  bool _isLoading = false;
  bool _loadedOnce = false;
  String? _errorMessage;
  List<Reservation> _reservations = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<DateTime> get days => _days;
  DateTime get selectedDay => _selectedDay;
  bool get hasLoaded => _loadedOnce;

  List<Reservation> reservationsFor(DateTime day) => _reservations
      .where(
        (r) =>
            r.when.year == day.year &&
            r.when.month == day.month &&
            r.when.day == day.day,
      )
      .toList();

  List<Reservation> get selectedDayReservations =>
      reservationsFor(_selectedDay);

  List<Reservation> selectedByStatus(ReservationStatus status) =>
      selectedDayReservations.where((r) => r.status == status).toList();

  int countFor(DateTime day) => reservationsFor(day).length;

  void selectDay(DateTime day) {
    _selectedDay = day;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    final result = await _reservationRepository.getBusinessReservations(
      from: _days.first,
      to: _days.last.add(const Duration(days: 1)),
    );
    switch (result) {
      case Ok(:final value):
        _reservations = value;
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
