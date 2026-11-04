import '../../../utils/result.dart';
import '../../fake/fake_store.dart';
import '../../fake/seed_data.dart';
import 'catalog_repository.dart';

class FakeCatalogRepository implements CatalogRepository {
  FakeCatalogRepository(this._store);

  final FakeStore _store;

  @override
  Future<Result<List<String>>> getCategories() async {
    await _store.delay();
    return const Ok(seedBusinessCategories);
  }

  @override
  Future<Result<List<String>>> getMunicipalities() async {
    await _store.delay();
    return const Ok(seedMunicipalities);
  }
}
