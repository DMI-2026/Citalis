/// Horario de un día de la semana (Req 3.1). La lista semanal va de
/// lunes (índice 0) a domingo (índice 6), igual que `day_of_week` en el backend.
class DayHours {
  final bool open;
  final int openHour;
  final int openMinute;
  final int closeHour;
  final int closeMinute;

  const DayHours({
    required this.open,
    this.openHour = 10,
    this.openMinute = 0,
    this.closeHour = 20,
    this.closeMinute = 0,
  });

  String get label {
    if (!open) return 'Cerrado';
    final o =
        '${openHour.toString().padLeft(2, '0')}:${openMinute.toString().padLeft(2, '0')}';
    final c =
        '${closeHour.toString().padLeft(2, '0')}:${closeMinute.toString().padLeft(2, '0')}';
    return '$o – $c';
  }

  DayHours copyWith({
    bool? open,
    int? openHour,
    int? openMinute,
    int? closeHour,
    int? closeMinute,
  }) => DayHours(
    open: open ?? this.open,
    openHour: openHour ?? this.openHour,
    openMinute: openMinute ?? this.openMinute,
    closeHour: closeHour ?? this.closeHour,
    closeMinute: closeMinute ?? this.closeMinute,
  );
}
