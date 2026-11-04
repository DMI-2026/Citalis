import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_views.dart';
import '../view_models/change_password_view_model.dart';
import '../view_models/edit_profile_view_model.dart';
import '../view_models/location_view_model.dart';
import '../view_models/notifications_view_model.dart';

// ─────────────────────────────────────────────────────────────────
// Editar perfil (Req 7.1)
// ─────────────────────────────────────────────────────────────────
class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          EditProfileViewModel(profileRepository: context.read())..load(),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  bool _filled = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final error = await context.read<EditProfileViewModel>().save(
      name: _name.text,
      email: _email.text,
      phone: _phone.text,
    );
    if (!mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Perfil actualizado',
          style: AppTheme.sans(size: 14, color: Colors.white),
        ),
        backgroundColor: AppTheme.ink,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditProfileViewModel>();
    final profile = vm.profile;
    // Los campos se llenan una sola vez, cuando llega el perfil.
    if (profile != null && !_filled) {
      _filled = true;
      _name.text = profile.name;
      _email.text = profile.email;
      _phone.text = profile.phone;
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Información personal', style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (profile == null)
              Expanded(
                child: vm.errorMessage != null
                    ? ErrorView(message: vm.errorMessage!, onRetry: vm.load)
                    : const LoadingView(),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  children: [
                    Text('NOMBRE', style: AppTheme.eyebrow()),
                    const SizedBox(height: 8),
                    TextField(controller: _name),
                    const SizedBox(height: 20),
                    Text('CORREO', style: AppTheme.eyebrow()),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    Text('TELÉFONO', style: AppTheme.eyebrow()),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
            _BottomBar(
              child: ElevatedButton(
                onPressed: profile == null || vm.isSubmitting ? null : _save,
                child: const Text('Guardar cambios'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Cambiar contraseña (Req 1.2, 7.1)
// ─────────────────────────────────────────────────────────────────
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          ChangePasswordViewModel(authRepository: context.read()),
      child: const _ChangePasswordView(),
    );
  }
}

class _ChangePasswordView extends StatefulWidget {
  const _ChangePasswordView();

  @override
  State<_ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<_ChangePasswordView> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscureA = true;
  bool _obscureB = true;
  bool _obscureC = true;

  @override
  void dispose() {
    _current.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final error = await context.read<ChangePasswordViewModel>().changePassword(
      currentPassword: _current.text,
      newPassword: _new.text,
      confirmation: _confirm.text,
    );
    if (!mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Contraseña actualizada',
          style: AppTheme.sans(size: 14, color: Colors.white),
        ),
        backgroundColor: AppTheme.ink,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChangePasswordViewModel>();
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Seguridad y acceso', style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                children: [
                  Text('CONTRASEÑA ACTUAL', style: AppTheme.eyebrow()),
                  const SizedBox(height: 8),
                  _pwField(
                    _current,
                    _obscureA,
                    () => setState(() => _obscureA = !_obscureA),
                  ),
                  const SizedBox(height: 20),
                  Text('NUEVA CONTRASEÑA', style: AppTheme.eyebrow()),
                  const SizedBox(height: 8),
                  _pwField(
                    _new,
                    _obscureB,
                    () => setState(() => _obscureB = !_obscureB),
                  ),
                  const SizedBox(height: 20),
                  Text('CONFIRMAR NUEVA', style: AppTheme.eyebrow()),
                  const SizedBox(height: 8),
                  _pwField(
                    _confirm,
                    _obscureC,
                    () => setState(() => _obscureC = !_obscureC),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.lock_outline,
                              size: 16,
                              color: AppTheme.ink,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Requisitos de contraseña',
                              style: AppTheme.sans(
                                size: 13,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '· Mínimo 8 caracteres\n· Al menos una mayúscula\n· Al menos un número\n· Un símbolo especial',
                          style: AppTheme.sans(
                            size: 13,
                            color: AppTheme.inkMuted,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _BottomBar(
              child: ElevatedButton(
                onPressed: vm.isSubmitting ? null : _submit,
                child: const Text('Actualizar contraseña'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pwField(
    TextEditingController controller,
    bool obs,
    VoidCallback onToggle,
  ) {
    return TextField(
      controller: controller,
      obscureText: obs,
      decoration: InputDecoration(
        hintText: '••••••••',
        suffixIcon: IconButton(
          icon: Icon(
            obs ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppTheme.inkMuted,
            size: 20,
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Notificaciones (Req 6.1, 7.3)
// ─────────────────────────────────────────────────────────────────
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          NotificationsViewModel(notificationsRepository: context.read())
            ..load(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  Future<void> _update(
    BuildContext context, {
    bool? reminders,
    bool? promos,
    bool? news,
  }) async {
    final error = await context.read<NotificationsViewModel>().update(
      reminders: reminders,
      promos: promos,
      news: news,
    );
    if (error != null && context.mounted) showErrorSnackBar(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsViewModel>();
    final n = vm.settings;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Notificaciones', style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: n == null
            ? (vm.errorMessage != null
                  ? ErrorView(message: vm.errorMessage!, onRetry: vm.load)
                  : const LoadingView())
            : ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                children: [
                  Text(
                    'Elige qué quieres recibir.',
                    style: AppTheme.sans(size: 15, color: AppTheme.inkMuted),
                  ),
                  const SizedBox(height: 24),
                  _ToggleRow(
                    title: 'Recordatorios de citas',
                    subtitle: 'Avisos antes de tu próxima cita',
                    value: n.reminders,
                    onChanged: (v) => _update(context, reminders: v),
                  ),
                  _ToggleRow(
                    title: 'Novedades',
                    subtitle: 'Nuevos negocios y mejoras de la app',
                    value: n.news,
                    onChanged: (v) => _update(context, news: v),
                  ),
                  _ToggleRow(
                    title: 'Promociones',
                    subtitle:
                        'Descuentos y campañas de los negocios que sigues',
                    value: n.promos,
                    onChanged: (v) => _update(context, promos: v),
                  ),
                ],
              ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.sans(size: 15, weight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTheme.sans(size: 13, color: AppTheme.inkMuted),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.ink,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Métodos de pago (stub)
// ─────────────────────────────────────────────────────────────────
class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Métodos de pago', style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.ink,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'MASTERCARD',
                        style: AppTheme.eyebrow(color: Colors.white70),
                      ),
                      const Spacer(),
                      Text(
                        'PREDETERMINADA',
                        style: AppTheme.eyebrow(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    '•••• •••• •••• 4821',
                    style: AppTheme.serif(
                      size: 22,
                      weight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        'María García',
                        style: AppTheme.sans(size: 13, color: Colors.white70),
                      ),
                      const Spacer(),
                      Text(
                        '09/27',
                        style: AppTheme.sans(size: 13, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar método de pago'),
            ),
            const SizedBox(height: 24),
            Text('PAGO EN NEGOCIO', style: AppTheme.eyebrow()),
            const SizedBox(height: 8),
            Text(
              'Puedes reservar sin tarjeta — la mayoría de negocios aceptan pago en efectivo o terminal al momento del servicio.',
              style: AppTheme.sans(
                size: 14,
                color: AppTheme.inkMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Ubicación por defecto (Req 5.3, 7.3)
// ─────────────────────────────────────────────────────────────────
class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LocationViewModel(
        profileRepository: context.read(),
        catalogRepository: context.read(),
      )..load(),
      child: const _LocationView(),
    );
  }
}

class _LocationView extends StatelessWidget {
  const _LocationView();

  Future<void> _select(BuildContext context, String city) async {
    final error = await context.read<LocationViewModel>().selectCity(city);
    if (error != null && context.mounted) showErrorSnackBar(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LocationViewModel>();
    final municipalities = vm.municipalities;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Ubicación', style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.place_outlined, color: AppTheme.ink),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Usamos tu ubicación para mostrarte negocios cercanos. Puedes elegir una ciudad manualmente.',
                      style: AppTheme.sans(
                        size: 13,
                        color: AppTheme.inkMuted,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('CIUDAD POR DEFECTO', style: AppTheme.eyebrow()),
            const SizedBox(height: 10),
            if (vm.isLoading && municipalities.isEmpty)
              const LoadingView()
            else if (vm.errorMessage != null && municipalities.isEmpty)
              ErrorView(message: vm.errorMessage!, onRetry: vm.load)
            else
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.line),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < municipalities.length; i++) ...[
                      _CityRow(
                        city: municipalities[i],
                        selected: vm.selectedCity == municipalities[i],
                        onTap: () => _select(context, municipalities[i]),
                      ),
                      if (i != municipalities.length - 1)
                        const Divider(
                          height: 1,
                          color: AppTheme.line,
                          indent: 54,
                        ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CityRow extends StatelessWidget {
  final String city;
  final bool selected;
  final VoidCallback onTap;

  const _CityRow({
    required this.city,
    required this.selected,
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
            const Icon(Icons.place_outlined, size: 18, color: AppTheme.ink),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                city,
                style: AppTheme.sans(size: 15, weight: FontWeight.w500),
              ),
            ),
            if (selected)
              const Icon(Icons.check, size: 18, color: AppTheme.ink),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final Widget child;
  const _BottomBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.line)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
      child: SafeArea(top: false, child: child),
    );
  }
}
