/// Horario que se puede reservar para un servicio en un día (Req 3.2).
class TimeSlot {
  final DateTime start;
  final bool available;

  const TimeSlot({required this.start, required this.available});
}
