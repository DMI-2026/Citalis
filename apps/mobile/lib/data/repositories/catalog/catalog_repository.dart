import '../../../utils/result.dart';

/// Catálogos de solo lectura.
/// Endpoints: `GET /catalogs/categories`, `GET /catalogs/municipalities`.
abstract class CatalogRepository {
  Future<Result<List<String>>> getCategories();

  Future<Result<List<String>>> getMunicipalities();
}
