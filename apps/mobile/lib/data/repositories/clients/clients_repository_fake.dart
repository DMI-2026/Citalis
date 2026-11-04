import '../../../domain/models/client_link.dart';
import '../../../domain/models/reservation.dart';
import '../../../utils/result.dart';
import '../../fake/fake_store.dart';
import 'clients_repository.dart';

class FakeClientsRepository implements ClientsRepository {
  FakeClientsRepository(this._store);

  final FakeStore _store;

  List<Reservation> _businessReservations() {
    final id = _store.myBusiness?.id;
    if (id == null) return const [];
    return _store.reservations.where((r) => r.business.id == id).toList();
  }

  @override
  Future<Result<List<ClientLink>>> getClients() async {
    await _store.delay();
    final map = <String, List<Reservation>>{};
    for (final r in _businessReservations()) {
      map.putIfAbsent(r.clientId, () => []).add(r);
    }
    final clients = map.values.map((group) {
      final first = group.first;
      final completed = group
          .where((r) => r.status == ReservationStatus.completed)
          .toList();
      final totalSpent = completed.fold<double>(
        0,
        (a, r) => a + r.service.price,
      );
      final last = group
          .map((r) => r.when)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      return ClientLink(
        clientId: first.clientId,
        name: first.clientName,
        email: first.clientEmail,
        phone: first.clientPhone,
        visits: completed.length,
        lastVisit: last,
        totalSpent: totalSpent,
      );
    }).toList()..sort((a, b) => b.lastVisit.compareTo(a.lastVisit));
    return Ok(clients);
  }

  @override
  Future<Result<List<Reservation>>> getClientHistory(String clientId) async {
    await _store.delay();
    return Ok(
      _businessReservations().where((r) => r.clientId == clientId).toList()
        ..sort((a, b) => b.when.compareTo(a.when)),
    );
  }
}
