import '../../../domain/models/business.dart';
import '../../../utils/result.dart';

/// Negocios públicos para el cliente (Req 5.1–5.3, 2.2 lectura).
/// Endpoints: `GET /discover/businesses`, `GET /discover/nearby`,
/// `GET /discover/businesses/:id`.
abstract class BusinessRepository {
  Future<Result<List<Business>>> search({String? query, String? category});

  Future<Result<List<Business>>> getNearby({int limit = 4});

  Future<Result<Business>> getById(String id);
}
