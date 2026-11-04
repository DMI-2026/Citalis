import 'package:flutter/foundation.dart';

import '../../../domain/models/user_profile.dart';
import '../../../utils/result.dart';

/// Perfil del usuario autenticado (Req 7.1, 5.3).
/// Endpoints: `GET /users/me`, `PATCH /users/me`.
abstract class ProfileRepository extends ChangeNotifier {
  Future<Result<UserProfile>> getProfile();

  Future<Result<UserProfile>> updateProfile(UserProfile profile);
}
