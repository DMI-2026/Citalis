import '../../../domain/models/reservation.dart';
import '../../../domain/models/time_slot.dart';
import '../../../utils/result.dart';
import '../../fake/fake_store.dart';
import 'reservation_repository.dart';

class FakeReservationRepository extends ReservationRepository {
  FakeReservationRepository(this._store);

  final FakeStore _store;

  static const _slots = [
    '09:00',
    '09:45',
    '10:30',
    '11:15',
    '12:00',
    '13:30',
    '14:15',
    '15:00',
    '15:45',
    '16:30',
    '17:15',
    '18:00',
    '18:45',
    '19:30',
  ];

  static const _notFound = AppException(
    'RESERVATION_NOT_FOUND',
    'No encontramos esta reserva',
  );

  @override
  Future<Result<List<Reservation>>> getMyReservations() async {
    await _store.delay();
    return Ok(
      _store.reservations
          .where((r) => r.clientId == FakeStore.currentUserId)
          .toList(),
    );
  }

  @override
  Future<Result<Reservation>> getById(String id) async {
    await _store.delay();
    for (final r in _store.reservations) {
      if (r.id == id) return Ok(r);
    }
    return const Failure(_notFound);
  }

  @override
  Future<Result<List<TimeSlot>>> getAvailability({
    required String businessId,
    required String serviceId,
    required DateTime date,
  }) async {
    await _store.delay();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    final dayIndex = day.difference(today).inDays;

    final slots = <TimeSlot>[];
    for (var i = 0; i < _slots.length; i++) {
      final parts = _slots[i].split(':');
      final start = DateTime(
        day.year,
        day.month,
        day.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      // Ocupación pseudoaleatoria (la misma del prototipo) + reservas reales.
      final seed = dayIndex * 7 + i;
      final busy = seed % 5 == 2 || seed % 7 == 3 || _taken(businessId, start);
      slots.add(TimeSlot(start: start, available: !busy));
    }
    return Ok(slots);
  }

  bool _taken(String businessId, DateTime start) => _store.reservations.any(
    (r) =>
        r.business.id == businessId &&
        r.status == ReservationStatus.upcoming &&
        r.when == start,
  );

  @override
  Future<Result<Reservation>> create({
    required String businessId,
    required String serviceId,
    required DateTime scheduledAt,
  }) async {
    await _store.delay();
    final business = _store.businessById(businessId);
    if (business == null) {
      return const Failure(
        AppException('BUSINESS_NOT_FOUND', 'No encontramos este negocio'),
      );
    }
    final service = business.services.where((s) => s.id == serviceId);
    if (service.isEmpty) {
      return const Failure(
        AppException('SERVICE_NOT_FOUND', 'No encontramos este servicio'),
      );
    }
    if (_taken(businessId, scheduledAt)) {
      return const Failure(
        AppException(
          'RESERVATION_OVERLAP',
          'Ese horario ya no está disponible',
        ),
      );
    }
    final r = _store.clientReservation(
      id: 'r${DateTime.now().microsecondsSinceEpoch}',
      business: business,
      service: service.first,
      when: scheduledAt,
      status: ReservationStatus.upcoming,
    );
    _store.reservations.add(r);
    notifyListeners();
    return Ok(r);
  }

  @override
  Future<Result<void>> cancel(String id) async {
    await _store.delay();
    final i = _store.reservations.indexWhere((r) => r.id == id);
    if (i == -1) return const Failure(_notFound);
    _store.reservations[i] = _store.reservations[i].copyWith(
      status: ReservationStatus.cancelled,
    );
    notifyListeners();
    return const Ok(null);
  }

  @override
  Future<Result<List<Reservation>>> getBusinessReservations({
    required DateTime from,
    required DateTime to,
  }) async {
    await _store.delay();
    final id = _store.myBusiness?.id;
    if (id == null) return const Ok([]);
    return Ok(
      _store.reservations
          .where(
            (r) =>
                r.business.id == id &&
                !r.when.isBefore(from) &&
                r.when.isBefore(to),
          )
          .toList()
        ..sort((a, b) => a.when.compareTo(b.when)),
    );
  }
}
