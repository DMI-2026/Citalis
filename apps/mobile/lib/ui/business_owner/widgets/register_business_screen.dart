import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_views.dart';
import '../view_models/register_business_view_model.dart';
import 'business_home_screen.dart';

class RegisterBusinessScreen extends StatelessWidget {
  const RegisterBusinessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegisterBusinessViewModel(
        myBusinessRepository: context.read(),
        catalogRepository: context.read(),
      )..load(),
      child: const _RegisterBusinessView(),
    );
  }
}

class _RegisterBusinessView extends StatefulWidget {
  const _RegisterBusinessView();

  @override
  State<_RegisterBusinessView> createState() => _RegisterBusinessViewState();
}

class _RegisterBusinessViewState extends State<_RegisterBusinessView> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _phone;
  late final TextEditingController _address;

  @override
  void initState() {
    super.initState();
    final vm = context.read<RegisterBusinessViewModel>();
    _name = TextEditingController(text: vm.name);
    _description = TextEditingController(text: vm.description);
    _phone = TextEditingController(text: vm.phone);
    _address = TextEditingController(text: vm.address);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final error = await context.read<RegisterBusinessViewModel>().submit();
    if (!mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const BusinessHomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegisterBusinessViewModel>();
    final catalogsReady =
        vm.categories.isNotEmpty && vm.municipalities.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Registrar negocio', style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                children: [
                  Text('PARA PROFESIONALES', style: AppTheme.eyebrow()),
                  const SizedBox(height: 8),
                  Text(
                    'Pon tu negocio\nen Citalis.',
                    style: AppTheme.display(size: 32, weight: FontWeight.w400),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Completa estos datos para crear el perfil público. Podrás editarlos cuando quieras.',
                    style: AppTheme.sans(
                      size: 15,
                      color: AppTheme.inkMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _label('NOMBRE DEL NEGOCIO'),
                  TextField(
                    controller: _name,
                    onChanged: (v) {
                      vm.name = v;
                      vm.fieldsChanged();
                    },
                  ),
                  const SizedBox(height: 20),
                  _label('CATEGORÍA'),
                  if (catalogsReady)
                    _CategoryDropdown(
                      value: vm.category,
                      options: vm.categories,
                      onChanged: (v) => vm.category = v,
                    )
                  else
                    _catalogPlaceholder(vm),
                  const SizedBox(height: 20),
                  _label('DESCRIPCIÓN'),
                  TextField(
                    controller: _description,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Qué te hace diferente, estilo, especialidades…',
                    ),
                    onChanged: (v) {
                      vm.description = v;
                      vm.fieldsChanged();
                    },
                  ),
                  const SizedBox(height: 20),
                  _label('TELÉFONO'),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    onChanged: (v) {
                      vm.phone = v;
                      vm.fieldsChanged();
                    },
                  ),
                  const SizedBox(height: 20),
                  _label('DIRECCIÓN'),
                  TextField(
                    controller: _address,
                    onChanged: (v) {
                      vm.address = v;
                      vm.fieldsChanged();
                    },
                  ),
                  const SizedBox(height: 20),
                  _label('MUNICIPIO'),
                  if (catalogsReady)
                    _MunicipalityDropdown(
                      value: vm.municipality,
                      options: vm.municipalities,
                      onChanged: (v) => vm.municipality = v,
                    )
                  else
                    _catalogPlaceholder(vm),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppTheme.ink,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Después podrás agregar fotos, servicios, horarios y descargar tu código QR.',
                            style: AppTheme.sans(
                              size: 13,
                              color: AppTheme.inkMuted,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
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
                  onPressed: catalogsReady && vm.canSubmit ? _submit : null,
                  child: const Text('Crear mi negocio'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _catalogPlaceholder(RegisterBusinessViewModel vm) =>
      vm.errorMessage != null
      ? ErrorView(message: vm.errorMessage!, onRetry: vm.load)
      : const LinearProgressIndicator(color: AppTheme.ink);

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: AppTheme.eyebrow()),
  );
}

class _CategoryDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _CategoryDropdown({
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

class _MunicipalityDropdown extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _MunicipalityDropdown({
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
