import 'business.dart';
import 'service.dart';

enum ReservationStatus { upcoming, completed, cancelled }

/// Reserva de un cliente en un negocio (Req 3.3, 3.4).
class Reservation {
  final String id;
  final Business business;
  final Service service;
  final DateTime when;
  final ReservationStatus status;
  final String clientId;
  final String clientName;
  final String clientEmail;
  final String clientPhone;

  const Reservation({
    required this.id,
    required this.business,
    required this.service,
    required this.when,
    required this.status,
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.clientPhone,
  });

  Reservation copyWith({ReservationStatus? status}) => Reservation(
    id: id,
    business: business,
    service: service,
    when: when,
    status: status ?? this.status,
    clientId: clientId,
    clientName: clientName,
    clientEmail: clientEmail,
    clientPhone: clientPhone,
  );
}
