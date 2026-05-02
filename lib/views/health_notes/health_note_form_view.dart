import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../controllers/app_state_controller.dart';
import '../../models/health_note_model.dart';

class HealthNoteFormView extends ConsumerStatefulWidget {
  const HealthNoteFormView({required this.petId, super.key});

  final String petId;

  @override
  ConsumerState<HealthNoteFormView> createState() => _HealthNoteFormViewState();
}

class _HealthNoteFormViewState extends ConsumerState<HealthNoteFormView> {
  final _symptoms = TextEditingController();
  final _mood = TextEditingController();
  final _appetite = TextEditingController();
  final _notes = TextEditingController();
  double _energy = 3;

  @override
  void dispose() {
    _symptoms.dispose();
    _mood.dispose();
    _appetite.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nota de salud')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          TextField(
            controller: _symptoms,
            decoration: const InputDecoration(labelText: 'Sintomas'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mood,
            decoration: const InputDecoration(labelText: 'Estado de animo'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _appetite,
            decoration: const InputDecoration(labelText: 'Apetito'),
          ),
          const SizedBox(height: 18),
          Text('Nivel de energia: ${_energy.round()}/5'),
          Slider(
            value: _energy,
            min: 1,
            max: 5,
            divisions: 4,
            label: _energy.round().toString(),
            onChanged: (value) => setState(() => _energy = value),
          ),
          TextField(
            controller: _notes,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Notas'),
          ),
          const SizedBox(height: 22),
          FilledButton(onPressed: _save, child: const Text('Guardar nota')),
        ],
      ),
    );
  }

  Future<void> _save() async {
    final profile = ref.read(appStateControllerProvider).profile;
    final now = DateTime.now();
    await ref
        .read(appStateControllerProvider.notifier)
        .addNote(
          HealthNoteModel(
            id: '',
            userId: profile?.id ?? 'demo-user',
            petId: widget.petId,
            symptoms: _symptoms.text.trim(),
            mood: _mood.text.trim(),
            appetite: _appetite.text.trim(),
            energyLevel: _energy.round(),
            notes: _notes.text.trim(),
            noteDate: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
    if (mounted) context.go('/pets/${widget.petId}');
  }
}
