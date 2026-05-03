import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/constants/app_copy.dart';

class VetVisitPrepView extends ConsumerStatefulWidget {
  const VetVisitPrepView({super.key});

  @override
  ConsumerState<VetVisitPrepView> createState() => _VetVisitPrepViewState();
}

class _VetVisitPrepViewState extends ConsumerState<VetVisitPrepView> {
  String? _petId;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateControllerProvider);
    final pets = state.pets;
    final selectedPet = pets.where((pet) => pet.id == _petId).firstOrNull;
    final pet = selectedPet ?? (pets.isEmpty ? null : pets.first);
    final notes = pet == null
        ? []
        : state.notes.where((note) => note.petId == pet.id).take(5).toList();
    final pending = pet == null
        ? []
        : state.pendingEvents
              .where((event) => event.petId == pet.id)
              .take(5)
              .toList();
    final summary = pet == null ? null : state.summaries[pet.id];

    return Scaffold(
      appBar: AppBar(title: const Text('Preparar visita')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Antes del veterinario',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          if (pets.isNotEmpty)
            DropdownButtonFormField<String>(
              value: pet?.id,
              decoration: const InputDecoration(
                labelText: 'Mascota',
                prefixIcon: Icon(Icons.pets),
              ),
              items: [
                for (final item in pets)
                  DropdownMenuItem(value: item.id, child: Text(item.name)),
              ],
              onChanged: (value) => setState(() => _petId = value),
            ),
          const SizedBox(height: 18),
          _PrepCard(
            title: 'Pendientes',
            children: pending.isEmpty
                ? const [Text('Sin recordatorios pendientes.')]
                : [
                    for (final event in pending)
                      Text(
                        '· ${event.title} (${DateFormat.yMMMd('es').format(event.eventDate)})',
                      ),
                  ],
          ),
          _PrepCard(
            title: 'Notas recientes',
            children: notes.isEmpty
                ? const [Text('Sin notas recientes.')]
                : [
                    for (final note in notes)
                      Text(
                        '· ${note.symptoms.isEmpty ? 'Sin sintomas' : note.symptoms} · energia ${note.energyLevel}/5',
                      ),
                  ],
          ),
          _PrepCard(
            title: 'Preguntas sugeridas',
            children: summary == null
                ? const [
                    Text('Genera un resumen IA para obtener preguntas.'),
                    Text('· ¿Hay vacunas pendientes?'),
                    Text('· ¿Los sintomas recientes requieren revision?'),
                    Text('· ¿El peso y apetito son adecuados?'),
                  ]
                : [
                    for (final question in summary.vetQuestions)
                      Text('· $question'),
                  ],
          ),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(AppCopy.aiNotice),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrepCard extends StatelessWidget {
  const _PrepCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }
}
