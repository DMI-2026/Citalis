import 'day_hours.dart';
import 'service.dart';

/// Negocio del usuario en modo empresa (Req 2.1–2.5, 3.1). Inmutable: cada
/// cambio pasa por `MyBusinessRepository`, que devuelve la versión nueva.
class MyBusiness {
  final String id;
  final String name;
  final String category;
  final String description;
  final String phone;
  final String address;
  final String municipality;
  final String heroImage;
  final String deepLinkCode;
  final List<Service> services;
  final List<DayHours> weeklyHours; // lunes..domingo

  const MyBusiness({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.phone,
    required this.address,
    required this.municipality,
    required this.heroImage,
    required this.deepLinkCode,
    required this.services,
    required this.weeklyHours,
  });

  String get deepLink => 'https://citalis.app/n/$deepLinkCode';

  MyBusiness copyWith({
    String? name,
    String? category,
    String? description,
    String? phone,
    String? address,
    String? municipality,
    String? heroImage,
    List<Service>? services,
    List<DayHours>? weeklyHours,
  }) => MyBusiness(
    id: id,
    name: name ?? this.name,
    category: category ?? this.category,
    description: description ?? this.description,
    phone: phone ?? this.phone,
    address: address ?? this.address,
    municipality: municipality ?? this.municipality,
    heroImage: heroImage ?? this.heroImage,
    deepLinkCode: deepLinkCode,
    services: services ?? this.services,
    weeklyHours: weeklyHours ?? this.weeklyHours,
  );
}
