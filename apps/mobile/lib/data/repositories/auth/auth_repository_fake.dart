import '../../../utils/result.dart';
import '../../fake/fake_store.dart';
import 'auth_repository.dart';

class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository(this._store);

  final FakeStore _store;

  @override
  bool get isAuthenticated => _store.authenticated;

  @override
  Future<Result<void>> login({
    required String email,
    required String password,
  }) async {
    await _store.delay();
    _store.authenticated = true;
    notifyListeners();
    return const Ok(null);
  }

  @override
  Future<Result<void>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _store.delay();
    if (name.trim().isNotEmpty) {
      _store.profile = _store.profile.copyWith(name: name.trim());
    }
    if (email.trim().isNotEmpty) {
      _store.profile = _store.profile.copyWith(email: email.trim());
    }
    _store.authenticated = true;
    notifyListeners();
    return const Ok(null);
  }

  @override
  Future<Result<void>> logout() async {
    _store.authenticated = false;
    notifyListeners();
    return const Ok(null);
  }

  @override
  Future<Result<void>> sendPasswordReset(String email) async {
    await _store.delay();
    return const Ok(null);
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _store.delay();
    return const Ok(null);
  }
}
