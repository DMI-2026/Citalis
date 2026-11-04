import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/business_image.dart';
import 'business_detail_screen.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final AppState _state = AppState.instance;
  int _tab = 0;

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

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final upcoming = _state.upcoming;
    final history = _state.history;
    final showing = _tab == 0 ? upcoming : history;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RESERVAS', style: AppTheme.eyebrow()),
              const SizedBox(height: 8),
              Text('Tus citas,\nordenadas.',
                  style: AppTheme.display(size: 32, weight: FontWeight.w400)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _SegmentedTab(
            labels: ['Próximas (${upcoming.length})', 'Historial'],
            value: _tab,
            onChanged: (v) => setState(() => _tab = v),
          ),
        ),
        const SizedBox(height: 20),
        if (showing.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: _EmptyReservations(upcoming: _tab == 0),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                for (final r in showing) ...[
                  _ReservationCard(
                    reservation: r,
                    onOpen: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BusinessDetailScreen(business: r.business),
                      ),
                    ),
                    onCancel: r.status == ReservationStatus.upcoming
                        ? () => _confirmCancel(context, r)
                        : null,
                  ),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  void _confirmCancel(BuildContext context, Reservation r) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(ctx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                  width: 40, height: 4, color: AppTheme.line),
            ),
            const SizedBox(height: 20),
            Text('Cancelar reserva',
                style: AppTheme.serif(size: 22, weight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(
              '¿Seguro que deseas cancelar tu ${r.service.name} en ${r.business.name}?',
              style:
                  AppTheme.sans(size: 14, color: AppTheme.inkMuted, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
              onPressed: () {
                _state.cancelReservation(r.id);
                Navigator.pop(ctx);
              },
              child: const Text('Sí, cancelar'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Mantener reserva'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SegmentedTab extends StatelessWidget {
  final List<String> labels;
  final int value;
  final ValueChanged<int> onChanged;

  const _SegmentedTab({
    required this.labels,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: List.generate(labels.length, (i) {
          final selected = i == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: AppTheme.sans(
                    size: 13,
                    weight: FontWeight.w600,
                    color: selected ? AppTheme.ink : AppTheme.inkMuted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyReservations extends StatelessWidget {
  final bool upcoming;
  const _EmptyReservations({required this.upcoming});

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
            child: const Icon(Icons.event_outlined, color: AppTheme.ink),
          ),
          const SizedBox(height: 20),
          Text(upcoming ? 'Sin próximas citas' : 'Sin historial aún',
              style: AppTheme.serif(size: 20, weight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            upcoming
                ? 'Explora negocios y reserva tu próxima experiencia.'
                : 'Cuando completes tu primera cita, aparecerá aquí.',
            textAlign: TextAlign.center,
            style:
                AppTheme.sans(size: 14, color: AppTheme.inkMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  final Reservation reservation;
  final VoidCallback onOpen;
  final VoidCallback? onCancel;

  const _ReservationCard({
    required this.reservation,
    required this.onOpen,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    final past = r.status != ReservationStatus.upcoming;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: BusinessImage(
                      url: r.business.heroImage,
                      fallbackLetter: r.business.name[0],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              r.business.name,
                              style: AppTheme.serif(
                                  size: 17, weight: FontWeight.w500),
                            ),
                          ),
                          _StatusChip(status: r.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(r.service.name,
                          style: AppTheme.sans(
                              size: 13, color: AppTheme.inkMuted)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.event_outlined,
                              size: 13, color: AppTheme.ink),
                          const SizedBox(width: 4),
                          Text(
                              '${formatReservationDate(r.when)} · ${formatReservationTime(r.when)}',
                              style: AppTheme.sans(
                                  size: 12,
                                  weight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.line),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: onOpen,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: Text(
                        past ? 'Reservar de nuevo' : 'Ver detalle',
                        style: AppTheme.sans(
                            size: 13, weight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
              if (onCancel != null) ...[
                Container(width: 1, height: 46, color: AppTheme.line),
                Expanded(
                  child: InkWell(
                    onTap: onCancel,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: Text(
                          'Cancelar',
                          style: AppTheme.sans(
                              size: 13,
                              weight: FontWeight.w600,
                              color: AppTheme.danger),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final ReservationStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    switch (status) {
      case ReservationStatus.upcoming:
        label = 'CONFIRMADA';
        color = AppTheme.success;
      case ReservationStatus.completed:
        label = 'COMPLETADA';
        color = AppTheme.inkMuted;
      case ReservationStatus.cancelled:
        label = 'CANCELADA';
        color = AppTheme.danger;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label,
          style: AppTheme.sans(
              size: 9,
              weight: FontWeight.w700,
              color: color,
              letterSpacing: 1)),
    );
  }
}
