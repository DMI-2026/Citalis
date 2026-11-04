import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/business_image.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final Reservation reservation;

  const BookingConfirmationScreen({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final r = reservation;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
                children: [
                  Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: AppTheme.ink,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text('CONFIRMADO', style: AppTheme.eyebrow()),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tu cita está\nreservada.',
                    textAlign: TextAlign.center,
                    style: AppTheme.display(size: 34, weight: FontWeight.w400),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Te enviamos un recordatorio antes de la hora.',
                    textAlign: TextAlign.center,
                    style:
                        AppTheme.sans(size: 15, color: AppTheme.inkMuted),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.line),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.business.name.toUpperCase(),
                                  style: AppTheme.eyebrow()),
                              const SizedBox(height: 6),
                              Text(r.service.name,
                                  style: AppTheme.serif(
                                      size: 22, weight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text(r.business.address,
                                  style: AppTheme.sans(
                                      size: 13, color: AppTheme.inkMuted)),
                            ],
                          ),
                        ),
                        const _TicketDivider(),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('FECHA', style: AppTheme.eyebrow()),
                                    const SizedBox(height: 6),
                                    Text(formatReservationDate(r.when),
                                        style: AppTheme.serif(
                                            size: 18,
                                            weight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('HORA', style: AppTheme.eyebrow()),
                                    const SizedBox(height: 6),
                                    Text(formatReservationTime(r.when),
                                        style: AppTheme.serif(
                                            size: 18,
                                            weight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.end,
                                children: [
                                  Text('TOTAL', style: AppTheme.eyebrow()),
                                  const SizedBox(height: 6),
                                  Text(
                                      '\$${r.service.price.toStringAsFixed(0)}',
                                      style: AppTheme.serif(
                                          size: 18,
                                          weight: FontWeight.w500)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _IconLine(
                    icon: Icons.event_outlined,
                    label: 'Agregar al calendario',
                    onTap: () {},
                  ),
                  const Divider(height: 1, color: AppTheme.line),
                  _IconLine(
                    icon: Icons.place_outlined,
                    label: 'Cómo llegar',
                    onTap: () => openInMaps(
                        query: '${r.business.name}, ${r.business.address}'),
                  ),
                  const Divider(height: 1, color: AppTheme.line),
                  _IconLine(
                    icon: Icons.ios_share_rounded,
                    label: 'Compartir reserva',
                    onTap: () {},
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
                  onPressed: () =>
                      Navigator.popUntil(context, (r) => r.isFirst),
                  child: const Text('Volver al inicio'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketDivider extends StatelessWidget {
  const _TicketDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      child: Row(
        children: List.generate(
          40,
          (i) => Expanded(
            child: Container(
              height: 1,
              color: i.isEven ? AppTheme.line : Colors.transparent,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconLine({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppTheme.ink),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label,
                  style:
                      AppTheme.sans(size: 15, weight: FontWeight.w500)),
            ),
            const Icon(Icons.arrow_forward,
                size: 16, color: AppTheme.inkMuted),
          ],
        ),
      ),
    );
  }
}
