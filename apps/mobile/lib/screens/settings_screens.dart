import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────────
// Editar perfil (Req 7.1)
// ─────────────────────────────────────────────────────────────────
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final p = AppState.instance.profile;
    _name = TextEditingController(text: p.name);
    _email = TextEditingController(text: p.email);
    _phone = TextEditingController(text: p.phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  void _save() {
    AppState.instance.updateProfile(UserProfile(
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perfil actualizado', style: AppTheme.sans(size: 14, color: Colors.white)),
        backgroundColor: AppTheme.ink,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Información personal', style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: Column(
          children: [
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
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  Text('TELÉFONO', style: AppTheme.eyebrow()),
                  const SizedBox(height: 8),
                  TextField(
                      controller: _phone,
                      keyboardType: TextInputType.phone),
                ],
              ),
            ),
            _BottomBar(child: ElevatedButton(onPressed: _save, child: const Text('Guardar cambios'))),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Cambiar contraseña (Req 1.2, 7.1)
// ─────────────────────────────────────────────────────────────────
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  bool _obscureA = true;
  bool _obscureB = true;
  bool _obscureC = true;

  @override
  Widget build(BuildContext context) {
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
                  _pwField(_obscureA, () => setState(() => _obscureA = !_obscureA)),
                  const SizedBox(height: 20),
                  Text('NUEVA CONTRASEÑA', style: AppTheme.eyebrow()),
                  const SizedBox(height: 8),
                  _pwField(_obscureB, () => setState(() => _obscureB = !_obscureB)),
                  const SizedBox(height: 20),
                  Text('CONFIRMAR NUEVA', style: AppTheme.eyebrow()),
                  const SizedBox(height: 8),
                  _pwField(_obscureC, () => setState(() => _obscureC = !_obscureC)),
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
                            const Icon(Icons.lock_outline, size: 16, color: AppTheme.ink),
                            const SizedBox(width: 8),
                            Text('Requisitos de contraseña',
                                style: AppTheme.sans(size: 13, weight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '· Mínimo 8 caracteres\n· Al menos una mayúscula\n· Al menos un número\n· Un símbolo especial',
                          style: AppTheme.sans(size: 13, color: AppTheme.inkMuted, height: 1.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _BottomBar(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Contraseña actualizada', style: AppTheme.sans(size: 14, color: Colors.white)),
                      backgroundColor: AppTheme.ink,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Actualizar contraseña'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pwField(bool obs, VoidCallback onToggle) {
    return TextField(
      obscureText: obs,
      decoration: InputDecoration(
        hintText: '••••••••',
        suffixIcon: IconButton(
          icon: Icon(obs ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppTheme.inkMuted, size: 20),
          onPressed: onToggle,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Notificaciones (Req 6.1, 7.3)
// ─────────────────────────────────────────────────────────────────
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final AppState _state = AppState.instance;

  @override
  Widget build(BuildContext context) {
    final n = _state.notifications;
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Notificaciones', style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          children: [
            Text('Elige qué quieres recibir.',
                style: AppTheme.sans(size: 15, color: AppTheme.inkMuted)),
            const SizedBox(height: 24),
            _ToggleRow(
              title: 'Recordatorios de citas',
              subtitle: 'Avisos antes de tu próxima cita',
              value: n.reminders,
              onChanged: (v) => setState(
                  () => _state.updateNotifications(reminders: v)),
            ),
            _ToggleRow(
              title: 'Novedades',
              subtitle: 'Nuevos negocios y mejoras de la app',
              value: n.news,
              onChanged: (v) =>
                  setState(() => _state.updateNotifications(news: v)),
            ),
            _ToggleRow(
              title: 'Promociones',
              subtitle: 'Descuentos y campañas de los negocios que sigues',
              value: n.promos,
              onChanged: (v) =>
                  setState(() => _state.updateNotifications(promos: v)),
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
                Text(title,
                    style: AppTheme.sans(size: 15, weight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: AppTheme.sans(size: 13, color: AppTheme.inkMuted)),
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
                      Text('MASTERCARD',
                          style: AppTheme.eyebrow(color: Colors.white70)),
                      const Spacer(),
                      Text('PREDETERMINADA',
                          style: AppTheme.eyebrow(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('•••• •••• •••• 4821',
                      style: AppTheme.serif(
                          size: 22, weight: FontWeight.w500, color: Colors.white)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text('María García',
                          style: AppTheme.sans(size: 13, color: Colors.white70)),
                      const Spacer(),
                      Text('09/27',
                          style: AppTheme.sans(size: 13, color: Colors.white70)),
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
              style: AppTheme.sans(size: 14, color: AppTheme.inkMuted, height: 1.5),
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
class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  String _selected = 'Cuernavaca';

  @override
  Widget build(BuildContext context) {
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
                          size: 13, color: AppTheme.inkMuted, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('CIUDAD POR DEFECTO', style: AppTheme.eyebrow()),
            const SizedBox(height: 10),
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
                      selected: _selected == municipalities[i],
                      onTap: () => setState(() => _selected = municipalities[i]),
                    ),
                    if (i != municipalities.length - 1)
                      const Divider(height: 1, color: AppTheme.line, indent: 54),
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
              child: Text(city,
                  style: AppTheme.sans(size: 15, weight: FontWeight.w500)),
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
