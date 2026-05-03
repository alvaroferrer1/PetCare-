import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/widgets/empty_state.dart';

class TimelineView extends ConsumerWidget {
  const TimelineView({required this.petId, super.key});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateControllerProvider);
    final matches = state.pets.where((item) => item.id == petId);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Timeline')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No se pudo cargar esta mascota.'),
          ),
        ),
      );
    }
    final pet = matches.first;
    final items = [
      for (final event in state.events.where((item) => item.petId == petId))
        _TimelineItem(
          date: event.eventDate,
          title: event.title,
          subtitle: '${event.type.label} · ${event.status.label}',
          icon: Icons.event_note,
        ),
      for (final note in state.notes.where((item) => item.petId == petId))
        _TimelineItem(
          date: note.noteDate,
          title: note.symptoms.isEmpty ? 'Nota de salud' : note.symptoms,
          subtitle: 'Energia ${note.energyLevel}/5 · ${note.appetite}',
          icon: Icons.monitor_heart_outlined,
        ),
      for (final weight in state.weightLogs.where(
        (item) => item.petId == petId,
      ))
        _TimelineItem(
          date: weight.loggedAt,
          title: '${weight.weight.toStringAsFixed(1)} kg',
          subtitle: weight.notes.isEmpty ? 'Peso registrado' : weight.notes,
          icon: Icons.monitor_weight_outlined,
        ),
      for (final doc in state.documents.where((item) => item.petId == petId))
        _TimelineItem(
          date: doc.createdAt,
          title: doc.title,
          subtitle: 'Documento · ${doc.documentType}',
          icon: Icons.description_outlined,
        ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: Text('Timeline de ${pet.name}')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          if (items.isEmpty)
            const EmptyState(
              icon: Icons.timeline,
              title: 'Sin linea temporal',
              message:
                  'Los eventos, notas, pesos y documentos apareceran aqui.',
            )
          else
            for (final item in items)
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Icon(item.icon)),
                  title: Text(item.title),
                  subtitle: Text(item.subtitle),
                  trailing: Text(DateFormat.MMMd('es').format(item.date)),
                ),
              ),
        ],
      ),
    );
  }
}

class _TimelineItem {
  const _TimelineItem({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
}
