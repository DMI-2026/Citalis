import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/business_image.dart';

class BusinessClientsTab extends StatefulWidget {
  const BusinessClientsTab({super.key});

  @override
  State<BusinessClientsTab> createState() => _BusinessClientsTabState();
}

class _BusinessClientsTabState extends State<BusinessClientsTab> {
  final AppState _state = AppState.instance;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _state.addListener(_onChange);
  }

  @override
  void dispose() {
    _state.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => mounted ? setState(() {}) : null;

  @override
  Widget build(BuildContext context) {
    final all = _state.businessClients();
    final q = _query.trim().toLowerCase();
    final clients = q.isEmpty
        ? all
        : all
            .where((c) =>
                c.name.toLowerCase().contains(q) ||
                c.email.toLowerCase().contains(q))
            .toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('DIRECTORIO', style: AppTheme.eyebrow()),
              const SizedBox(height: 6),
              Text(
                  all.isEmpty
                      ? 'Aún no hay clientes'
                      : '${all.length} ${all.length == 1 ? "cliente" : "clientes"} vinculados',
                  style: AppTheme.serif(size: 24, weight: FontWeight.w500)),
              const SizedBox(height: 16),
              TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre o correo',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(left: 14, right: 10),
                    child: Icon(Icons.search, color: AppTheme.ink, size: 20),
                  ),
                  prefixIconConstraints:
                      BoxConstraints(minWidth: 0, minHeight: 0),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (clients.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: _EmptyClients(hasQuery: q.isNotEmpty),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                for (final c in clients) ...[
                  _ClientRow(
                    client: c,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _ClientDetailScreen(client: c),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _ClientRow extends StatelessWidget {
  final ClientLink client;
  final VoidCallback onTap;

  const _ClientRow({required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initials = client.name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0])
        .join();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.line),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppTheme.line),
              ),
              alignment: Alignment.center,
              child: Text(initials,
                  style:
                      AppTheme.serif(size: 16, weight: FontWeight.w500)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(client.name,
                      style: AppTheme.serif(
                          size: 17, weight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(client.email,
                      style: AppTheme.sans(
                          size: 12, color: AppTheme.inkMuted)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                          '${client.visits} ${client.visits == 1 ? "visita" : "visitas"}',
                          style: AppTheme.sans(
                              size: 12, weight: FontWeight.w600)),
                      Text('  ·  ',
                          style: AppTheme.sans(
                              size: 12, color: AppTheme.inkFaint)),
                      Text('última ${formatReservationDate(client.lastVisit)}',
                          style: AppTheme.sans(
                              size: 12, color: AppTheme.inkMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: AppTheme.inkFaint),
          ],
        ),
      ),
    );
  }
}

class _EmptyClients extends StatelessWidget {
  final bool hasQuery;
  const _EmptyClients({required this.hasQuery});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.surfaceAlt,
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(Icons.people_outline_rounded,
                color: AppTheme.ink),
          ),
          const SizedBox(height: 20),
          Text(hasQuery ? 'Sin resultados' : 'Sin clientes aún',
              style: AppTheme.serif(size: 20, weight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            hasQuery
                ? 'No encontramos clientes que coincidan con tu búsqueda.'
                : 'Los clientes aparecerán cuando realicen su primera reserva en tu negocio.',
            textAlign: TextAlign.center,
            style:
                AppTheme.sans(size: 14, color: AppTheme.inkMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Detalle del cliente — historial de citas (Req 4.2)
// ─────────────────────────────────────────────────────────────────
class _ClientDetailScreen extends StatelessWidget {
  final ClientLink client;
  const _ClientDetailScreen({required this.client});

  @override
  Widget build(BuildContext context) {
    final history = AppState.instance.clientHistory(client.email);
    final initials = client.name
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((s) => s[0])
        .join();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Cliente', style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppTheme.line),
                  ),
                  alignment: Alignment.center,
                  child: Text(initials,
                      style: AppTheme.serif(
                          size: 22, weight: FontWeight.w500)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(client.name,
                          style: AppTheme.serif(
                              size: 22, weight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(client.email,
                          style: AppTheme.sans(
                              size: 13, color: AppTheme.inkMuted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.line),
              ),
              child: Row(
                children: [
                  _StatCell(label: 'Visitas', value: '${client.visits}'),
                  Container(width: 1, height: 42, color: AppTheme.line),
                  _StatCell(
                    label: 'Gastado',
                    value: '\$${client.totalSpent.toStringAsFixed(0)}',
                  ),
                  Container(width: 1, height: 42, color: AppTheme.line),
                  _StatCell(
                    label: 'Última',
                    value: formatReservationDate(client.lastVisit),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => openUrl('tel:${client.phone}'),
                    icon: const Icon(Icons.phone_outlined, size: 16),
                    label: Text('Llamar',
                        style: AppTheme.sans(
                            size: 13, weight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        openUrl('mailto:${client.email}'),
                    icon: const Icon(Icons.mail_outlined, size: 16),
                    label: Text('Correo',
                        style: AppTheme.sans(
                            size: 13, weight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('HISTORIAL DE CITAS', style: AppTheme.eyebrow()),
            const SizedBox(height: 12),
            if (history.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text('Sin historial todavía.',
                    style:
                        AppTheme.sans(size: 14, color: AppTheme.inkMuted)),
              )
            else
              Column(
                children: [
                  for (final r in history) ...[
                    _HistoryTile(reservation: r),
                    const Divider(height: 24, color: AppTheme.line),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(value,
                style: AppTheme.serif(size: 18, weight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(label,
                style: AppTheme.sans(size: 11, color: AppTheme.inkMuted)),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Reservation reservation;
  const _HistoryTile({required this.reservation});

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    late final String stateLabel;
    late final Color stateColor;
    switch (r.status) {
      case ReservationStatus.upcoming:
        stateLabel = 'Próxima';
        stateColor = AppTheme.success;
      case ReservationStatus.completed:
        stateLabel = 'Completada';
        stateColor = AppTheme.inkMuted;
      case ReservationStatus.cancelled:
        stateLabel = 'Cancelada';
        stateColor = AppTheme.danger;
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatReservationDate(r.when),
                style: AppTheme.serif(size: 15, weight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(formatReservationTime(r.when),
                style:
                    AppTheme.sans(size: 12, color: AppTheme.inkMuted)),
          ],
        ),
        Container(
          width: 1,
          height: 36,
          color: AppTheme.line,
          margin: const EdgeInsets.symmetric(horizontal: 14),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(r.service.name,
                  style: AppTheme.sans(
                      size: 14, weight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(stateLabel,
                  style: AppTheme.sans(
                      size: 11,
                      weight: FontWeight.w600,
                      color: stateColor,
                      letterSpacing: 0.4)),
            ],
          ),
        ),
        Text('\$${r.service.price.toStringAsFixed(0)}',
            style: AppTheme.serif(size: 15, weight: FontWeight.w500)),
      ],
    );
  }
}
