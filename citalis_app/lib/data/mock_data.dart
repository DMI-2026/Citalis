import 'package:flutter/foundation.dart';

class Business {
  final String id;
  final String name;
  final String category;
  final String neighborhood;
  final String address;
  final double rating;
  final int reviews;
  final double distanceKm;
  final String openHours;
  final String heroImage;
  final List<String> gallery;
  final String tagline;
  final List<Service> services;
  final String phone;

  const Business({
    required this.id,
    required this.name,
    required this.category,
    required this.neighborhood,
    required this.address,
    required this.rating,
    required this.reviews,
    required this.distanceKm,
    required this.openHours,
    required this.heroImage,
    required this.gallery,
    required this.tagline,
    required this.services,
    this.phone = '+52 777 123 4567',
  });
}

class Service {
  final String id;
  final String name;
  final String description;
  final int durationMinutes;
  final double price;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMinutes,
    required this.price,
  });

  Service copyWith({
    String? name,
    String? description,
    int? durationMinutes,
    double? price,
  }) =>
      Service(
        id: id,
        name: name ?? this.name,
        description: description ?? this.description,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        price: price ?? this.price,
      );
}

enum ReservationStatus { upcoming, completed, cancelled }

class Reservation {
  final String id;
  final Business business;
  final Service service;
  final DateTime when;
  final ReservationStatus status;
  final String clientName;
  final String clientEmail;
  final String clientPhone;

  const Reservation({
    required this.id,
    required this.business,
    required this.service,
    required this.when,
    required this.status,
    this.clientName = 'María García',
    this.clientEmail = 'maria@correo.com',
    this.clientPhone = '+52 777 234 5678',
  });

  Reservation copyWith({ReservationStatus? status}) => Reservation(
        id: id,
        business: business,
        service: service,
        when: when,
        status: status ?? this.status,
        clientName: clientName,
        clientEmail: clientEmail,
        clientPhone: clientPhone,
      );
}

class UserProfile {
  final String name;
  final String email;
  final String phone;

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
  });

  UserProfile copyWith({String? name, String? email, String? phone}) =>
      UserProfile(
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
      );
}

class DayHours {
  final bool open;
  final int openHour;
  final int openMinute;
  final int closeHour;
  final int closeMinute;

  const DayHours({
    required this.open,
    this.openHour = 10,
    this.openMinute = 0,
    this.closeHour = 20,
    this.closeMinute = 0,
  });

  String get label {
    if (!open) return 'Cerrado';
    final o = '${openHour.toString().padLeft(2, '0')}:${openMinute.toString().padLeft(2, '0')}';
    final c = '${closeHour.toString().padLeft(2, '0')}:${closeMinute.toString().padLeft(2, '0')}';
    return '$o – $c';
  }

  DayHours copyWith({
    bool? open,
    int? openHour,
    int? openMinute,
    int? closeHour,
    int? closeMinute,
  }) =>
      DayHours(
        open: open ?? this.open,
        openHour: openHour ?? this.openHour,
        openMinute: openMinute ?? this.openMinute,
        closeHour: closeHour ?? this.closeHour,
        closeMinute: closeMinute ?? this.closeMinute,
      );
}

class MyBusiness {
  final String id;
  String name;
  String category;
  String description;
  String phone;
  String address;
  String municipality;
  String heroImage;
  List<Service> services;
  List<DayHours> weeklyHours; // lunes..domingo

  MyBusiness({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.phone,
    required this.address,
    required this.municipality,
    required this.heroImage,
    required this.services,
    required this.weeklyHours,
  });

  String get deepLink => 'https://citalis.app/n/$id';
}

enum AppMode { client, business }

class NotificationSettings {
  bool reminders;
  bool promos;
  bool news;
  NotificationSettings(
      {this.reminders = true, this.promos = false, this.news = true});
}

String _img(String id, {int w = 900}) =>
    'https://images.unsplash.com/photo-$id?w=$w&q=80&auto=format&fit=crop';

const String _salonA = '1560066984-138dadb4c035';
const String _salonB = '1522337360788-8b13dee7a37e';
const String _salonC = '1562322140-8baeececf3df';
const String _spaA = '1540555700478-4be289fbecef';
const String _spaB = '1544161515-4ab6ce6db874';
const String _spaC = '1600334129128-685c5582fd35';
const String _barberA = '1503951914875-452162b0f3f1';
const String _barberB = '1585747860715-2ba37e788b70';
const String _nailsA = '1604654894610-df63bc536371';
const String _nailsB = '1632345031435-8727f6897d53';
const String _browsA = '1583001809873-a128495da465';
const String _wellnessA = '1545205597-3d9d02c29597';
const String _wellnessB = '1506126613408-eca07ce68773';

