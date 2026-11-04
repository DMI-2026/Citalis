import '../../../domain/models/day_hours.dart';
import '../../../domain/models/my_business.dart';
import '../../../domain/models/service.dart';
import '../../../utils/result.dart';
import '../../fake/fake_store.dart';
import 'my_business_repository.dart';

class FakeMyBusinessRepository extends MyBusinessRepository {
  FakeMyBusinessRepository(this._store);

  final FakeStore _store;

  static const _noBusiness = AppException(
    'BUSINESS_NOT_FOUND',
    'Aún no registras un negocio',
  );

  @override
  Future<Result<MyBusiness?>> getMyBusiness() async {
    await _store.delay();
    return Ok(_store.myBusiness);
  }

  @override
  Future<Result<MyBusiness>> register({
    required String name,
    required String category,
    required String description,
    required String phone,
    required String address,
    required String municipality,
  }) async {
    await _store.delay();
    if (_store.myBusiness != null) {
      return const Failure(
        AppException(
          'BUSINESS_ALREADY_EXISTS',
          'Ya tienes un negocio registrado',
        ),
      );
    }
    final b = _store.createMyBusiness(
      name: name,
      category: category,
      description: description,
      phone: phone,
      address: address,
      municipality: municipality,
    );
    _store.myBusiness = b;
    _store.seedBusinessReservations(b);
    notifyListeners();
    return Ok(b);
  }

  Future<Result<MyBusiness>> _update(
    MyBusiness Function(MyBusiness current) change,
  ) async {
    await _store.delay();
    final current = _store.myBusiness;
    if (current == null) return const Failure(_noBusiness);
    final updated = change(current);
    _store.myBusiness = updated;
    notifyListeners();
    return Ok(updated);
  }

  @override
  Future<Result<MyBusiness>> updateProfile({
    String? name,
    String? category,
    String? description,
    String? phone,
    String? address,
    String? municipality,
    String? heroImage,
  }) => _update(
    (b) => b.copyWith(
      name: name,
      category: category,
      description: description,
      phone: phone,
      address: address,
      municipality: municipality,
      heroImage: heroImage,
    ),
  );

  @override
  Future<Result<Service>> addService({
    required String name,
    required String description,
    required int durationMinutes,
    required double price,
  }) async {
    final created = Service(
      id: 'svc-${DateTime.now().microsecondsSinceEpoch}',
      name: name,
      description: description,
      durationMinutes: durationMinutes,
      price: price,
    );
    final result = await _update(
      (b) => b.copyWith(services: [...b.services, created]),
    );
    return switch (result) {
      Ok() => Ok(created),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<Service>> updateService(Service service) async {
    final result = await _update(
      (b) => b.copyWith(
        services: [
          for (final s in b.services) s.id == service.id ? service : s,
        ],
      ),
    );
    return switch (result) {
      Ok() => Ok(service),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> deleteService(String serviceId) async {
    final result = await _update(
      (b) => b.copyWith(
        services: b.services.where((s) => s.id != serviceId).toList(),
      ),
    );
    return switch (result) {
      Ok() => const Ok(null),
      Failure(:final error) => Failure(error),
    };
  }

  @override
  Future<Result<void>> setDayHours(int dayIndex, DayHours hours) async {
    final result = await _update((b) {
      final week = [...b.weeklyHours];
      week[dayIndex] = hours;
      return b.copyWith(weeklyHours: week);
    });
    return switch (result) {
      Ok() => const Ok(null),
      Failure(:final error) => Failure(error),
    };
  }
}
