import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/utils/date_text.dart';
import '../../core/widgets/empty_state.dart';

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateControllerProvider);
    final petsById = {for (final pet in state.pets) pet.id: pet.name};
    final events = state.events.where((event) {
      return event.eventDate.year == _month.year &&
          event.eventDate.month == _month.month;
    }).toList()..sort((a, b) => a.eventDate.compareTo(b.eventDate));

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => setState(
                  () => _month = DateTime(_month.year, _month.month - 1),
                ),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  formatMonthYear(_month),
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              IconButton(
                onPressed: () => setState(
                  () => _month = DateTime(_month.year, _month.month + 1),
                ),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (events.isEmpty)
            const EmptyState(
              icon: Icons.calendar_month,
              title: 'Mes sin cuidados',
              message: 'Los eventos del mes apareceran aqui.',
            )
          else
            for (final event in events)
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${event.eventDate.day}')),
                  title: Text(event.title),
                  subtitle: Text(
                    '${petsById[event.petId] ?? 'Mascota'} · ${event.type.label}',
                  ),
                  trailing: Chip(label: Text(event.status.label)),
                ),
              ),
        ],
      ),
    );
  }
}
