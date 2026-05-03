import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/constants/app_copy.dart';

class VetReportView extends ConsumerWidget {
  const VetReportView({required this.petId, super.key});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateControllerProvider);
    final matches = state.pets.where((item) => item.id == petId);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Informe veterinario')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No se pudo cargar esta mascota.'),
          ),
        ),
      );
    }
    final pet = matches.first;
    final events = state.events.where((item) => item.petId == petId).toList();
    final notes = state.notes.where((item) => item.petId == petId).toList();
    final weights = state.weightLogs
        .where((item) => item.petId == petId)
        .toList();
    final report = StringBuffer()
      ..writeln('Informe veterinario - ${pet.name}')
      ..writeln('Especie: ${pet.species.label}')
      ..writeln('Raza: ${pet.breed}')
      ..writeln('Peso actual: ${pet.weight ?? 'No registrado'}')
      ..writeln(
        'Alergias: ${pet.allergies.isEmpty ? 'Sin registrar' : pet.allergies}',
      )
      ..writeln('')
      ..writeln('Eventos:')
      ..writeAll(
        events.map(
          (e) => '- ${e.title} (${e.type.label}, ${e.status.label})\n',
        ),
      )
      ..writeln('')
      ..writeln('Notas de salud:')
      ..writeAll(
        notes.map(
          (n) => '- Energia ${n.energyLevel}/5: ${n.symptoms} ${n.notes}\n',
        ),
      )
      ..writeln('')
      ..writeln('Pesos:')
      ..writeAll(weights.map((w) => '- ${w.weight} kg: ${w.notes}\n'))
      ..writeln('')
      ..writeln(AppCopy.aiNotice);

    return Scaffold(
      appBar: AppBar(title: const Text('Informe veterinario')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: SelectableText(report.toString()),
            ),
          ),
        ],
      ),
    );
  }
}
