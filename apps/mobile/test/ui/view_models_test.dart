import 'package:flutter_test/flutter_test.dart';

import 'package:citalis_app/data/fake/fake_store.dart';
import 'package:citalis_app/data/repositories/business/business_repository_fake.dart';
import 'package:citalis_app/data/repositories/favorites/favorites_repository_fake.dart';
import 'package:citalis_app/data/repositories/reservation/reservation_repository_fake.dart';
import 'package:citalis_app/domain/models/reservation.dart';
import 'package:citalis_app/ui/booking/view_models/booking_view_model.dart';
import 'package:citalis_app/ui/favorites/view_models/favorites_view_model.dart';
import 'package:citalis_app/ui/reservations/view_models/reservations_view_model.dart';
import 'package:citalis_app/utils/result.dart';

void main() {
  late FakeStore store;

  setUp(() => store = FakeStore());

  test(
    'FavoritesViewModel carga y se actualiza al quitar un favorito',
    () async {
      final repo = FakeFavoritesRepository(store);
      final vm = FavoritesViewModel(favoritesRepository: repo);

      await vm.load();
      expect(vm.favorites.map((b) => b.id), containsAll(['b1', 'b3']));

      expect(await vm.remove('b1'), isNull);
      await Future<void>.delayed(FakeStore.latency * 2); // recarga por listener
      expect(vm.favorites.map((b) => b.id), ['b3']);
      vm.dispose();
    },
  );

  test('ReservationsViewModel separa próximas e historial', () async {
    final vm = ReservationsViewModel(
      reservationRepository: FakeReservationRepository(store),
    );
    await vm.load();

    expect(vm.upcoming, isNotEmpty);
    expect(
      vm.upcoming.every((r) => r.status == ReservationStatus.upcoming),
      isTrue,
    );
    expect(
      vm.history.every((r) => r.status != ReservationStatus.upcoming),
      isTrue,
    );
    vm.dispose();
  });

  test(
    'BookingViewModel crea la reserva y rechaza el mismo horario dos veces',
    () async {
      final reservations = FakeReservationRepository(store);
      BookingViewModel newVm() => BookingViewModel(
        businessId: 'b1',
        serviceId: 's1-1',
        businessRepository: FakeBusinessRepository(store),
        reservationRepository: reservations,
      );

      final vm = newVm();
      await vm.load();
      final free = vm.slots.indexWhere((s) => s.available);
      vm.selectSlot(free);
      final slotStart = vm.slots[free].start;

      expect(await vm.confirm(), isA<Ok<Reservation>>());

      // Otro cliente intenta el mismo horario con datos viejos.
      final other = newVm();
      await other.load();
      other.selectSlot(free);
      // El slot ya aparece ocupado tras recargar disponibilidad.
      expect(other.slots[free].available, isFalse);
      final direct = await reservations.create(
        businessId: 'b1',
        serviceId: 's1-1',
        scheduledAt: slotStart,
      );
      expect(direct, isA<Failure<Reservation>>());
      expect(
        (direct as Failure<Reservation>).error.code,
        'RESERVATION_OVERLAP',
      );
      vm.dispose();
      other.dispose();
    },
  );
}
