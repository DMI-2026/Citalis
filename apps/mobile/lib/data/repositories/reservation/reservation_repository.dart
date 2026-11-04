import 'package:flutter/foundation.dart';

import '../../../domain/models/reservation.dart';
import '../../../domain/models/time_slot.dart';
import '../../../utils/result.dart';

/// Reservas del cliente y agenda del negocio (Req 3.2–3.4). Notifica cada vez
/// que se crea o cancela una reserva.
/// Endpoints: `/reservations/*` y `GET /availability` (agenda-service).
abstract class ReservationRepository extends ChangeNotifier {
  /// Reservas del usuario como cliente (próximas e historial).
  Future<Result<List<Reservation>>> getMyReservations();

  Future<Result<Reservation>> getById(String id);

  Future<Result<List<TimeSlot>>> getAvailability({
    required String businessId,
    required String serviceId,
    required DateTime date,
  });

  Future<Result<Reservation>> create({
    required String businessId,
    required String serviceId,
    required DateTime scheduledAt,
  });

  Future<Result<void>> cancel(String id);

  /// Reservas recibidas por mi negocio en el rango `[from, to)` (modo empresa).
  Future<Result<List<Reservation>>> getBusinessReservations({
    required DateTime from,
    required DateTime to,
  });
}
