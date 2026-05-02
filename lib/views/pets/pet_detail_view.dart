import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/app_section.dart';
import '../../core/widgets/metric_card.dart';
import '../../models/care_event_model.dart';
import '../../models/pet_model.dart';

class PetDetailView extends ConsumerWidget {
  const PetDetailView({required this.petId, super.key});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateControllerProvider);
    final pet = state.pets.firstWhere((item) => item.id == petId);
    final events = state.events.where((item) => item.petId == petId).toList();
    final notes = state.notes.where((item) => item.petId == petId).toList();
    final pending = events
        .where((event) => event.status == CareEventStatus.pending)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          IconButton(
            onPressed: () => context.go('/pets/$petId/edit'),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
          ),
          IconButton(
            onPressed: () async {
              await ref
                  .read(appStateControllerProvider.notifier)
                  .deletePet(petId);
              if (context.mounted) context.go('/home');
            },
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          AnimatedListItem(index: 0, child: _PetHeader(pet: pet)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  icon: Icons.event_note,
                  label: 'Cuidados',
                  value: '${events.length}',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  icon: Icons.pending_actions,
                  label: 'Pendientes',
                  value: '$pending',
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  icon: Icons.monitor_heart_outlined,
                  label: 'Notas',
                  value: '${notes.length}',
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => context.go('/pets/$petId/events/new'),
                  icon: const Icon(Icons.event_note),
                  label: const Text('Evento'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () => context.go('/pets/$petId/notes/new'),
                  icon: const Icon(Icons.note_add_outlined),
                  label: const Text('Nota'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppSection(
            title: 'Historial',
            child: events.isEmpty
                ? const Text('Aun no hay eventos.')
                : Column(
                    children: [
                      for (final entry in events.indexed)
                        AnimatedListItem(
                          index: entry.$1,
                          child: Card(
                            child: ListTile(
                              title: Text(entry.$2.title),
                              subtitle: Text(
                                '${entry.$2.type.label} · ${DateFormat.yMMMd('es').format(entry.$2.eventDate)}',
                              ),
                              trailing: Chip(
                                label: Text(entry.$2.status.label),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 24),
          AppSection(
            title: 'Notas de salud',
            child: notes.isEmpty
                ? const Text('Aun no hay notas.')
                : Column(
                    children: [
                      for (final entry in notes.indexed)
                        AnimatedListItem(
                          index: entry.$1,
                          child: Card(
                            child: ListTile(
                              title: Text(
                                entry.$2.symptoms.isEmpty
                                    ? 'Nota de salud'
                                    : entry.$2.symptoms,
                              ),
                              subtitle: Text(
                                'Energia ${entry.$2.energyLevel}/5 · ${entry.$2.notes}',
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => context.go('/assistant'),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generar resumen IA'),
          ),
        ],
      ),
    );
  }
}

class _PetHeader extends StatelessWidget {
  const _PetHeader({required this.pet});

  final PetModel pet;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundImage: pet.photoUrl == null
                  ? null
                  : NetworkImage(pet.photoUrl!),
              child: pet.photoUrl == null
                  ? const Icon(Icons.pets, size: 36)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    '${pet.species.label} · ${pet.breed.isEmpty ? 'Raza sin definir' : pet.breed}',
                  ),
                  if (pet.weight != null) Text('${pet.weight} kg'),
                  if (pet.notes.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      pet.notes,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
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
