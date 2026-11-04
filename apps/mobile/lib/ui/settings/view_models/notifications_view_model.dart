import '../../../data/repositories/notifications/notifications_repository.dart';
import '../../../domain/models/notification_settings.dart';
import '../../../utils/result.dart';
import '../../core/view_model.dart';

class NotificationsViewModel extends ViewModel {
  NotificationsViewModel({required this._notificationsRepository});

  final NotificationsRepository _notificationsRepository;

  bool _isLoading = false;
  String? _errorMessage;
  NotificationSettings? _settings;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  NotificationSettings? get settings => _settings;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    switch (await _notificationsRepository.getPreferences()) {
      case Ok(:final value):
        _settings = value;
        _errorMessage = null;
      case Failure(:final error):
        _errorMessage = error.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Cambia una preferencia de forma optimista: la UI se actualiza al
  /// instante y, si el guardado falla, se revierte. Devuelve el mensaje de
  /// error, o `null` si se guardó.
  Future<String?> update({bool? reminders, bool? promos, bool? news}) async {
    final previous = _settings;
    if (previous == null) return null;

    _settings = previous.copyWith(
      reminders: reminders,
      promos: promos,
      news: news,
    );
    notifyListeners();

    final result = await _notificationsRepository.updatePreferences(_settings!);
    if (result case Failure(:final error)) {
      _settings = previous;
      notifyListeners();
      return error.message;
    }
    return null;
  }
}
