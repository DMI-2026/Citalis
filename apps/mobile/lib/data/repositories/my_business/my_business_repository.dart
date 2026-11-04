import 'package:flutter/foundation.dart';

import '../../../domain/models/day_hours.dart';
import '../../../domain/models/my_business.dart';
import '../../../domain/models/service.dart';
import '../../../utils/result.dart';

/// Negocio del usuario en modo empresa (Req 2.1–2.5, 3.1). Notifica cada vez
/// que el negocio, sus servicios o su horario cambian.
/// Endpoints: `/businesses/me*` (negocios-service) y `/schedule/hours`
/// (agenda-service).
abstract class MyBusinessRepository extends ChangeNotifier {
  /// `Ok(null)` si el usuario todavía no registra un negocio.
  Future<Result<MyBusiness?>> getMyBusiness();

  Future<Result<MyBusiness>> register({
    required String name,
    required String category,
    required String description,
    required String phone,
    required String address,
    required String municipality,
  });

  Future<Result<MyBusiness>> updateProfile({
    String? name,
    String? category,
    String? description,
    String? phone,
    String? address,
    String? municipality,
    String? heroImage,
  });

  Future<Result<Service>> addService({
    required String name,
    required String description,
    required int durationMinutes,
    required double price,
  });

  Future<Result<Service>> updateService(Service service);

  Future<Result<void>> deleteService(String serviceId);

  /// `dayIndex`: 0 = lunes … 6 = domingo.
  Future<Result<void>> setDayHours(int dayIndex, DayHours hours);
}
