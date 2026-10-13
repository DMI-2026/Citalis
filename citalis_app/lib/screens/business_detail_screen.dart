import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/business_image.dart';
import 'booking_screen.dart';

class BusinessDetailScreen extends StatefulWidget {
  final Business business;
  const BusinessDetailScreen({super.key, required this.business});

  @override
  State<BusinessDetailScreen> createState() => _BusinessDetailScreenState();
}

class _BusinessDetailScreenState extends State<BusinessDetailScreen> {
  final AppState _state = AppState.instance;

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
    final b = widget.business;
    final isFav = _state.isFavorite(b.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppTheme.background,
            foregroundColor: AppTheme.ink,
            elevation: 0,
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(10),
              child: _CircleIconButton(
                icon: Icons.arrow_back,
                onTap: () => Navigator.pop(context),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: _CircleIconButton(
                  icon: isFav
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_outline_rounded,
                  onTap: () => _state.toggleFavorite(b.id),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
                child: _CircleIconButton(
                  icon: Icons.ios_share_rounded,
                  onTap: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  BusinessImage(
                    url: b.heroImage,
                    fallbackLetter: b.name[0],
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x33000000), Colors.transparent],
                        stops: [0.0, 0.4],
                      ),
                    ),
                    child: SizedBox.expand(),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -20, 0),
              decoration: const BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.category.toUpperCase(), style: AppTheme.eyebrow()),
                  const SizedBox(height: 8),
                  Text(b.name,
                      style:
                          AppTheme.display(size: 32, weight: FontWeight.w400)),
                  const SizedBox(height: 10),
                  Text(b.tagline,
                      style: AppTheme.sans(
                          size: 15, color: AppTheme.inkMuted, height: 1.5)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _MetricChip(
                        icon: Icons.star_rounded,
                        label: '${b.rating}',
                        sub: '${b.reviews} reseñas',
                      ),
                      const SizedBox(width: 12),
                      _MetricChip(
                        icon: Icons.place_outlined,
                        label: '${b.distanceKm.toStringAsFixed(1)} km',
                        sub: b.neighborhood,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricChip(
                          icon: Icons.schedule_rounded,
                          label: 'Abierto',
                          sub: b.openHours.replaceFirst('Hoy · ', ''),
                          success: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  _InfoRow(
                    icon: Icons.place_outlined,
                    label: b.address,
                    trailing: 'Ver mapa',
                    onTrailing: () =>
                        openInMaps(query: '${b.name}, ${b.address}'),
                  ),
                  const Divider(height: 24),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: '+52 777 123 4567',
                    trailing: 'Llamar',
                    onTrailing: () => openUrl('tel:+527771234567'),
                  ),
                  const SizedBox(height: 32),
                  Text('SERVICIOS', style: AppTheme.eyebrow()),
                  const SizedBox(height: 8),
                  Text('Elige y reserva',
                      style:
                          AppTheme.serif(size: 24, weight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  ...b.services.map(
                    (s) => _ServiceTile(
                      service: s,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BookingScreen(business: b, service: s),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text('GALERÍA', style: AppTheme.eyebrow()),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: b.gallery.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 140,
                          height: 180,
                          child: BusinessImage(
                            url: b.gallery[i],
                            fallbackLetter: b.name[0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 18, color: AppTheme.ink),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool success;

  const _MetricChip({
    required this.icon,
    required this.label,
    required this.sub,
    this.success = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon,
                  size: 14,
                  color: success ? AppTheme.success : AppTheme.ink),
              const SizedBox(width: 4),
              Text(label,
                  style: AppTheme.sans(
                    size: 13,
                    weight: FontWeight.w600,
                    color: success ? AppTheme.success : AppTheme.ink,
                  )),
            ],
          ),
          const SizedBox(height: 2),
          Text(sub,
              style:
                  AppTheme.sans(size: 11, color: AppTheme.inkMuted)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTrailing;

  const _InfoRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTrailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.ink),
        const SizedBox(width: 12),
        Expanded(
            child: Text(label,
                style: AppTheme.sans(size: 14, color: AppTheme.ink))),
        if (trailing != null)
          GestureDetector(
            onTap: onTrailing,
            child: Text(
              trailing!,
              style: AppTheme.sans(size: 13, weight: FontWeight.w500)
                  .copyWith(decoration: TextDecoration.underline),
            ),
          ),
      ],
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final Service service;
  final VoidCallback onTap;
  const _ServiceTile({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name,
                      style: AppTheme.serif(
                          size: 17, weight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(service.description,
                      style: AppTheme.sans(
                          size: 13,
                          color: AppTheme.inkMuted,
                          height: 1.4)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule_outlined,
                          size: 13, color: AppTheme.inkMuted),
                      const SizedBox(width: 4),
                      Text('${service.durationMinutes} min',
                          style: AppTheme.sans(
                              size: 12, color: AppTheme.inkMuted)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('\$${service.price.toStringAsFixed(0)}',
                    style:
                        AppTheme.serif(size: 20, weight: FontWeight.w500)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.ink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Reservar',
                    style: AppTheme.sans(
                        size: 12,
                        weight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
