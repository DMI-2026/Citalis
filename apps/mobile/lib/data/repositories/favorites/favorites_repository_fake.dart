import '../../../domain/models/business.dart';
import '../../../utils/result.dart';
import '../../fake/fake_store.dart';
import 'favorites_repository.dart';

class FakeFavoritesRepository extends FavoritesRepository {
  FakeFavoritesRepository(this._store);

  final FakeStore _store;

  @override
  Future<Result<List<Business>>> getFavorites() async {
    await _store.delay();
    return Ok(
      _store.businesses
          .where((b) => _store.favoriteIds.contains(b.id))
          .toList(),
    );
  }

  @override
  Future<Result<bool>> isFavorite(String businessId) async {
    await _store.delay();
    return Ok(_store.favoriteIds.contains(businessId));
  }

  @override
  Future<Result<void>> add(String businessId) async {
    await _store.delay();
    _store.favoriteIds.add(businessId);
    notifyListeners();
    return const Ok(null);
  }

  @override
  Future<Result<void>> remove(String businessId) async {
    await _store.delay();
    _store.favoriteIds.remove(businessId);
    notifyListeners();
    return const Ok(null);
  }
}
