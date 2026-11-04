/// Preferencias de notificación del usuario (Req 6.1, 7.3).
class NotificationSettings {
  final bool reminders;
  final bool promos;
  final bool news;

  const NotificationSettings({
    this.reminders = true,
    this.promos = false,
    this.news = true,
  });

  NotificationSettings copyWith({bool? reminders, bool? promos, bool? news}) =>
      NotificationSettings(
        reminders: reminders ?? this.reminders,
        promos: promos ?? this.promos,
        news: news ?? this.news,
      );
}
