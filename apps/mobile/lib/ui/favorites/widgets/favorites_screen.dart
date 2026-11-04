import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/business.dart';
import '../../business_detail/widgets/business_detail_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_views.dart';
import '../../core/widgets/business_image.dart';
import '../view_models/favorites_view_model.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          FavoritesViewModel(favoritesRepository: context.read())..load(),
      child: const _FavoritesView(),
    );
  }
}

class _FavoritesView extends StatelessWidget {
  const _FavoritesView();

  Future<void> _remove(BuildContext context, Business b) async {
    final error = await context.read<FavoritesViewModel>().remove(b.id);
    if (error != null && context.mounted) showErrorSnackBar(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FavoritesViewModel>();
    final favs = vm.favorites;
    final firstLoad = vm.isLoading && favs.isEmpty;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('GUARDADOS', style: AppTheme.eyebrow()),
              const SizedBox(height: 8),
              Text(
                'Tus lugares\nfavoritos',
                style: AppTheme.display(size: 32, weight: FontWeight.w400),
              ),
              const SizedBox(height: 10),
              if (!firstLoad && vm.errorMessage == null)
                Text(
                  favs.isEmpty
                      ? 'Toca el bookmark en un negocio para guardarlo aquí.'
                      : '${favs.length} ${favs.length == 1 ? "negocio guardado" : "negocios guardados"}',
                  style: AppTheme.sans(size: 14, color: AppTheme.inkMuted),
                ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        if (firstLoad)
          const LoadingView()
        else if (vm.errorMessage != null && favs.isEmpty)
          ErrorView(message: vm.errorMessage!, onRetry: vm.load)
        else if (favs.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: _EmptyFavorites(),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: favs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 20,
                childAspectRatio: 0.68,
              ),
              itemBuilder: (context, i) {
                final b = favs[i];
                return _FavoriteCard(
                  business: b,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BusinessDetailScreen(businessId: b.id),
                    ),
                  ),
                  onRemove: () => _remove(context, b),
                );
              },
            ),
          ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

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
              Icons.bookmark_outline_rounded,
              color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Sin guardados aún',
            style: AppTheme.serif(size: 20, weight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Marca un negocio con el bookmark y vuelve aquí para encontrarlo rápido.',
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

class _FavoriteCard extends StatelessWidget {
  final Business business;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.business,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BusinessImage(
                    url: business.heroImage,
                    fallbackLetter: business.name[0],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.95),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_rounded,
                          size: 16,
                          color: AppTheme.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(business.category.toUpperCase(), style: AppTheme.eyebrow()),
          const SizedBox(height: 4),
          Text(
            business.name,
            style: AppTheme.serif(size: 16, weight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 12, color: AppTheme.ink),
              const SizedBox(width: 2),
              Text(
                business.rating.toString(),
                style: AppTheme.sans(size: 12, weight: FontWeight.w600),
              ),
              Text(
                ' · ${business.distanceKm.toStringAsFixed(1)} km',
                style: AppTheme.sans(size: 12, color: AppTheme.inkMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
