String formatReservationDate(DateTime d) {
  const months = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];
  const weekdays = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
  final w = weekdays[(d.weekday - 1) % 7];
  final m = months[d.month - 1];
  return '$w ${d.day} $m';
}

String formatReservationTime(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String weekdayShort(int index) {
  const names = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
  return names[index % 7];
}

String weekdayFull(int index) {
  const names = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];
  return names[index % 7];
}
