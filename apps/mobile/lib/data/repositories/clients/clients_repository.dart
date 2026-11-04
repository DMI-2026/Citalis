import '../../../domain/models/client_link.dart';
import '../../../domain/models/reservation.dart';
import '../../../utils/result.dart';

/// Directorio de clientes de mi negocio (Req 4.1, 4.2).
/// Endpoints: `GET /clients`, `GET /clients/:clientId/reservations`.
abstract class ClientsRepository {
  Future<Result<List<ClientLink>>> getClients();

  Future<Result<List<Reservation>>> getClientHistory(String clientId);
}
