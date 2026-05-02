import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/care_event_model.dart';

class RemindersView extends ConsumerStatefulWidget {
  const RemindersView({super.key});

  @override
  ConsumerState<RemindersView> createState() => _RemindersViewState();
}

class _RemindersViewState extends ConsumerState<RemindersView> {
  CareEventStatus? _statusFilter = CareEventStatus.pending;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateControllerProvider);
    final petsById = {for (final pet in state.pets) pet.id: pet};
    final events = state.events.where((event) {
      if (_statusFilter == null) return true;
      return event.status == _statusFilter;
    }).toList()..sort((a, b) => a.eventDate.compareTo(b.eventDate));

    return Scaffold(
      appBar: AppBar(title: const Text('Recordatorios')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Plan de cuidados',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Filtra eventos, revisa fechas y marca cuidados como completados.',
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                selected: _statusFilter == null,
                label: const Text('Todos'),
                onSelected: (_) => setState(() => _statusFilter = null),
              ),
              for (final status in CareEventStatus.values)
                FilterChip(
                  selected: _statusFilter == status,
                  label: Text(status.label),
                  onSelected: (_) => setState(() => _statusFilter = status),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (events.isEmpty)
            const EmptyState(
              icon: Icons.event_available,
              title: 'Sin recordatorios',
              message: 'Cuando crees eventos apareceran organizados aqui.',
            )
          else
            for (final entry in events.indexed)
              AnimatedListItem(
                index: entry.$1,
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        entry.$2.status == CareEventStatus.completed
                            ? Icons.check
                            : Icons.schedule,
                      ),
                    ),
                    title: Text(entry.$2.title),
                    subtitle: Text(
                      '${petsById[entry.$2.petId]?.name ?? 'Mascota'} · ${entry.$2.type.label} · ${DateFormat.yMMMd('es').format(entry.$2.eventDate)}',
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
}
