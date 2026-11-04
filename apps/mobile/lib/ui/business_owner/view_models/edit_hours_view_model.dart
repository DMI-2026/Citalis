import '../../../data/repositories/my_business/my_business_repository.dart';
import '../../../domain/models/day_hours.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

/// Horario semanal del negocio (Req 3.1).
class EditHoursViewModel extends ViewModel {
  EditHoursViewModel({required this._myBusinessRepository}) {
    _myBusinessRepository.addListener(load);
  }

  final MyBusinessRepository _myBusinessRepository;

  bool _isLoading = false;
  String? _errorMessage;
  List<DayHours> _weeklyHours = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Lunes (0) a domingo (6).
  List<DayHours> get weeklyHours => _weeklyHours;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    switch (await _myBusinessRepository.getMyBusiness()) {
      case Ok(:final value):
        _weeklyHours = value?.weeklyHours ?? const [];
        _errorMessage = null;
      case Failure(:final error):
        _errorMessage = error.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> setOpen(int day, bool open) =>
      _setDay(day, _weeklyHours[day].copyWith(open: open));

  Future<String?> setOpenTime(int day, int hour, int minute) => _setDay(
    day,
    _weeklyHours[day].copyWith(openHour: hour, openMinute: minute),
  );

  Future<String?> setCloseTime(int day, int hour, int minute) => _setDay(
    day,
    _weeklyHours[day].copyWith(closeHour: hour, closeMinute: minute),
  );

  /// Devuelve el mensaje de error, o `null` si se guardó correctamente.
  Future<String?> _setDay(int day, DayHours hours) async {
    final result = await _myBusinessRepository.setDayHours(day, hours);
    return result is Failure<void> ? result.error.message : null;
  }

  @override
  void dispose() {
    _myBusinessRepository.removeListener(load);
    super.dispose();
  }
}
