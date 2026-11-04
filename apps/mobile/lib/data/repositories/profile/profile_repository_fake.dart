import '../../../domain/models/user_profile.dart';
import '../../../utils/result.dart';
import '../../fake/fake_store.dart';
import 'profile_repository.dart';

class FakeProfileRepository extends ProfileRepository {
  FakeProfileRepository(this._store);

  final FakeStore _store;

  @override
  Future<Result<UserProfile>> getProfile() async {
    await _store.delay();
    return Ok(_store.profile);
  }

  @override
  Future<Result<UserProfile>> updateProfile(UserProfile profile) async {
    await _store.delay();
    _store.profile = profile;
    notifyListeners();
    return Ok(profile);
  }
}