final List<Business> mockBusinesses = [
  Business(
    id: 'b1',
    name: 'Casa Bella',
    category: 'Peluquería',
    neighborhood: 'Reforma',
    address: 'Av. Reforma 123, Cuernavaca',
    rating: 4.9,
    reviews: 182,
    distanceKm: 0.6,
    openHours: 'Hoy · 09:00 — 20:00',
    tagline: 'Color editorial y cortes de autor.',
    heroImage: _img(_salonA),
    gallery: [_img(_salonB, w: 600), _img(_salonC, w: 600)],
    services: [
      Service(
          id: 's1-1',
          name: 'Corte & lavado',
          description: 'Diagnóstico, corte personalizado y peinado.',
          durationMinutes: 45,
          price: 320),
      Service(
          id: 's1-2',
          name: 'Color global',
          description: 'Coloración profesional con tratamiento post-color.',
          durationMinutes: 120,
          price: 980),
      Service(
          id: 's1-3',
          name: 'Peinado evento',
          description: 'Recogido o suelto, incluye prueba previa.',
          durationMinutes: 60,
          price: 520),
    ],
  ),
  Business(
    id: 'b2',
    name: 'Atelier Nails',
    category: 'Uñas',
    neighborhood: 'Centro',
    address: 'Plaza Galerías · Local 42, Cuernavaca',
    rating: 4.8,
    reviews: 134,
    distanceKm: 1.2,
    openHours: 'Hoy · 10:00 — 21:00',
    tagline: 'Nail art minimalista hecho a mano.',
    heroImage: _img(_nailsA),
    gallery: [_img(_nailsB, w: 600), _img(_salonC, w: 600)],
    services: [
      Service(
          id: 's2-1',
          name: 'Manicure signature',
          description: 'Limado, cutícula y esmalte semipermanente.',
          durationMinutes: 50,
          price: 260),
      Service(
          id: 's2-2',
          name: 'Acrílicas con diseño',
          description: 'Aplicación completa con arte personalizado.',
          durationMinutes: 100,
          price: 680),
      Service(
          id: 's2-3',
          name: 'Pedicure spa',
          description: 'Exfoliación, mascarilla y esmalte.',
          durationMinutes: 60,
          price: 340),
    ],
  ),
  Business(
    id: 'b3',
    name: 'Noma Spa',
    category: 'Spa',
    neighborhood: 'Vista Hermosa',
    address: 'Vista Hermosa #88, Cuernavaca',
    rating: 4.9,
    reviews: 231,
    distanceKm: 2.4,
    openHours: 'Hoy · 11:00 — 22:00',
    tagline: 'Rituales de bienestar inspirados en el norte.',
    heroImage: _img(_spaA),
    gallery: [_img(_spaB, w: 600), _img(_spaC, w: 600)],
    services: [
      Service(
          id: 's3-1',
          name: 'Masaje profundo',
          description: 'Técnica sueca con aceites esenciales.',
          durationMinutes: 60,
          price: 780),
      Service(
          id: 's3-2',
          name: 'Facial hidra-glow',
          description: 'Limpieza, exfoliación y mascarilla iluminadora.',
          durationMinutes: 50,
          price: 620),
      Service(
          id: 's3-3',
          name: 'Ritual completo',
          description: 'Masaje + facial + aromaterapia (120 min).',
          durationMinutes: 120,
          price: 1480),
    ],
  ),
  Business(
    id: 'b4',
    name: 'Fox Barber',
    category: 'Barbería',
    neighborhood: 'Centro',
    address: 'Centro Histórico · Local 7, Cuernavaca',
    rating: 4.7,
    reviews: 198,
    distanceKm: 1.1,
    openHours: 'Hoy · 10:00 — 20:00',
    tagline: 'Afeitado clásico y cortes modernos.',
    heroImage: _img(_barberA),
    gallery: [_img(_barberB, w: 600)],
    services: [
      Service(
          id: 's4-1',
          name: 'Corte signature',
          description: 'Corte, perfilado y styling.',
          durationMinutes: 45,
          price: 260),
      Service(
          id: 's4-2',
          name: 'Afeitado tradicional',
          description: 'Toalla caliente, navaja y bálsamo.',
          durationMinutes: 30,
          price: 220),
      Service(
          id: 's4-3',
          name: 'Corte + barba',
          description: 'Experiencia completa para caballero.',
          durationMinutes: 70,
          price: 420),
    ],
  ),
  Business(
    id: 'b5',
    name: 'Luz Brow Bar',
    category: 'Cejas & Pestañas',
    neighborhood: 'Reforma',
    address: 'Av. Reforma 410, Int. 2, Cuernavaca',
    rating: 4.9,
    reviews: 96,
    distanceKm: 0.9,
    openHours: 'Hoy · 10:00 — 19:00',
    tagline: 'Microblading, lifting y laminado de cejas.',
    heroImage: _img(_browsA),
    gallery: [_img(_salonB, w: 600)],
    services: [
      Service(
          id: 's5-1',
          name: 'Diseño de cejas',
          description: 'Depilación con hilo y diseño personalizado.',
          durationMinutes: 30,
          price: 180),
      Service(
          id: 's5-2',
          name: 'Lifting de pestañas',
          description: 'Curvatura natural duradera (6 semanas).',
          durationMinutes: 50,
          price: 480),
    ],
  ),
  Business(
    id: 'b6',
    name: 'Studio Yoga',
    category: 'Wellness',
    neighborhood: 'Palmira',
    address: 'Palmira 221, Jardín, Cuernavaca',
    rating: 4.8,
    reviews: 312,
    distanceKm: 3.1,
    openHours: 'Hoy · 06:30 — 21:00',
    tagline: 'Yoga, meditación y breathwork en jardín.',
    heroImage: _img(_wellnessA),
    gallery: [_img(_wellnessB, w: 600)],
    services: [
      Service(
          id: 's6-1',
          name: 'Clase vinyasa',
          description: 'Sesión grupal 60 min, todos los niveles.',
          durationMinutes: 60,
          price: 220),
      Service(
          id: 's6-2',
          name: 'Yin + meditación',
          description: 'Práctica suave con cuencos tibetanos.',
          durationMinutes: 75,
          price: 260),
    ],
  ),
];

