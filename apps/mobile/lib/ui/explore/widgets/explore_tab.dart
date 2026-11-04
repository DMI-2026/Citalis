import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/business.dart';
import '../../business_detail/widgets/business_detail_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/launchers.dart';
import '../../core/widgets/async_views.dart';
import '../../core/widgets/business_image.dart';
import '../view_models/explore_view_model.dart';

/// Tab "Explorar" del cliente (Req 5.1–5.3).
class ExploreTab extends StatelessWidget {
  const ExploreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ExploreViewModel(
        businessRepository: context.read(),
        catalogRepository: context.read(),
      )..load(),
      child: const _ExploreView(),
    );
  }
}

class _ExploreView extends StatefulWidget {
  const _ExploreView();

  @override
  State<_ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<_ExploreView> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExploreViewModel>();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Row(
            children: [
              Text(
                'CITALIS',
                style: AppTheme.eyebrow().copyWith(letterSpacing: 3),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.place_outlined,
                    size: 14,
                    color: AppTheme.inkMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Cuernavaca',
                    style: AppTheme.sans(
                      size: 12,
                      color: AppTheme.inkMuted,
                      weight: FontWeight.w500,
                    ),
                  ),
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
            controller: _search,
            onChanged: vm.setQuery,
            decoration: InputDecoration(
              hintText: 'Buscar negocios, barrios o servicios',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 14, right: 10),
                child: Icon(Icons.search, color: AppTheme.ink, size: 20),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              suffixIcon: vm.query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _search.clear();
                        vm.setQuery('');
                      },
                    ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        if (vm.isLoading)
          const LoadingView()
        else if (vm.errorMessage != null && vm.results.isEmpty)
          ErrorView(message: vm.errorMessage!, onRetry: vm.load)
        else ...[
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
              itemCount: vm.nearby.length,
              separatorBuilder: (_, _) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final b = vm.nearby[i];
                return _NearbyCard(
                  business: b,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BusinessDetailScreen(businessId: b.id),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 36),
          _SectionHeader(eyebrow: 'EXPLORA', title: 'Por categoría'),
          const SizedBox(height: 16),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: vm.categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = vm.categories[i];
                final selected = cat == vm.selectedCategory;
                return GestureDetector(
                  onTap: () => vm.selectCategory(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
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
                for (final b in vm.results) ...[
                  _EditorialRow(
                    business: b,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BusinessDetailScreen(businessId: b.id),
                      ),
                    ),
                  ),
                  const Divider(color: AppTheme.line, height: 32),
                ],
                if (vm.results.isEmpty && !vm.isSearching)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'Sin resultados por ahora.',
                      style: AppTheme.sans(size: 14, color: AppTheme.inkMuted),
                    ),
                  ),
              ],
            ),
          ),
        ],
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
                child: Text(
                  title,
                  style: AppTheme.serif(size: 22, weight: FontWeight.w500),
                ),
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
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${business.distanceKm.toStringAsFixed(1)} km',
                          style: AppTheme.sans(
                            size: 11,
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              business.name,
              style: AppTheme.serif(size: 17, weight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  business.category,
                  style: AppTheme.sans(size: 12, color: AppTheme.inkMuted),
                ),
                Text(
                  ' · ',
                  style: AppTheme.sans(size: 12, color: AppTheme.inkFaint),
                ),
                const Icon(Icons.star_rounded, size: 13, color: AppTheme.ink),
                const SizedBox(width: 2),
                Text(
                  business.rating.toString(),
                  style: AppTheme.sans(size: 12, weight: FontWeight.w600),
                ),
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
                Text(
                  business.category.toUpperCase(),
                  style: AppTheme.eyebrow(),
                ),
                const SizedBox(height: 4),
                Text(
                  business.name,
                  style: AppTheme.serif(size: 20, weight: FontWeight.w500),
                ),
                const SizedBox(height: 6),
                Text(
                  business.tagline,
                  style: AppTheme.sans(
                    size: 13,
                    color: AppTheme.inkMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 14,
                      color: AppTheme.ink,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      business.rating.toString(),
                      style: AppTheme.sans(size: 12, weight: FontWeight.w600),
                    ),
                    Text(
                      '  ·  ${business.reviews} reseñas',
                      style: AppTheme.sans(size: 12, color: AppTheme.inkMuted),
                    ),
                    const Spacer(),
                    Text(
                      '${business.distanceKm.toStringAsFixed(1)} km',
                      style: AppTheme.sans(
                        size: 12,
                        color: AppTheme.inkMuted,
                        weight: FontWeight.w500,
                      ),
                    ),
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
