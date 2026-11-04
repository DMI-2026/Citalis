import 'service.dart';

/// Negocio tal como lo ve un cliente (exploración, detalle, reservas).
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
