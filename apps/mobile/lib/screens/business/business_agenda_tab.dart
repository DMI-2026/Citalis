import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';

class BusinessAgendaTab extends StatefulWidget {
  const BusinessAgendaTab({super.key});

  @override
  State<BusinessAgendaTab> createState() => _BusinessAgendaTabState();
}

class _BusinessAgendaTabState extends State<BusinessAgendaTab> {
  final AppState _state = AppState.instance;
  late DateTime _selectedDay;
  late List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);
    _selectedDay = base;
    _days = List.generate(14, (i) => base.add(Duration(days: i)));
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
    final todays = _state.businessReservationsForDay(_selectedDay);
    final upcoming =
        todays.where((r) => r.status == ReservationStatus.upcoming).toList();
    final completed =
        todays.where((r) => r.status == ReservationStatus.completed).toList();
    final cancelled =
        todays.where((r) => r.status == ReservationStatus.cancelled).toList();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AGENDA DEL DÍA', style: AppTheme.eyebrow()),
                    const SizedBox(height: 6),
                    Text(formatReservationDate(_selectedDay),
                        style: AppTheme.serif(
                            size: 24, weight: FontWeight.w500)),
                  ],
                ),
              ),
              _MetricCapsule(label: '${upcoming.length} activas'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 72,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final d = _days[i];
              final selected = d.year == _selectedDay.year &&
                  d.month == _selectedDay.month &&
                  d.day == _selectedDay.day;
              final count = _state.businessReservationsForDay(d).length;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 54,
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.ink : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: selected ? AppTheme.ink : AppTheme.line),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekdayShort(d.weekday - 1),
                        style: AppTheme.sans(
                          size: 10,
                          weight: FontWeight.w600,
                          letterSpacing: 1,
                          color:
                              selected ? Colors.white70 : AppTheme.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d.day}',
                        style: AppTheme.serif(
                          size: 18,
                          weight: FontWeight.w500,
                          color: selected ? Colors.white : AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: count > 0
                              ? (selected ? Colors.white : AppTheme.accent)
                              : Colors.transparent,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),
        if (todays.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: _EmptyAgenda(),
          )
        else ...[
          if (upcoming.isNotEmpty)
            _Section(
              label: 'PRÓXIMAS',
              count: upcoming.length,
              children: upcoming
                  .map((r) => _AgendaCard(reservation: r, past: false))
                  .toList(),
            ),
          if (completed.isNotEmpty)
            _Section(
              label: 'COMPLETADAS',
              count: completed.length,
              children: completed
                  .map((r) => _AgendaCard(reservation: r, past: true))
                  .toList(),
            ),
          if (cancelled.isNotEmpty)
            _Section(
              label: 'CANCELADAS',
              count: cancelled.length,
              children: cancelled
                  .map((r) => _AgendaCard(reservation: r, past: true, cancelled: true))
                  .toList(),
            ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _MetricCapsule extends StatelessWidget {
  final String label;
  const _MetricCapsule({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppTheme.success),
          ),
          const SizedBox(width: 6),
          Text(label,
              style: AppTheme.sans(
                  size: 11, weight: FontWeight.w600, color: AppTheme.success)),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final int count;
  final List<Widget> children;
  const _Section(
      {required this.label, required this.count, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Text(label, style: AppTheme.eyebrow()),
                const SizedBox(width: 8),
                Text('·  $count',
                    style:
                        AppTheme.sans(size: 11, color: AppTheme.inkMuted)),
              ],
            ),
          ),
          for (final c in children) ...[
            c,
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  final Reservation reservation;
  final bool past;
  final bool cancelled;
  const _AgendaCard({
    required this.reservation,
    required this.past,
    this.cancelled = false,
  });

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    final color = cancelled
        ? AppTheme.danger
        : past
            ? AppTheme.inkMuted
            : AppTheme.success;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formatReservationTime(r.when),
                  style: AppTheme.serif(size: 22, weight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text('${r.service.durationMinutes} min',
                  style: AppTheme.sans(
                      size: 11, color: AppTheme.inkMuted)),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            width: 1,
            height: 48,
            color: AppTheme.line,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.clientName,
                    style:
                        AppTheme.serif(size: 16, weight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(r.service.name,
                    style: AppTheme.sans(
                        size: 13, color: AppTheme.inkMuted)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration:
                          BoxDecoration(shape: BoxShape.circle, color: color),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cancelled
                          ? 'Cancelada'
                          : past
                              ? 'Completada'
                              : 'Confirmada',
                      style: AppTheme.sans(
                          size: 11,
                          weight: FontWeight.w600,
                          color: color,
                          letterSpacing: 0.4),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text('\$${r.service.price.toStringAsFixed(0)}',
              style: AppTheme.serif(size: 16, weight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _EmptyAgenda extends StatelessWidget {
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
            child: const Icon(Icons.event_available_outlined,
                color: AppTheme.ink),
          ),
          const SizedBox(height: 20),
          Text('Día libre',
              style: AppTheme.serif(size: 20, weight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            'No tienes citas agendadas para este día.',
            textAlign: TextAlign.center,
            style:
                AppTheme.sans(size: 14, color: AppTheme.inkMuted, height: 1.5),
          ),
        ],
      ),
    );
  }
}
