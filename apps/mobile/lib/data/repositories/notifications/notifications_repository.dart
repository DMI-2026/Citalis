import 'package:flutter/foundation.dart';

import '../../../domain/models/notification_settings.dart';
import '../../../utils/result.dart';

/// Preferencias de notificación (Req 6.1, 7.3).
/// Endpoints: `GET /notifications/preferences`,
/// `PATCH /notifications/preferences`.
abstract class NotificationsRepository extends ChangeNotifier {
  Future<Result<NotificationSettings>> getPreferences();

  Future<Result<NotificationSettings>> updatePreferences(
    NotificationSettings settings,
  );
}
