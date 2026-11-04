import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../utils/result.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/async_views.dart';
import '../view_models/booking_view_model.dart';
import 'booking_confirmation_screen.dart';

class BookingScreen extends StatelessWidget {
  final String businessId;
  final String serviceId;
  const BookingScreen({
    super.key,
    required this.businessId,
    required this.serviceId,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BookingViewModel(
        businessId: businessId,
        serviceId: serviceId,
        businessRepository: context.read(),
        reservationRepository: context.read(),
      )..load(),
      child: const _BookingView(),
    );
  }
}

class _BookingView extends StatelessWidget {
  const _BookingView();

  Future<void> _confirm(BuildContext context) async {
    final result = await context.read<BookingViewModel>().confirm();
    if (!context.mounted) return;
    switch (result) {
      case Ok(:final value):
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingConfirmationScreen(
              reservationId: value.id,
              reservation: value,
            ),
          ),
        );
      case Failure(:final error):
        showErrorSnackBar(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    const monthNames = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    final vm = context.watch<BookingViewModel>();
    final business = vm.business;
    final service = vm.service;
    if (business == null || service == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: Text('Reservar', style: AppTheme.serif(size: 16)),
        ),
        body: vm.isLoading || vm.errorMessage == null
            ? const LoadingView()
            : ErrorView(message: vm.errorMessage!, onRetry: vm.load),
      );
    }
    final days = vm.days;
    final selectedDay = vm.selectedDay;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Reservar', style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.line),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                business.name.toUpperCase(),
                                style: AppTheme.eyebrow(),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                service.name,
                                style: AppTheme.serif(
                                  size: 18,
                                  weight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${service.durationMinutes} min · ${business.neighborhood}',
                                style: AppTheme.sans(
                                  size: 13,
                                  color: AppTheme.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${service.price.toStringAsFixed(0)}',
                          style: AppTheme.serif(
                            size: 22,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('ELIGE UN DÍA', style: AppTheme.eyebrow()),
                  const SizedBox(height: 8),
                  Text(
                    '${monthNames[days[selectedDay].month - 1]} ${days[selectedDay].year}',
                    style: AppTheme.serif(size: 20, weight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: days.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final d = days[i];
                        final selected = i == selectedDay;
                        return GestureDetector(
                          onTap: () => vm.selectDay(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 56,
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.ink
                                  : Colors.transparent,
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
                                    color: selected
                                        ? Colors.white70
                                        : AppTheme.inkMuted,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${d.day}',
                                  style: AppTheme.serif(
                                    size: 22,
                                    weight: FontWeight.w500,
                                    color: selected
                                        ? Colors.white
                                        : AppTheme.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('HORARIOS DISPONIBLES', style: AppTheme.eyebrow()),
                  const SizedBox(height: 12),
                  if (vm.isLoadingSlots)
                    const LoadingView()
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(vm.slots.length, (i) {
                        final selected = i == vm.selectedSlot;
                        final disabled = !vm.slots[i].available;
                        return GestureDetector(
                          onTap: disabled ? null : () => vm.selectSlot(i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: disabled
                                  ? AppTheme.surfaceAlt
                                  : selected
                                  ? AppTheme.ink
                                  : AppTheme.surface,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected ? AppTheme.ink : AppTheme.line,
                              ),
                            ),
                            child: Text(
                              formatReservationTime(vm.slots[i].start),
                              style:
                                  AppTheme.sans(
                                    size: 14,
                                    weight: FontWeight.w500,
                                    color: disabled
                                        ? AppTheme.inkFaint
                                        : selected
                                        ? Colors.white
                                        : AppTheme.ink,
                                  ).copyWith(
                                    decoration: disabled
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                            ),
                          ),
                        );
                      }),
                    ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(top: BorderSide(color: AppTheme.line)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              child: SafeArea(
                top: false,
                child: ElevatedButton(
                  onPressed: vm.canConfirm ? () => _confirm(context) : null,
                  child: Text(
                    vm.selectedSlot == null
                        ? 'Selecciona un horario'
                        : 'Confirmar reserva  ·  \$${service.price.toStringAsFixed(0)}',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
