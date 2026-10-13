import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';

class BusinessServicesTab extends StatefulWidget {
  const BusinessServicesTab({super.key});

  @override
  State<BusinessServicesTab> createState() => _BusinessServicesTabState();
}

class _BusinessServicesTabState extends State<BusinessServicesTab> {
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

  void _onChange() => mounted ? setState(() {}) : null;

  void _openEditor({Service? service}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => _ServiceEditor(service: service),
    );
  }

  void _confirmDelete(Service s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 24, 24, 24 + MediaQuery.of(ctx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 40, height: 4, color: AppTheme.line)),
            const SizedBox(height: 20),
            Text('Eliminar servicio',
                style: AppTheme.serif(size: 22, weight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text('"${s.name}" dejará de aparecer en tu perfil público.',
                style: AppTheme.sans(
                    size: 14, color: AppTheme.inkMuted, height: 1.5)),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
              onPressed: () {
                _state.removeService(s.id);
                Navigator.pop(ctx);
              },
              child: const Text('Eliminar'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = _state.myBusiness?.services ?? [];

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('CATÁLOGO', style: AppTheme.eyebrow()),
                        const SizedBox(height: 6),
                        Text(
                            services.isEmpty
                                ? 'Aún no hay servicios'
                                : '${services.length} ${services.length == 1 ? "servicio" : "servicios"}',
                            style: AppTheme.serif(
                                size: 24, weight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (services.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _EmptyServices(onAdd: () => _openEditor()),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    for (final s in services) ...[
                      _ServiceRow(
                        service: s,
                        onEdit: () => _openEditor(service: s),
                        onDelete: () => _confirmDelete(s),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: 100),
          ],
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: FloatingActionButton.extended(
            onPressed: () => _openEditor(),
            backgroundColor: AppTheme.ink,
            foregroundColor: Colors.white,
            elevation: 0,
            icon: const Icon(Icons.add, size: 20),
            label: Text('Nuevo servicio',
                style: AppTheme.sans(
                    size: 13, weight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ],
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final Service service;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ServiceRow({
    required this.service,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(service.name,
                          style: AppTheme.serif(
                              size: 17, weight: FontWeight.w500)),
                    ),
                    const SizedBox(width: 8),
                    Text('\$${service.price.toStringAsFixed(0)}',
                        style: AppTheme.serif(
                            size: 18, weight: FontWeight.w500)),
                  ],
                ),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz_rounded, color: AppTheme.ink),
            color: AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AppTheme.line),
            ),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit_outlined,
                        size: 16, color: AppTheme.ink),
                    const SizedBox(width: 10),
                    Text('Editar', style: AppTheme.sans(size: 14)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline,
                        size: 16, color: AppTheme.danger),
                    const SizedBox(width: 10),
                    Text('Eliminar',
                        style:
                            AppTheme.sans(size: 14, color: AppTheme.danger)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyServices extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyServices({required this.onAdd});

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
            child: const Icon(Icons.layers_outlined, color: AppTheme.ink),
          ),
          const SizedBox(height: 20),
          Text('Sin servicios',
              style: AppTheme.serif(size: 20, weight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(
            'Agrega al menos un servicio para que los clientes puedan reservar.',
            textAlign: TextAlign.center,
            style:
                AppTheme.sans(size: 14, color: AppTheme.inkMuted, height: 1.5),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: onAdd, child: const Text('Agregar servicio')),
        ],
      ),
    );
  }
}

class _ServiceEditor extends StatefulWidget {
  final Service? service;
  const _ServiceEditor({this.service});

  @override
  State<_ServiceEditor> createState() => _ServiceEditorState();
}

class _ServiceEditorState extends State<_ServiceEditor> {
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _duration;
  late final TextEditingController _price;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _name = TextEditingController(text: s?.name ?? '');
    _desc = TextEditingController(text: s?.description ?? '');
    _duration = TextEditingController(text: s?.durationMinutes.toString() ?? '45');
    _price = TextEditingController(text: s?.price.toStringAsFixed(0) ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _duration.dispose();
    _price.dispose();
    super.dispose();
  }

  bool get _valid {
    final d = int.tryParse(_duration.text.trim());
    final p = double.tryParse(_price.text.trim());
    return _name.text.trim().isNotEmpty &&
        d != null && d > 0 &&
        p != null && p > 0;
  }

  void _save() {
    final s = widget.service;
    final n = _name.text.trim();
    final desc = _desc.text.trim();
    final d = int.parse(_duration.text.trim());
    final p = double.parse(_price.text.trim());

    if (s == null) {
      final created = Service(
        id: 'mine-s${DateTime.now().microsecondsSinceEpoch}',
        name: n,
        description: desc,
        durationMinutes: d,
        price: p,
      );
      AppState.instance.addService(created);
    } else {
      AppState.instance.updateService(s.copyWith(
        name: n,
        description: desc,
        durationMinutes: d,
        price: p,
      ));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.service == null;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Container(width: 40, height: 4, color: AppTheme.line)),
              const SizedBox(height: 20),
              Text(isNew ? 'Nuevo servicio' : 'Editar servicio',
                  style: AppTheme.serif(size: 22, weight: FontWeight.w500)),
              const SizedBox(height: 20),
              Text('NOMBRE', style: AppTheme.eyebrow()),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'Ej. Corte & lavado'),
              ),
              const SizedBox(height: 16),
              Text('DESCRIPCIÓN', style: AppTheme.eyebrow()),
              const SizedBox(height: 8),
              TextField(
                controller: _desc,
                minLines: 2,
                maxLines: 4,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Qué incluye el servicio',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('DURACIÓN (MIN)', style: AppTheme.eyebrow()),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _duration,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(hintText: '45'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PRECIO (MXN)', style: AppTheme.eyebrow()),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _price,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(hintText: '320'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _valid ? _save : null,
                child: Text(isNew ? 'Crear servicio' : 'Guardar cambios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
