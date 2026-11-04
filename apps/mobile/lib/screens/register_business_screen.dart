import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../theme/app_theme.dart';
import 'business/business_home_screen.dart';

class RegisterBusinessScreen extends StatefulWidget {
  const RegisterBusinessScreen({super.key});

  @override
  State<RegisterBusinessScreen> createState() => _RegisterBusinessScreenState();
}

class _RegisterBusinessScreenState extends State<RegisterBusinessScreen> {
  final _name = TextEditingController(text: 'Estudio María');
  final _description = TextEditingController(
      text: 'Peluquería y color editorial con enfoque natural.');
  final _phone = TextEditingController(text: '+52 777 456 7890');
  final _address = TextEditingController(text: 'Av. Álvaro Obregón 320');
  String _category = 'Peluquería';
  String _municipality = 'Cuernavaca';

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _name.text.trim().isNotEmpty &&
      _description.text.trim().isNotEmpty &&
      _phone.text.trim().isNotEmpty &&
      _address.text.trim().isNotEmpty;

  void _submit() {
    final b = createMyBusiness(
      name: _name.text.trim(),
      category: _category,
      description: _description.text.trim(),
      phone: _phone.text.trim(),
      address: _address.text.trim(),
      municipality: _municipality,
    );
    AppState.instance.registerBusiness(b);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const BusinessHomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  Text('Pon tu negocio\nen Citalis.',
                      style: AppTheme.display(
                          size: 32, weight: FontWeight.w400)),
                  const SizedBox(height: 10),
                  Text(
                    'Completa estos datos para crear el perfil público. Podrás editarlos cuando quieras.',
                    style: AppTheme.sans(
                        size: 15, color: AppTheme.inkMuted, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  _label('NOMBRE DEL NEGOCIO'),
                  TextField(
                    controller: _name,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  _label('CATEGORÍA'),
                  _CategoryDropdown(
                    value: _category,
                    onChanged: (v) => setState(() => _category = v),
                  ),
                  const SizedBox(height: 20),
                  _label('DESCRIPCIÓN'),
                  TextField(
                    controller: _description,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Qué te hace diferente, estilo, especialidades…',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  _label('TELÉFONO'),
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  _label('DIRECCIÓN'),
                  TextField(
                    controller: _address,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  _label('MUNICIPIO'),
                  _MunicipalityDropdown(
                    value: _municipality,
                    onChanged: (v) => setState(() => _municipality = v),
                  ),
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
                        const Icon(Icons.info_outline,
                            size: 16, color: AppTheme.ink),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Después podrás agregar fotos, servicios, horarios y descargar tu código QR.',
                            style: AppTheme.sans(
                                size: 13,
                                color: AppTheme.inkMuted,
                                height: 1.5),
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
                  onPressed: _canSubmit ? _submit : null,
                  child: const Text('Crear mi negocio'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: AppTheme.eyebrow()),
      );
}

class _CategoryDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _CategoryDropdown({required this.value, required this.onChanged});

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
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppTheme.ink),
          style: AppTheme.sans(size: 15),
          items: businessCategories
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
  final ValueChanged<String> onChanged;
  const _MunicipalityDropdown({required this.value, required this.onChanged});

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
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppTheme.ink),
          style: AppTheme.sans(size: 15),
          items: municipalities
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
