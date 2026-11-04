import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import 'booking_confirmation_screen.dart';

class BookingScreen extends StatefulWidget {
  final Business business;
  final Service service;
  const BookingScreen({
    super.key,
    required this.business,
    required this.service,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late final List<DateTime> _days;
  int _selectedDay = 1;
  int? _selectedSlot;

  final List<String> _slots = const [
    '09:00',
    '09:45',
    '10:30',
    '11:15',
    '12:00',
    '13:30',
    '14:15',
    '15:00',
    '15:45',
    '16:30',
    '17:15',
    '18:00',
    '18:45',
    '19:30',
  ];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _days = List.generate(
        14, (i) => DateTime(today.year, today.month, today.day + i));
  }

  bool _isDisabled(int i) {
    final seed = _selectedDay * 7 + i;
    return seed % 5 == 2 || seed % 7 == 3;
  }

  @override
  Widget build(BuildContext context) {
    const monthNames = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre'
    ];
    const weekdayShort = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];

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
                              Text(widget.business.name.toUpperCase(),
                                  style: AppTheme.eyebrow()),
                              const SizedBox(height: 6),
                              Text(widget.service.name,
                                  style: AppTheme.serif(
                                      size: 18, weight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(
                                  '${widget.service.durationMinutes} min · ${widget.business.neighborhood}',
                                  style: AppTheme.sans(
                                      size: 13, color: AppTheme.inkMuted)),
                            ],
                          ),
                        ),
                        Text('\$${widget.service.price.toStringAsFixed(0)}',
                            style: AppTheme.serif(
                                size: 22, weight: FontWeight.w500)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('ELIGE UN DÍA', style: AppTheme.eyebrow()),
                  const SizedBox(height: 8),
                  Text(
                      '${monthNames[_days[_selectedDay].month - 1]} ${_days[_selectedDay].year}',
                      style: AppTheme.serif(size: 20, weight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 84,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _days.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final d = _days[i];
                        final selected = i == _selectedDay;
                        return GestureDetector(
                          onTap: () => setState(() {
                            _selectedDay = i;
                            _selectedSlot = null;
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 56,
                            decoration: BoxDecoration(
                              color:
                                  selected ? AppTheme.ink : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected ? AppTheme.ink : AppTheme.line,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  weekdayShort[(d.weekday - 1) % 7],
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
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(_slots.length, (i) {
                      final selected = i == _selectedSlot;
                      final disabled = _isDisabled(i);
                      return GestureDetector(
                        onTap: disabled
                            ? null
                            : () => setState(() => _selectedSlot = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
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
                            _slots[i],
                            style: AppTheme.sans(
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
                  onPressed: _selectedSlot == null
                      ? null
                      : () {
                          final slot = _slots[_selectedSlot!];
                          final parts = slot.split(':');
                          final when = DateTime(
                            _days[_selectedDay].year,
                            _days[_selectedDay].month,
                            _days[_selectedDay].day,
                            int.parse(parts[0]),
                            int.parse(parts[1]),
                          );
                          final r = Reservation(
                            id: 'r${DateTime.now().microsecondsSinceEpoch}',
                            business: widget.business,
                            service: widget.service,
                            when: when,
                            status: ReservationStatus.upcoming,
                          );
                          AppState.instance.addReservation(r);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BookingConfirmationScreen(reservation: r),
                            ),
                          );
                        },
                  child: Text(
                    _selectedSlot == null
                        ? 'Selecciona un horario'
                        : 'Confirmar reserva  ·  \$${widget.service.price.toStringAsFixed(0)}',
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
