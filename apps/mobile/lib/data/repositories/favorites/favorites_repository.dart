import 'package:flutter/foundation.dart';

import '../../../domain/models/business.dart';
import '../../../utils/result.dart';

/// Favoritos del usuario. Notifica al agregar o quitar uno.
/// Endpoints: `GET /favorites`, `PUT /favorites/:businessId`,
/// `DELETE /favorites/:businessId`.
abstract class FavoritesRepository extends ChangeNotifier {
  Future<Result<List<Business>>> getFavorites();

  Future<Result<bool>> isFavorite(String businessId);

  Future<Result<void>> add(String businessId);

  Future<Result<void>> remove(String businessId);
}
