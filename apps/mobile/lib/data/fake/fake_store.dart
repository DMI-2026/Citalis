import '../../domain/models/business.dart';
import '../../domain/models/day_hours.dart';
import '../../domain/models/my_business.dart';
import '../../domain/models/notification_settings.dart';
import '../../domain/models/reservation.dart';
import '../../domain/models/service.dart';
import '../../domain/models/user_profile.dart';
import 'seed_data.dart';

/// "Backend" en memoria del modo demo. Lo comparten todos los repositorios
/// fake para que una reserva creada como cliente aparezca también en la
/// agenda del negocio, igual que pasaría con la API real.
class FakeStore {
  FakeStore() {
    reservations.addAll(_seedClientReservations());
  }

  /// Latencia simulada de red: permite ver los estados de carga (F6).
  static const Duration latency = Duration(milliseconds: 200);

  static const String currentUserId = 'u-me';

  final List<Business> businesses = seedBusinesses;
  final Set<String> favoriteIds = {'b1', 'b3'};
  final List<Reservation> reservations = [];

  UserProfile profile = const UserProfile(
    id: currentUserId,
    name: 'María García',
    email: 'maria@correo.com',
    phone: '+52 777 234 5678',
    defaultCity: 'Cuernavaca',
  );
  NotificationSettings notifications = const NotificationSettings();
  MyBusiness? myBusiness;
  bool authenticated = false;

  Future<void> delay() => Future.delayed(latency);

  Business? businessById(String id) {
    for (final b in businesses) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// Vista "pública" de mi negocio, como la vería un cliente.
  Business myBusinessAsPublic(MyBusiness b) => Business(
    id: b.id,
    name: b.name,
    category: b.category,
    neighborhood: b.municipality,
    address: b.address,
    rating: 5.0,
    reviews: 0,
    distanceKm: 0,
    openHours: 'Hoy',
    heroImage: b.heroImage,
    gallery: const [],
    tagline: b.description,
    services: b.services,
    phone: b.phone,
  );

  MyBusiness createMyBusiness({
    required String name,
    required String category,
    required String description,
    required String phone,
    required String address,
    required String municipality,
  }) {
    const defaultHours = [
      DayHours(open: true, openHour: 10, closeHour: 20),
      DayHours(open: true, openHour: 10, closeHour: 20),
      DayHours(open: true, openHour: 10, closeHour: 20),
      DayHours(open: true, openHour: 10, closeHour: 20),
      DayHours(open: true, openHour: 10, closeHour: 20),
      DayHours(open: true, openHour: 11, closeHour: 18),
      DayHours(open: false),
    ];

    const id = 'mine';
    return MyBusiness(
      id: id,
      name: name,
      category: category,
      description: description,
      phone: phone,
      address: address,
      municipality: municipality,
      heroImage: seedDefaultHeroImage,
      deepLinkCode: id,
      services: const [
        Service(
          id: '$id-s1',
          name: 'Servicio ejemplo',
          description: 'Descripción breve del servicio.',
          durationMinutes: 60,
          price: 300,
        ),
      ],
      weeklyHours: defaultHours,
    );
  }

  Reservation clientReservation({
    required String id,
    required Business business,
    required Service service,
    required DateTime when,
    required ReservationStatus status,
  }) => Reservation(
    id: id,
    business: business,
    service: service,
    when: when,
    status: status,
    clientId: profile.id,
    clientName: profile.name,
    clientEmail: profile.email,
    clientPhone: profile.phone,
  );

  static DateTime _at(int addDays, int hour, int minute) {
    final now = DateTime.now();
    final d = DateTime(now.year, now.month, now.day, hour, minute);
    return d.add(Duration(days: addDays));
  }

  List<Reservation> _seedClientReservations() {
    final b = businesses;
    return [
      clientReservation(
        id: 'r1',
        business: b[0],
        service: b[0].services[0],
        when: _at(2, 11, 30),
        status: ReservationStatus.upcoming,
      ),
      clientReservation(
        id: 'r2',
        business: b[2],
        service: b[2].services[2],
        when: _at(6, 17, 0),
        status: ReservationStatus.upcoming,
      ),
      clientReservation(
        id: 'r3',
        business: b[3],
        service: b[3].services[0],
        when: _at(-14, 10, 0),
        status: ReservationStatus.completed,
      ),
      clientReservation(
        id: 'r4',
        business: b[1],
        service: b[1].services[0],
        when: _at(-28, 15, 30),
        status: ReservationStatus.completed,
      ),
    ];
  }

  /// Reservas de ejemplo de otros clientes para el negocio recién registrado.
  void seedBusinessReservations(MyBusiness b) {
    if (b.services.isEmpty) return;
    final asBusiness = myBusinessAsPublic(b);
    final s0 = b.services.first;
    final s1 = b.services.length > 1 ? b.services[1] : s0;

    Reservation other(
      String id,
      Service s,
      DateTime when,
      ReservationStatus status,
      String clientId,
      String name,
      String email,
      String phone,
    ) => Reservation(
      id: id,
      business: asBusiness,
      service: s,
      when: when,
      status: status,
      clientId: clientId,
      clientName: name,
      clientEmail: email,
      clientPhone: phone,
    );

    reservations.addAll([
      other(
        'bz1',
        s0,
        _at(0, 11, 0),
        ReservationStatus.upcoming,
        'u-laura',
        'Laura Pérez',
        'laura@correo.com',
        '+52 777 345 1122',
      ),
      other(
        'bz2',
        s1,
        _at(0, 14, 30),
        ReservationStatus.upcoming,
        'u-dani',
        'Daniela Soto',
        'dani@correo.com',
        '+52 777 882 5518',
      ),
      other(
        'bz3',
        s0,
        _at(1, 10, 15),
        ReservationStatus.upcoming,
        'u-ana',
        'Ana Ruiz',
        'ana@correo.com',
        '+52 777 118 2240',
      ),
      other(
        'bz4',
        s1,
        _at(-7, 16, 0),
        ReservationStatus.completed,
        'u-laura',
        'Laura Pérez',
        'laura@correo.com',
        '+52 777 345 1122',
      ),
      other(
        'bz5',
        s0,
        _at(-21, 12, 0),
        ReservationStatus.completed,
        'u-ana',
        'Ana Ruiz',
        'ana@correo.com',
        '+52 777 118 2240',
      ),
    ]);
  }
}
