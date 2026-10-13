import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import '../widgets/business_image.dart';
import 'business_detail_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'reservations_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedTab = widget.initialTab;
  String _selectedCategory = 'Todos';
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _ExploreTab(
        selectedCategory: _selectedCategory,
        onCategoryChanged: (c) => setState(() => _selectedCategory = c),
        search: _search,
        onSearchChanged: () => setState(() {}),
      ),
      const ReservationsScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(bottom: false, child: tabs[_selectedTab]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.line)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedTab,
          onDestinationSelected: (i) => setState(() => _selectedTab = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'Explorar',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_available_outlined),
              selectedIcon: Icon(Icons.event_available_rounded),
              label: 'Reservas',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline_rounded),
              selectedIcon: Icon(Icons.bookmark_rounded),
              label: 'Guardados',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}

class _ExploreTab extends StatelessWidget {
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;
  final TextEditingController search;
  final VoidCallback onSearchChanged;

  const _ExploreTab({
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.search,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final q = search.text.trim().toLowerCase();
    final all = selectedCategory == 'Todos'
        ? mockBusinesses
        : mockBusinesses
            .where((b) => b.category == selectedCategory)
            .toList();
    final filtered = q.isEmpty
        ? all
        : all
            .where((b) =>
                b.name.toLowerCase().contains(q) ||
                b.category.toLowerCase().contains(q) ||
                b.neighborhood.toLowerCase().contains(q))
            .toList();

    final nearby = [...mockBusinesses]
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            children: [
              Text('CITALIS',
                  style: AppTheme.eyebrow().copyWith(letterSpacing: 3)),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.place_outlined,
                      size: 14, color: AppTheme.inkMuted),
                  const SizedBox(width: 4),
                  Text('Cuernavaca',
                      style: AppTheme.sans(
                          size: 12,
                          color: AppTheme.inkMuted,
                          weight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Buenos días,\n¿qué te apetece hoy?',
            style: AppTheme.display(size: 32, weight: FontWeight.w400),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            controller: search,
            onChanged: (_) => onSearchChanged(),
            decoration: InputDecoration(
              hintText: 'Buscar negocios, barrios o servicios',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 10),
                child: Icon(Icons.search, color: AppTheme.ink, size: 20),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: search.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        search.clear();
                        onSearchChanged();
                      },
                    ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        _SectionHeader(
          eyebrow: 'CERCA DE TI',
          title: 'A menos de 2 km',
          action: 'Ver mapa',
          onAction: () =>
              openInMaps(query: 'salones de belleza en Cuernavaca'),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 340,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: nearby.take(4).length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final b = nearby[i];
              return _NearbyCard(
                business: b,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => BusinessDetailScreen(business: b)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 36),
        _SectionHeader(
          eyebrow: 'EXPLORA',
          title: 'Por categoría',
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = categories[i];
              final selected = cat == selectedCategory;
              return GestureDetector(
                onTap: () => onCategoryChanged(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? AppTheme.ink : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected ? AppTheme.ink : AppTheme.line,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    cat,
                    style: AppTheme.sans(
                      size: 13,
                      weight: FontWeight.w500,
                      color: selected ? Colors.white : AppTheme.ink,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              for (final b in filtered) ...[
                _EditorialRow(
                  business: b,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BusinessDetailScreen(business: b)),
                  ),
                ),
                const Divider(color: AppTheme.line, height: 32),
              ],
              if (filtered.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Text('Sin resultados por ahora.',
                      style: AppTheme.sans(
                          size: 14, color: AppTheme.inkMuted)),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(eyebrow, style: AppTheme.eyebrow()),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child:
                    Text(title, style: AppTheme.serif(size: 22, weight: FontWeight.w500)),
              ),
              if (action != null)
                GestureDetector(
                  onTap: onAction,
                  child: Text(
                    action!,
                    style: AppTheme.sans(
                      size: 13,
                      weight: FontWeight.w500,
                    ).copyWith(decoration: TextDecoration.underline),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NearbyCard extends StatelessWidget {
  final Business business;
  final VoidCallback onTap;
  const _NearbyCard({required this.business, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 220,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 4 / 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    BusinessImage(
                      url: business.heroImage,
                      fallbackLetter: business.name[0],
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${business.distanceKm.toStringAsFixed(1)} km',
                          style: AppTheme.sans(
                              size: 11, weight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(business.name,
                style: AppTheme.serif(size: 17, weight: FontWeight.w500)),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(business.category,
                    style: AppTheme.sans(
                        size: 12, color: AppTheme.inkMuted)),
                Text(' · ',
                    style: AppTheme.sans(
                        size: 12, color: AppTheme.inkFaint)),
                const Icon(Icons.star_rounded,
                    size: 13, color: AppTheme.ink),
                const SizedBox(width: 2),
                Text(business.rating.toString(),
                    style: AppTheme.sans(size: 12, weight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorialRow extends StatelessWidget {
  final Business business;
  final VoidCallback onTap;
  const _EditorialRow({required this.business, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 96,
              height: 96,
              child: BusinessImage(
                url: business.heroImage,
                fallbackLetter: business.name[0],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(business.category.toUpperCase(),
                    style: AppTheme.eyebrow()),
                const SizedBox(height: 4),
                Text(business.name,
                    style:
                        AppTheme.serif(size: 20, weight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text(business.tagline,
                    style: AppTheme.sans(
                        size: 13, color: AppTheme.inkMuted, height: 1.4)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 14, color: AppTheme.ink),
                    const SizedBox(width: 3),
                    Text(business.rating.toString(),
                        style: AppTheme.sans(
                            size: 12, weight: FontWeight.w600)),
                    Text('  ·  ${business.reviews} reseñas',
                        style: AppTheme.sans(
                            size: 12, color: AppTheme.inkMuted)),
                    const Spacer(),
                    Text('${business.distanceKm.toStringAsFixed(1)} km',
                        style: AppTheme.sans(
                            size: 12,
                            color: AppTheme.inkMuted,
                            weight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
