import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../domain/models/day_hours.dart';
import '../../../domain/models/my_business.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/launchers.dart';
import '../../core/widgets/async_views.dart';
import '../../core/widgets/business_image.dart';
import '../view_models/business_profile_view_model.dart';
import '../view_models/edit_business_profile_view_model.dart';
import '../view_models/edit_hours_view_model.dart';

class BusinessProfileTab extends StatelessWidget {
  const BusinessProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => BusinessProfileViewModel(
        myBusinessRepository: context.read(),
        clientsRepository: context.read(),
        reservationRepository: context.read(),
      )..load(),
      child: const _BusinessProfileView(),
    );
  }
}

class _BusinessProfileView extends StatelessWidget {
  const _BusinessProfileView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BusinessProfileViewModel>();
    final b = vm.business;
    if (b == null) {
      if (vm.errorMessage != null) {
        return ErrorView(message: vm.errorMessage!, onRetry: vm.load);
      }
      return vm.isLoading ? const LoadingView() : const SizedBox();
    }

    final clientCount = vm.clientCount;
    final upcomingCount = vm.upcomingCount;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: BusinessImage(url: b.heroImage, fallbackLetter: b.name[0]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(b.category.toUpperCase(), style: AppTheme.eyebrow()),
              const SizedBox(height: 6),
              Text(
                b.name,
                style: AppTheme.display(size: 28, weight: FontWeight.w400),
              ),
              const SizedBox(height: 10),
              Text(
                b.description,
                style: AppTheme.sans(
                  size: 14,
                  color: AppTheme.inkMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.line),
                ),
                child: Row(
                  children: [
                    _StatCell(label: 'Clientes', value: '$clientCount'),
                    Container(width: 1, height: 42, color: AppTheme.line),
                    _StatCell(label: 'Próximas', value: '$upcomingCount'),
                    Container(width: 1, height: 42, color: AppTheme.line),
                    _StatCell(
                      label: 'Servicios',
                      value: '${b.services.length}',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _Section(
          title: 'INFORMACIÓN',
          children: [
            _InfoLine(
              icon: Icons.phone_outlined,
              label: 'Teléfono',
              value: b.phone,
            ),
            _InfoLine(
              icon: Icons.place_outlined,
              label: 'Dirección',
              value: '${b.address}, ${b.municipality}',
            ),
            _ActionLine(
              icon: Icons.edit_outlined,
              label: 'Editar perfil',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _EditBusinessProfileScreen(business: b),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _Section(
          title: 'HORARIOS',
          children: [
            for (int i = 0; i < b.weeklyHours.length; i++)
              _HoursRow(
                day: weekdayFull(i),
                hours: b.weeklyHours[i],
                isToday: (DateTime.now().weekday - 1) % 7 == i,
              ),
            _ActionLine(
              icon: Icons.schedule_outlined,
              label: 'Editar horarios',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const _EditHoursScreen()),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _Section(
          title: 'CÓDIGO QR',
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.line),
                    ),
                    child: QrImageView(
                      data: b.deepLink,
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.zero,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppTheme.ink,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppTheme.ink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tu QR único',
                          style: AppTheme.serif(
                            size: 16,
                            weight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Al escanear, el cliente abre tu perfil directo para reservar.',
                          style: AppTheme.sans(
                            size: 12,
                            color: AppTheme.inkMuted,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _ActionLine(
              icon: Icons.qr_code_rounded,
              label: 'Ver código QR en grande',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _BusinessQrScreen(business: b),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label;
  final String value;
  const _StatCell({required this.label, required this.value});

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
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 2),
            child: Text(title, style: AppTheme.eyebrow()),
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

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppTheme.ink),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.sans(
                    size: 11,
                    color: AppTheme.inkMuted,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTheme.sans(size: 14, weight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionLine({
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
            Icon(icon, size: 18, color: AppTheme.ink),
            const SizedBox(width: 16),
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

class _HoursRow extends StatelessWidget {
  final String day;
  final DayHours hours;
  final bool isToday;

  const _HoursRow({
    required this.day,
    required this.hours,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Text(
                  day,
                  style: AppTheme.sans(
                    size: 14,
                    weight: isToday ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.ink,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Text(
              hours.label,
              style: AppTheme.sans(
                size: 14,
                color: hours.open ? AppTheme.ink : AppTheme.inkMuted,
                weight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Editar perfil del negocio (Req 2.2)
// ─────────────────────────────────────────────────────────────────
class _EditBusinessProfileScreen extends StatelessWidget {
  final MyBusiness business;
  const _EditBusinessProfileScreen({required this.business});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditBusinessProfileViewModel(
        myBusinessRepository: context.read(),
        catalogRepository: context.read(),
        business: business,
      )..load(),
      child: const _EditBusinessProfileView(),
    );
  }
}

class _EditBusinessProfileView extends StatefulWidget {
  const _EditBusinessProfileView();

  @override
  State<_EditBusinessProfileView> createState() =>
      _EditBusinessProfileViewState();
}

class _EditBusinessProfileViewState extends State<_EditBusinessProfileView> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _phone;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    final b = context.read<EditBusinessProfileViewModel>().business;
    _name = TextEditingController(text: b.name);
    _description = TextEditingController(text: b.description);
    _phone = TextEditingController(text: b.phone);
    _address = TextEditingController(text: b.address);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final error = await context.read<EditBusinessProfileViewModel>().save(
      name: _name.text,
      description: _description.text,
      phone: _phone.text,
      address: _address.text,
    );
    if (!mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditBusinessProfileViewModel>();
    final catalogsReady =
        vm.categories.isNotEmpty && vm.municipalities.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Editar negocio', style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: !catalogsReady
                  ? (vm.errorMessage != null
                        ? ErrorView(message: vm.errorMessage!, onRetry: vm.load)
                        : const LoadingView())
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      children: [
                        Text('NOMBRE', style: AppTheme.eyebrow()),
                        const SizedBox(height: 8),
                        TextField(controller: _name),
                        const SizedBox(height: 20),
                        Text('CATEGORÍA', style: AppTheme.eyebrow()),
                        const SizedBox(height: 8),
                        _DropField(
                          value: vm.category,
                          options: vm.categories,
                          onChanged: (v) => vm.category = v,
                        ),
                        const SizedBox(height: 20),
                        Text('DESCRIPCIÓN', style: AppTheme.eyebrow()),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _description,
                          minLines: 2,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 20),
                        Text('TELÉFONO', style: AppTheme.eyebrow()),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _phone,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),
                        Text('DIRECCIÓN', style: AppTheme.eyebrow()),
                        const SizedBox(height: 8),
                        TextField(controller: _address),
                        const SizedBox(height: 20),
                        Text('MUNICIPIO', style: AppTheme.eyebrow()),
                        const SizedBox(height: 8),
                        _DropField(
                          value: vm.municipality,
                          options: vm.municipalities,
                          onChanged: (v) => vm.municipality = v,
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
                  onPressed: catalogsReady && !vm.isSaving ? _save : null,
                  child: const Text('Guardar cambios'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DropField extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _DropField({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.line),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppTheme.ink,
          ),
          style: AppTheme.sans(size: 15),
          items: options
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Editar horarios (Req 3.1)
// ─────────────────────────────────────────────────────────────────
class _EditHoursScreen extends StatelessWidget {
  const _EditHoursScreen();

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          EditHoursViewModel(myBusinessRepository: context.read())..load(),
      child: const _EditHoursView(),
    );
  }
}

class _EditHoursView extends StatelessWidget {
  const _EditHoursView();

  Future<void> _pickTime(BuildContext context, int day, bool isOpen) async {
    final vm = context.read<EditHoursViewModel>();
    final h = vm.weeklyHours[day];
    final initial = TimeOfDay(
      hour: isOpen ? h.openHour : h.closeHour,
      minute: isOpen ? h.openMinute : h.closeMinute,
    );
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: isOpen ? 'Hora de apertura' : 'Hora de cierre',
    );
    if (picked == null) return;
    final error = isOpen
        ? await vm.setOpenTime(day, picked.hour, picked.minute)
        : await vm.setCloseTime(day, picked.hour, picked.minute);
    if (error != null && context.mounted) showErrorSnackBar(context, error);
  }

  Future<void> _setOpen(BuildContext context, int day, bool open) async {
    final error = await context.read<EditHoursViewModel>().setOpen(day, open);
    if (error != null && context.mounted) showErrorSnackBar(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EditHoursViewModel>();
    final week = vm.weeklyHours;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Horarios', style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            Text(
              'Define cuándo recibes clientes.',
              style: AppTheme.sans(size: 15, color: AppTheme.inkMuted),
            ),
            const SizedBox(height: 24),
            if (week.isEmpty && vm.isLoading)
              const LoadingView()
            else if (week.isEmpty && vm.errorMessage != null)
              ErrorView(message: vm.errorMessage!, onRetry: vm.load),
            for (int i = 0; i < week.length; i++) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.line),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            weekdayFull(i),
                            style: AppTheme.sans(
                              size: 15,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Switch.adaptive(
                          value: week[i].open,
                          onChanged: (v) => _setOpen(context, i, v),
                          activeThumbColor: AppTheme.ink,
                        ),
                      ],
                    ),
                    if (week[i].open) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: _TimeButton(
                              label: 'Abre',
                              time:
                                  '${week[i].openHour.toString().padLeft(2, '0')}:${week[i].openMinute.toString().padLeft(2, '0')}',
                              onTap: () => _pickTime(context, i, true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _TimeButton(
                              label: 'Cierra',
                              time:
                                  '${week[i].closeHour.toString().padLeft(2, '0')}:${week[i].closeMinute.toString().padLeft(2, '0')}',
                              onTap: () => _pickTime(context, i, false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimeButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceAlt,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: AppTheme.eyebrow()),
            const SizedBox(height: 4),
            Text(
              time,
              style: AppTheme.serif(size: 20, weight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// QR del negocio pantalla completa (Req 2.5)
// ─────────────────────────────────────────────────────────────────
class _BusinessQrScreen extends StatelessWidget {
  final MyBusiness business;
  const _BusinessQrScreen({required this.business});

  @override
  Widget build(BuildContext context) {
    final b = business;
    return Scaffold(
      backgroundColor: AppTheme.ink,
      appBar: AppBar(
        backgroundColor: AppTheme.ink,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: const BackButton(color: Colors.white),
        title: Text(
          'Código QR',
          style: AppTheme.serif(size: 16, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'ESCANEA PARA VISITAR',
                  style: AppTheme.eyebrow(color: Colors.white70),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  b.name,
                  style: AppTheme.serif(
                    size: 28,
                    weight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: QrImageView(
                    data: b.deepLink,
                    version: QrVersions.auto,
                    size: 240,
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppTheme.ink,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: AppTheme.ink,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  b.deepLink,
                  style: AppTheme.sans(size: 13, color: Colors.white70),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => openUrl(b.deepLink),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                      ),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Abrir enlace'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'QR descargado',
                              style: AppTheme.sans(
                                size: 14,
                                color: AppTheme.ink,
                              ),
                            ),
                            backgroundColor: Colors.white,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.ink,
                      ),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Descargar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
