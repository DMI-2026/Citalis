/// Cliente vinculado a mi negocio por sus reservas (Req 4.1).
class ClientLink {
  final String clientId;
  final String name;
  final String email;
  final String phone;
  final int visits;
  final DateTime lastVisit;
  final double totalSpent;

  const ClientLink({
    required this.clientId,
    required this.name,
    required this.email,
    required this.phone,
    required this.visits,
    required this.lastVisit,
    required this.totalSpent,
  });
}
