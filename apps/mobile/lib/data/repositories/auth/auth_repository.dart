import 'package:flutter/foundation.dart';

import '../../../utils/result.dart';

/// Sesión del usuario (Req 1.1–1.4).
///
/// Implementación real: Firebase Auth para credenciales + `POST /auth/register`
/// para crear el perfil en Citalis. Ver `docs/backend/endpoints-app.md`.
abstract class AuthRepository extends ChangeNotifier {
  bool get isAuthenticated;

  Future<Result<void>> login({required String email, required String password});

  Future<Result<void>> register({
    required String name,
    required String email,
    required String password,
  });

  Future<Result<void>> logout();

  Future<Result<void>> sendPasswordReset(String email);

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
