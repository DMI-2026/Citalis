/// Servicio que ofrece un negocio (Req 2.4).
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
  }) => Service(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    price: price ?? this.price,
  );
}
