import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/app_state_controller.dart';
import '../../models/care_event_model.dart';

class CareEventFormView extends ConsumerStatefulWidget {
  const CareEventFormView({required this.petId, super.key});

  final String petId;

  @override
  ConsumerState<CareEventFormView> createState() => _CareEventFormViewState();
}

class _CareEventFormViewState extends ConsumerState<CareEventFormView> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  CareEventType _type = CareEventType.vaccine;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo cuidado')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          DropdownButtonFormField<CareEventType>(
            value: _type,
            decoration: const InputDecoration(labelText: 'Tipo'),
            items: CareEventType.values
                .map(
                  (type) =>
                      DropdownMenuItem(value: type, child: Text(type.label)),
                )
                .toList(),
            onChanged: (value) => setState(() => _type = value!),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _title,
            decoration: const InputDecoration(labelText: 'Titulo'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _description,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Descripcion'),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Fecha'),
            subtitle: Text(_date.toLocal().toString().split(' ').first),
            trailing: const Icon(Icons.calendar_month),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
                initialDate: _date,
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
          const SizedBox(height: 22),
          FilledButton(onPressed: _save, child: const Text('Guardar evento')),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final profile = ref.read(appStateControllerProvider).profile;
    final now = DateTime.now();
    await ref
        .read(appStateControllerProvider.notifier)
        .addEvent(
          CareEventModel(
            id: '',
            userId: profile?.id ?? 'demo-user',
            petId: widget.petId,
            type: _type,
            title: _title.text.trim().isEmpty
                ? _type.label
                : _title.text.trim(),
            description: _description.text.trim(),
            eventDate: _date,
            status: CareEventStatus.pending,
            createdAt: now,
            updatedAt: now,
          ),
        );
    if (mounted) context.go('/pets/${widget.petId}');
  }
}
