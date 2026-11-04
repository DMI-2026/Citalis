/// Perfil del usuario autenticado (Req 7.1).
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? defaultCity;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.defaultCity,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? defaultCity,
  }) => UserProfile(
    id: id,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    defaultCity: defaultCity ?? this.defaultCity,
  );
}
