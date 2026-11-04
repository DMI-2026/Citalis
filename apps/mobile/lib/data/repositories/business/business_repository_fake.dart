import '../../../domain/models/business.dart';
import '../../../utils/result.dart';
import '../../fake/fake_store.dart';
import 'business_repository.dart';

class FakeBusinessRepository implements BusinessRepository {
  FakeBusinessRepository(this._store);

  final FakeStore _store;

  @override
  Future<Result<List<Business>>> search({
    String? query,
    String? category,
  }) async {
    await _store.delay();
    final q = query?.trim().toLowerCase() ?? '';
    final result = _store.businesses.where((b) {
      if (category != null && b.category != category) return false;
      if (q.isEmpty) return true;
      return b.name.toLowerCase().contains(q) ||
          b.category.toLowerCase().contains(q) ||
          b.neighborhood.toLowerCase().contains(q);
    }).toList();
    return Ok(result);
  }

  @override
  Future<Result<List<Business>>> getNearby({int limit = 4}) async {
    await _store.delay();
    final sorted = [..._store.businesses]
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return Ok(sorted.take(limit).toList());
  }

  @override
  Future<Result<Business>> getById(String id) async {
    await _store.delay();
    final b = _store.businessById(id);
    if (b == null) {
      return const Failure(
        AppException('BUSINESS_NOT_FOUND', 'No encontramos este negocio'),
      );
    }
    return Ok(b);
  }
}
