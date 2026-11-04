import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/fake/fake_store.dart';
import '../data/repositories/auth/auth_repository.dart';
import '../data/repositories/auth/auth_repository_fake.dart';
import '../data/repositories/business/business_repository.dart';
import '../data/repositories/business/business_repository_fake.dart';
import '../data/repositories/catalog/catalog_repository.dart';
import '../data/repositories/catalog/catalog_repository_fake.dart';
import '../data/repositories/clients/clients_repository.dart';
import '../data/repositories/clients/clients_repository_fake.dart';
import '../data/repositories/favorites/favorites_repository.dart';
import '../data/repositories/favorites/favorites_repository_fake.dart';
import '../data/repositories/my_business/my_business_repository.dart';
import '../data/repositories/my_business/my_business_repository_fake.dart';
import '../data/repositories/notifications/notifications_repository.dart';
import '../data/repositories/notifications/notifications_repository_fake.dart';
import '../data/repositories/profile/profile_repository.dart';
import '../data/repositories/profile/profile_repository_fake.dart';
import '../data/repositories/reservation/reservation_repository.dart';
import '../data/repositories/reservation/reservation_repository_fake.dart';

/// Repositorios del modo demo (datos en memoria, sin backend).
///
/// Para conectar la API basta con escribir las implementaciones remotas
/// (p. ej. `RemoteFavoritesRepository`) y registrarlas aquí en lugar de las
/// fake: ViewModels y pantallas no cambian.
List<SingleChildWidget> fakeRepositories() {
  final store = FakeStore();
  return [
    ChangeNotifierProvider<AuthRepository>(
      create: (_) => FakeAuthRepository(store),
    ),
    ChangeNotifierProvider<ProfileRepository>(
      create: (_) => FakeProfileRepository(store),
    ),
    Provider<CatalogRepository>(create: (_) => FakeCatalogRepository(store)),
    Provider<BusinessRepository>(create: (_) => FakeBusinessRepository(store)),
    ChangeNotifierProvider<FavoritesRepository>(
      create: (_) => FakeFavoritesRepository(store),
    ),
    ChangeNotifierProvider<ReservationRepository>(
      create: (_) => FakeReservationRepository(store),
    ),
    Provider<ClientsRepository>(create: (_) => FakeClientsRepository(store)),
    ChangeNotifierProvider<MyBusinessRepository>(
      create: (_) => FakeMyBusinessRepository(store),
    ),
    ChangeNotifierProvider<NotificationsRepository>(
      create: (_) => FakeNotificationsRepository(store),
    ),
  ];
}
