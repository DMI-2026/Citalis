import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/reservation.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/async_views.dart';
import '../view_models/business_agenda_view_model.dart';

class BusinessAgendaTab extends StatelessWidget {
  const BusinessAgendaTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          BusinessAgendaViewModel(reservationRepository: context.read())
            ..load(),
      child: const _BusinessAgendaView(),
    );
  }
}

class _BusinessAgendaView extends StatelessWidget {
  const _BusinessAgendaView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BusinessAgendaViewModel>();
    final selectedDay = vm.selectedDay;
    final todays = vm.selectedDayReservations;
    final upcoming = vm.selectedByStatus(ReservationStatus.upcoming);
    final completed = vm.selectedByStatus(ReservationStatus.completed);
    final cancelled = vm.selectedByStatus(ReservationStatus.cancelled);

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
                    Text(
                      formatReservationDate(selectedDay),
                      style: AppTheme.serif(size: 24, weight: FontWeight.w500),
                    ),
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
            itemCount: vm.days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final d = vm.days[i];
              final selected =
                  d.year == selectedDay.year &&
                  d.month == selectedDay.month &&
                  d.day == selectedDay.day;
              final count = vm.countFor(d);
              return GestureDetector(
                onTap: () => vm.selectDay(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 54,
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.ink : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? AppTheme.ink : AppTheme.line,
                    ),
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
                          color: selected ? Colors.white70 : AppTheme.inkMuted,
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
        if (!vm.hasLoaded && vm.isLoading)
          const LoadingView()
        else if (!vm.hasLoaded && vm.errorMessage != null)
          ErrorView(message: vm.errorMessage!, onRetry: vm.load)
        else if (todays.isEmpty)
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
                  .map(
                    (r) => _AgendaCard(
                      reservation: r,
                      past: true,
                      cancelled: true,
                    ),
                  )
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
              shape: BoxShape.circle,
              color: AppTheme.success,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTheme.sans(
              size: 11,
              weight: FontWeight.w600,
              color: AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final int count;
  final List<Widget> children;
  const _Section({
    required this.label,
    required this.count,
    required this.children,
  });

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
                Text(
                  '·  $count',
                  style: AppTheme.sans(size: 11, color: AppTheme.inkMuted),
                ),
              ],
            ),
          ),
          for (final c in children) ...[c, const SizedBox(height: 10)],
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
              Text(
                formatReservationTime(r.when),
                style: AppTheme.serif(size: 22, weight: FontWeight.w500),
              ),
              const SizedBox(height: 2),
              Text(
                '${r.service.durationMinutes} min',
                style: AppTheme.sans(size: 11, color: AppTheme.inkMuted),
              ),
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
                Text(
                  r.clientName,
                  style: AppTheme.serif(size: 16, weight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  r.service.name,
                  style: AppTheme.sans(size: 13, color: AppTheme.inkMuted),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                      ),
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
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '\$${r.service.price.toStringAsFixed(0)}',
            style: AppTheme.serif(size: 16, weight: FontWeight.w500),
          ),
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
            child: const Icon(
              Icons.event_available_outlined,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Día libre',
            style: AppTheme.serif(size: 20, weight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'No tienes citas agendadas para este día.',
            textAlign: TextAlign.center,
            style: AppTheme.sans(
              size: 14,
              color: AppTheme.inkMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
