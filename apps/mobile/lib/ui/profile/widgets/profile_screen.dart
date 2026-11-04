import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../business_owner/widgets/business_home_screen.dart';
import '../../business_owner/widgets/register_business_screen.dart';
import '../../auth/widgets/welcome_screen.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_views.dart';
import '../../legal/widgets/legal_screens.dart';
import '../../settings/widgets/settings_screens.dart';
import '../view_models/profile_view_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ProfileViewModel(
        authRepository: context.read(),
        profileRepository: context.read(),
        favoritesRepository: context.read(),
        reservationRepository: context.read(),
        myBusinessRepository: context.read(),
      )..load(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _logout(BuildContext context) async {
    final error = await context.read<ProfileViewModel>().logout();
    if (!context.mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final profile = vm.profile;
    if (profile == null) {
      if (vm.errorMessage != null) {
        return ErrorView(message: vm.errorMessage!, onRetry: vm.load);
      }
      return const LoadingView();
    }

    final myBusiness = vm.myBusiness;
    final completed = vm.completedCount;
    final upcoming = vm.upcomingCount;
    final favs = vm.favoritesCount;
    final initial = profile.name.isEmpty ? 'M' : profile.name[0].toUpperCase();

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.line),
                ),
                alignment: Alignment.center,
                child: Text(
                  initial,
                  style: AppTheme.serif(size: 28, weight: FontWeight.w500),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: AppTheme.serif(size: 20, weight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: AppTheme.sans(size: 13, color: AppTheme.inkMuted),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  side: const BorderSide(color: AppTheme.line),
                  textStyle: AppTheme.sans(size: 12, weight: FontWeight.w500),
                ),
                onPressed: () => _push(context, const EditProfileScreen()),
                child: const Text('Editar'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.line),
            ),
            child: Row(
              children: [
                _StatCell(value: '$upcoming', label: 'Próximas'),
                Container(width: 1, height: 42, color: AppTheme.line),
                _StatCell(value: '$completed', label: 'Completadas'),
                Container(width: 1, height: 42, color: AppTheme.line),
                _StatCell(value: '$favs', label: 'Guardados'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        // ─ Banner modo empresa ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: myBusiness != null
              ? _BusinessModeBanner(
                  businessName: myBusiness.name,
                  onEnter: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BusinessHomeScreen(),
                      ),
                      (_) => false,
                    );
                  },
                )
              : _RegisterBusinessBanner(
                  onTap: () => _push(context, const RegisterBusinessScreen()),
                ),
        ),
        const SizedBox(height: 28),
        _Section(
          eyebrow: 'CUENTA',
          children: [
            _MenuRow(
              icon: Icons.person_outline,
              label: 'Información personal',
              onTap: () => _push(context, const EditProfileScreen()),
            ),
            _MenuRow(
              icon: Icons.lock_outline,
              label: 'Seguridad y acceso',
              onTap: () => _push(context, const ChangePasswordScreen()),
            ),
            _MenuRow(
              icon: Icons.credit_card_outlined,
              label: 'Métodos de pago',
              onTap: () => _push(context, const PaymentMethodsScreen()),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _Section(
          eyebrow: 'PREFERENCIAS',
          children: [
            _MenuRow(
              icon: Icons.notifications_none_rounded,
              label: 'Notificaciones',
              onTap: () => _push(context, const NotificationsScreen()),
            ),
            _MenuRow(
              icon: Icons.place_outlined,
              label: 'Ubicación por defecto',
              onTap: () => _push(context, const LocationScreen()),
            ),
            _MenuRow(
              icon: Icons.privacy_tip_outlined,
              label: 'Privacidad y datos',
              onTap: () => _push(context, const PrivacyScreen()),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _Section(
          eyebrow: 'AYUDA',
          children: [
            _MenuRow(
              icon: Icons.help_outline_rounded,
              label: 'Centro de ayuda',
              onTap: () => _push(context, const HelpScreen()),
            ),
            _MenuRow(
              icon: Icons.description_outlined,
              label: 'Términos y condiciones',
              onTap: () => _push(context, const TermsScreen()),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.danger,
              side: const BorderSide(color: AppTheme.line),
            ),
            onPressed: () => _logout(context),
            child: const Text('Cerrar sesión'),
          ),
        ),
        const SizedBox(height: 24),
        Center(
          child: Text(
            'Citalis · v1.0.0',
            style: AppTheme.sans(size: 11, color: AppTheme.inkFaint),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _BusinessModeBanner extends StatelessWidget {
  final String businessName;
  final VoidCallback onEnter;

  const _BusinessModeBanner({
    required this.businessName,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onEnter,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.ink,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MODO EMPRESA',
                    style: AppTheme.eyebrow(color: Colors.white70)
                        .copyWith(letterSpacing: 1.4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    businessName,
                    style: AppTheme.serif(
                      size: 18,
                      weight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Gestiona tu agenda, servicios y clientes',
                    style: AppTheme.sans(size: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _RegisterBusinessBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _RegisterBusinessBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.line),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(
                Icons.add_business_outlined,
                color: AppTheme.ink,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('PARA PROFESIONALES', style: AppTheme.eyebrow()),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'NUEVO',
                          style: AppTheme.sans(
                            size: 9,
                            weight: FontWeight.w700,
                            color: AppTheme.accent,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registra tu negocio',
                    style: AppTheme.serif(size: 18, weight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Recibe reservas y gestiona tu agenda',
                    style: AppTheme.sans(size: 12, color: AppTheme.inkMuted),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_rounded,
              color: AppTheme.ink,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  const _StatCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(
              value,
              style: AppTheme.serif(size: 22, weight: FontWeight.w500),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTheme.sans(size: 11, color: AppTheme.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String eyebrow;
  final List<Widget> children;
  const _Section({required this.eyebrow, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 2),
            child: Text(eyebrow, style: AppTheme.eyebrow()),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.line),
            ),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1)
                    const Divider(height: 1, color: AppTheme.line, indent: 54),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.ink),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: AppTheme.sans(size: 15, weight: FontWeight.w500),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: AppTheme.inkFaint,
            ),
          ],
        ),
      ),
    );
  }
}
