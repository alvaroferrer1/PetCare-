import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/navigation/safe_navigation.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/care_event_model.dart';
import '../pets/pet_form_view.dart';
import 'care_event_form_view.dart';

class CareTypeOverviewView extends ConsumerWidget {
  const CareTypeOverviewView({
    required this.type,
    required this.title,
    required this.emptyTitle,
    required this.emptyMessage,
    super.key,
  });

  final CareEventType type;
  final String title;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateControllerProvider);
    final petsById = {for (final pet in state.pets) pet.id: pet};
    final events = state.events.where((event) => event.type == type).toList()
      ..sort((a, b) => b.eventDate.compareTo(a.eventDate));
    final pending = events
        .where((event) => event.status == CareEventStatus.pending)
        .length;
    final completed = events
        .where((event) => event.status == CareEventStatus.completed)
        .length;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              Expanded(
                child: _CounterCard(label: 'Pendientes', value: '$pending'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _CounterCard(label: 'Completados', value: '$completed'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (events.isEmpty)
            EmptyState(
              icon: _iconFor(type),
              title: emptyTitle,
              message: emptyMessage,
              action: state.pets.isEmpty
                  ? FilledButton.icon(
                      onPressed: () => context.openScreen(const PetFormView()),
                      icon: const Icon(Icons.add),
                      label: const Text('Anadir mascota'),
                    )
                  : FilledButton.icon(
                      onPressed: () => context.openScreen(
                        CareEventFormView(petId: state.pets.first.id),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Crear cuidado'),
                    ),
            )
          else
            for (final entry in events.indexed)
              AnimatedListItem(
                index: entry.$1,
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(_iconFor(type))),
                    title: Text(entry.$2.title),
                    subtitle: Text(
                      '${petsById[entry.$2.petId]?.name ?? 'Mascota'} · ${DateFormat.yMMMd('es').format(entry.$2.eventDate)}',
                    ),
                    trailing: entry.$2.status == CareEventStatus.pending
                        ? IconButton(
                            icon: const Icon(Icons.check_circle_outline),
                            onPressed: () => ref
                                .read(appStateControllerProvider.notifier)
                                .completeEvent(entry.$2.id),
                          )
                        : Chip(label: Text(entry.$2.status.label)),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  IconData _iconFor(CareEventType type) {
    return switch (type) {
      CareEventType.vaccine => Icons.vaccines_outlined,
      CareEventType.medication => Icons.medication_outlined,
      CareEventType.food => Icons.restaurant_menu,
      CareEventType.grooming => Icons.content_cut,
      CareEventType.deworming => Icons.health_and_safety_outlined,
      CareEventType.vetVisit => Icons.local_hospital_outlined,
      CareEventType.other => Icons.event_note,
    };
  }
}

class _CounterCard extends StatelessWidget {
  const _CounterCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
            Text(label),
          ],
        ),
      ),
    );
  }
}
