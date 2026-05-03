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
  CareEventType? _typeFilter;
  String? _petFilter;
  _DateFilter _dateFilter = _DateFilter.all;
  bool _urgentOnly = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateControllerProvider);
    final petsById = {for (final pet in state.pets) pet.id: pet};
    final events = state.events.where((event) {
      if (_statusFilter != null && event.status != _statusFilter) {
        return false;
      }
      if (_typeFilter != null && event.type != _typeFilter) return false;
      if (_petFilter != null && event.petId != _petFilter) return false;
      if (_urgentOnly && !_isUrgent(event)) return false;
      return switch (_dateFilter) {
        _DateFilter.all => true,
        _DateFilter.today => _isSameDay(event.eventDate, DateTime.now()),
        _DateFilter.week => event.eventDate.isBefore(
          DateTime.now().add(const Duration(days: 7)),
        ),
        _DateFilter.overdue => event.eventDate.isBefore(DateTime.now()),
      };
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
            runSpacing: 8,
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
          const SizedBox(height: 10),
          DropdownButtonFormField<String?>(
            value: _petFilter,
            decoration: const InputDecoration(
              labelText: 'Mascota',
              prefixIcon: Icon(Icons.pets),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todas')),
              for (final pet in state.pets)
                DropdownMenuItem(value: pet.id, child: Text(pet.name)),
            ],
            onChanged: (value) => setState(() => _petFilter = value),
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<CareEventType?>(
            value: _typeFilter,
            decoration: const InputDecoration(
              labelText: 'Tipo de cuidado',
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todos')),
              for (final type in CareEventType.values)
                DropdownMenuItem(value: type, child: Text(type.label)),
            ],
            onChanged: (value) => setState(() => _typeFilter = value),
          ),
          const SizedBox(height: 10),
          SegmentedButton<_DateFilter>(
            selected: {_dateFilter},
            segments: const [
              ButtonSegment(value: _DateFilter.all, label: Text('Todas')),
              ButtonSegment(value: _DateFilter.today, label: Text('Hoy')),
              ButtonSegment(value: _DateFilter.week, label: Text('7 dias')),
              ButtonSegment(
                value: _DateFilter.overdue,
                label: Text('Vencidas'),
              ),
            ],
            onSelectionChanged: (value) =>
                setState(() => _dateFilter = value.first),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Solo urgentes'),
            subtitle: const Text('Vencidas o en las proximas 48 horas'),
            value: _urgentOnly,
            onChanged: (value) => setState(() => _urgentOnly = value),
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

  bool _isUrgent(CareEventModel event) {
    final now = DateTime.now();
    return event.eventDate.isBefore(now.add(const Duration(days: 2)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

enum _DateFilter { all, today, week, overdue }
