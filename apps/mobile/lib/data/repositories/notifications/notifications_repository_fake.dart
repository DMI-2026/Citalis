import '../../../domain/models/notification_settings.dart';
import '../../../utils/result.dart';
import '../../fake/fake_store.dart';
import 'notifications_repository.dart';

class FakeNotificationsRepository extends NotificationsRepository {
  FakeNotificationsRepository(this._store);

  final FakeStore _store;

  @override
  Future<Result<NotificationSettings>> getPreferences() async {
    await _store.delay();
    return Ok(_store.notifications);
  }

  @override
  Future<Result<NotificationSettings>> updatePreferences(
    NotificationSettings settings,
  ) async {
    await _store.delay();
    _store.notifications = settings;
    notifyListeners();
    return Ok(settings);
  }
}