const List<String> categories = [
  'Todos',
  'Peluquería',
  'Uñas',
  'Spa',
  'Barbería',
  'Cejas & Pestañas',
  'Wellness',
];

const List<String> businessCategories = [
  'Peluquería',
  'Uñas',
  'Spa',
  'Barbería',
  'Cejas & Pestañas',
  'Wellness',
  'Masajes',
  'Depilación',
];

const List<String> municipalities = [
  'Cuernavaca',
  'Jiutepec',
  'Temixco',
  'Yautepec',
  'Emiliano Zapata',
  'Xochitepec',
];

Business businessById(String id) =>
    mockBusinesses.firstWhere((b) => b.id == id);

class ClientLink {
  final String name;
  final String email;
  final String phone;
  final int visits;
  final DateTime lastVisit;
  final double totalSpent;

  const ClientLink({
    required this.name,
    required this.email,
    required this.phone,
    required this.visits,
    required this.lastVisit,
    required this.totalSpent,
  });
}

class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  final Set<String> _favorites = {'b1', 'b3'};
  final List<Reservation> _reservations = _seedReservations();

  UserProfile _profile = const UserProfile(
    name: 'María García',
    email: 'maria@correo.com',
    phone: '+52 777 234 5678',
  );
  final NotificationSettings notifications = NotificationSettings();

  MyBusiness? _myBusiness;
  AppMode _mode = AppMode.client;

  // ─ getters ──────────────────────────────────────────────────────
  UserProfile get profile => _profile;
  MyBusiness? get myBusiness => _myBusiness;
  AppMode get mode => _mode;
  bool get hasBusiness => _myBusiness != null;

  Set<String> get favorites => _favorites;
  List<Business> get favoriteBusinesses =>
      mockBusinesses.where((b) => _favorites.contains(b.id)).toList();

  List<Reservation> get reservations => List.unmodifiable(_reservations);
  List<Reservation> get upcoming => _reservations
      .where((r) =>
          r.status == ReservationStatus.upcoming &&
          r.business.id != _myBusiness?.id)
      .toList()
    ..sort((a, b) => a.when.compareTo(b.when));
  List<Reservation> get history => _reservations
      .where((r) =>
          r.status != ReservationStatus.upcoming &&
          r.business.id != _myBusiness?.id)
      .toList()
    ..sort((a, b) => b.when.compareTo(a.when));

  // ─ favoritos ────────────────────────────────────────────────────
  bool isFavorite(String id) => _favorites.contains(id);
  void toggleFavorite(String id) {
    if (!_favorites.add(id)) _favorites.remove(id);
    notifyListeners();
  }

  // ─ reservas ─────────────────────────────────────────────────────
  void addReservation(Reservation r) {
    _reservations.add(r);
    notifyListeners();
  }

  void cancelReservation(String id) {
    final i = _reservations.indexWhere((r) => r.id == id);
    if (i == -1) return;
    _reservations[i] =
        _reservations[i].copyWith(status: ReservationStatus.cancelled);
    notifyListeners();
  }

  // ─ perfil ───────────────────────────────────────────────────────
  void updateProfile(UserProfile p) {
    _profile = p;
    notifyListeners();
  }

  void updateNotifications({bool? reminders, bool? promos, bool? news}) {
    if (reminders != null) notifications.reminders = reminders;
    if (promos != null) notifications.promos = promos;
    if (news != null) notifications.news = news;
    notifyListeners();
  }

  // ─ modo ─────────────────────────────────────────────────────────
  void switchMode(AppMode m) {
    if (!hasBusiness && m == AppMode.business) return;
    _mode = m;
    notifyListeners();
  }

  // ─ negocio ──────────────────────────────────────────────────────
  void registerBusiness(MyBusiness b) {
    _myBusiness = b;
    _mode = AppMode.business;
    _seedBusinessReservations(b);
    notifyListeners();
  }

  void updateBusinessProfile({
    String? name,
    String? category,
    String? description,
    String? phone,
    String? address,
    String? municipality,
    String? heroImage,
  }) {
    final b = _myBusiness;
    if (b == null) return;
    if (name != null) b.name = name;
    if (category != null) b.category = category;
    if (description != null) b.description = description;
    if (phone != null) b.phone = phone;
    if (address != null) b.address = address;
    if (municipality != null) b.municipality = municipality;
    if (heroImage != null) b.heroImage = heroImage;
    notifyListeners();
  }

  void addService(Service s) {
    _myBusiness?.services.add(s);
    notifyListeners();
  }

  void updateService(Service s) {
    final list = _myBusiness?.services;
    if (list == null) return;
    final i = list.indexWhere((x) => x.id == s.id);
    if (i != -1) list[i] = s;
    notifyListeners();
  }

  void removeService(String id) {
    _myBusiness?.services.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void setDayHours(int dayIndex, DayHours h) {
    final list = _myBusiness?.weeklyHours;
    if (list == null) return;
    list[dayIndex] = h;
    notifyListeners();
  }

  // ─ datos derivados para empresa ─────────────────────────────────
  List<Reservation> businessReservations() {
    final id = _myBusiness?.id;
    if (id == null) return const [];
    return _reservations.where((r) => r.business.id == id).toList()
      ..sort((a, b) => a.when.compareTo(b.when));
  }

  List<Reservation> businessReservationsForDay(DateTime day) {
    return businessReservations().where((r) {
      return r.when.year == day.year &&
          r.when.month == day.month &&
          r.when.day == day.day;
    }).toList();
  }

  List<ClientLink> businessClients() {
    final map = <String, List<Reservation>>{};
    for (final r in businessReservations()) {
      map.putIfAbsent(r.clientEmail, () => []).add(r);
    }
    return map.values.map((group) {
      final first = group.first;
      final completed = group
          .where((r) => r.status == ReservationStatus.completed)
          .toList();
      final totalSpent =
          completed.fold<double>(0, (a, r) => a + r.service.price);
      final last = group.map((r) => r.when).reduce((a, b) => a.isAfter(b) ? a : b);
      return ClientLink(
        name: first.clientName,
        email: first.clientEmail,
        phone: first.clientPhone,
        visits: completed.length,
        lastVisit: last,
        totalSpent: totalSpent,
      );
    }).toList()
      ..sort((a, b) => b.lastVisit.compareTo(a.lastVisit));
  }

  List<Reservation> clientHistory(String email) {
    return businessReservations()
        .where((r) => r.clientEmail == email)
        .toList()
      ..sort((a, b) => b.when.compareTo(a.when));
  }

  // ─ seeds ────────────────────────────────────────────────────────
  static List<Reservation> _seedReservations() {
    final now = DateTime.now();
    DateTime at(int addDays, int hour, int minute) {
      final d = DateTime(now.year, now.month, now.day, hour, minute);
      return d.add(Duration(days: addDays));
    }

    return [
      Reservation(
        id: 'r1',
        business: mockBusinesses[0],
        service: mockBusinesses[0].services[0],
        when: at(2, 11, 30),
        status: ReservationStatus.upcoming,
      ),
      Reservation(
        id: 'r2',
        business: mockBusinesses[2],
        service: mockBusinesses[2].services[2],
        when: at(6, 17, 0),
        status: ReservationStatus.upcoming,
      ),
      Reservation(
        id: 'r3',
        business: mockBusinesses[3],
        service: mockBusinesses[3].services[0],
        when: at(-14, 10, 0),
        status: ReservationStatus.completed,
      ),
      Reservation(
        id: 'r4',
        business: mockBusinesses[1],
        service: mockBusinesses[1].services[0],
        when: at(-28, 15, 30),
        status: ReservationStatus.completed,
      ),
    ];
  }

  void _seedBusinessReservations(MyBusiness b) {
    if (b.services.isEmpty) return;
    final now = DateTime.now();
    DateTime at(int addDays, int hour, int minute) {
      final d = DateTime(now.year, now.month, now.day, hour, minute);
      return d.add(Duration(days: addDays));
    }

    final asBusiness = Business(
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

    final s0 = b.services.first;
    final s1 = b.services.length > 1 ? b.services[1] : s0;

    _reservations.addAll([
      Reservation(
        id: 'bz1',
        business: asBusiness,
        service: s0,
        when: at(0, 11, 0),
        status: ReservationStatus.upcoming,
        clientName: 'Laura Pérez',
        clientEmail: 'laura@correo.com',
        clientPhone: '+52 777 345 1122',
      ),
      Reservation(
        id: 'bz2',
        business: asBusiness,
        service: s1,
        when: at(0, 14, 30),
        status: ReservationStatus.upcoming,
        clientName: 'Daniela Soto',
        clientEmail: 'dani@correo.com',
        clientPhone: '+52 777 882 5518',
      ),
      Reservation(
        id: 'bz3',
        business: asBusiness,
        service: s0,
        when: at(1, 10, 15),
        status: ReservationStatus.upcoming,
        clientName: 'Ana Ruiz',
        clientEmail: 'ana@correo.com',
        clientPhone: '+52 777 118 2240',
      ),
      Reservation(
        id: 'bz4',
        business: asBusiness,
        service: s1,
        when: at(-7, 16, 0),
        status: ReservationStatus.completed,
        clientName: 'Laura Pérez',
        clientEmail: 'laura@correo.com',
        clientPhone: '+52 777 345 1122',
      ),
      Reservation(
        id: 'bz5',
        business: asBusiness,
        service: s0,
        when: at(-21, 12, 0),
        status: ReservationStatus.completed,
        clientName: 'Ana Ruiz',
        clientEmail: 'ana@correo.com',
        clientPhone: '+52 777 118 2240',
      ),
    ]);
  }
}

String formatReservationDate(DateTime d) {
  const months = [
    'ene', 'feb', 'mar', 'abr', 'may', 'jun',
    'jul', 'ago', 'sep', 'oct', 'nov', 'dic'
  ];
  const weekdays = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
  final w = weekdays[(d.weekday - 1) % 7];
  final m = months[d.month - 1];
  return '$w ${d.day} $m';
}

String formatReservationTime(DateTime d) {
  final h = d.hour.toString().padLeft(2, '0');
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String weekdayShort(int index) {
  const names = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
  return names[index % 7];
}

String weekdayFull(int index) {
  const names = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves',
    'Viernes', 'Sábado', 'Domingo'
  ];
  return names[index % 7];
}

MyBusiness createMyBusiness({
  required String name,
  required String category,
  required String description,
  required String phone,
  required String address,
  required String municipality,
  String? heroImage,
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
  final services = [
    Service(
      id: '$id-s1',
      name: 'Servicio ejemplo',
      description: 'Descripción breve del servicio.',
      durationMinutes: 60,
      price: 300,
    ),
  ];

  return MyBusiness(
    id: id,
    name: name,
    category: category,
    description: description,
    phone: phone,
    address: address,
    municipality: municipality,
    heroImage: heroImage ?? _img(_salonA),
    services: services,
    weeklyHours: List<DayHours>.from(defaultHours),
  );
}
