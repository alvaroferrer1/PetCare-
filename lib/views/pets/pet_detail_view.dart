import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/navigation/safe_navigation.dart';
import '../../core/utils/date_text.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/app_section.dart';
import '../../core/widgets/metric_card.dart';
import '../../models/care_event_model.dart';
import '../../models/pet_model.dart';
import '../ai_assistant/ai_assistant_view.dart';
import '../care_events/care_event_form_view.dart';
import '../health_notes/health_note_form_view.dart';
import 'pet_documents_view.dart';
import 'pet_form_view.dart';
import 'timeline_view.dart';
import 'weight_view.dart';
import 'wellbeing_view.dart';
import '../reports/vet_report_view.dart';

class PetDetailView extends ConsumerStatefulWidget {
  const PetDetailView({required this.petId, super.key});

  final String petId;

  @override
  ConsumerState<PetDetailView> createState() => _PetDetailViewState();
}

class _PetDetailViewState extends ConsumerState<PetDetailView> {
  CareEventType? _typeFilter;
  CareEventStatus? _statusFilter;
  _HistoryDateFilter _dateFilter = _HistoryDateFilter.all;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateControllerProvider);
    final matches = state.pets.where((item) => item.id == widget.petId);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mascota')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Esta mascota ya no existe o no se pudo cargar.'),
          ),
        ),
      );
    }
    final pet = matches.first;
    final allEvents = state.events
        .where((item) => item.petId == widget.petId)
        .toList();
    final events = allEvents.where(_matchesHistoryFilters).toList()
      ..sort((a, b) => b.eventDate.compareTo(a.eventDate));
    final notes = state.notes
        .where((item) => item.petId == widget.petId)
        .toList();
    final pending = allEvents
        .where((event) => event.status == CareEventStatus.pending)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          IconButton(
            onPressed: () =>
                context.openScreen(PetFormView(petId: widget.petId)),
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar',
          ),
          IconButton(
            onPressed: () async {
              await ref
                  .read(appStateControllerProvider.notifier)
                  .deletePet(widget.petId);
              if (context.mounted) context.closeToRoot();
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
                  value: '${allEvents.length}',
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
                  onPressed: () =>
                      context.openScreen(
                        CareEventFormView(petId: widget.petId),
                      ),
                  icon: const Icon(Icons.event_note),
                  label: const Text('Evento'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.tonalIcon(
                  onPressed: () =>
                      context.openScreen(
                        HealthNoteFormView(petId: widget.petId),
                      ),
                  icon: const Icon(Icons.note_add_outlined),
                  label: const Text('Nota'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppSection(
            title: 'Historial',
            child: allEvents.isEmpty
                ? const Text('Aun no hay eventos.')
                : Column(
                    children: [
                      _HistoryFilters(
                        typeFilter: _typeFilter,
                        statusFilter: _statusFilter,
                        dateFilter: _dateFilter,
                        onTypeChanged: (value) =>
                            setState(() => _typeFilter = value),
                        onStatusChanged: (value) =>
                            setState(() => _statusFilter = value),
                        onDateChanged: (value) =>
                            setState(() => _dateFilter = value),
                      ),
                      const SizedBox(height: 12),
                      if (events.isEmpty)
                        const Text('No hay eventos con estos filtros.'),
                      for (final entry in events.indexed)
                        AnimatedListItem(
                          index: entry.$1,
                          child: Card(
                            child: ListTile(
                              title: Text(entry.$2.title),
                              subtitle: Text(
                                '${entry.$2.type.label} · ${formatReadableDate(entry.$2.eventDate)}',
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
            onPressed: () => context.openScreen(const AiAssistantView()),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generar resumen IA'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () =>
                context.openScreen(WellbeingView(petId: widget.petId)),
            icon: const Icon(Icons.favorite_border),
            label: const Text('Panel de bienestar'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () =>
                context.openScreen(TimelineView(petId: widget.petId)),
            icon: const Icon(Icons.timeline),
            label: const Text('Timeline completo'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () =>
                context.openScreen(WeightView(petId: widget.petId)),
            icon: const Icon(Icons.monitor_weight_outlined),
            label: const Text('Peso y grafica'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () =>
                context.openScreen(PetDocumentsView(petId: widget.petId)),
            icon: const Icon(Icons.description_outlined),
            label: const Text('Documentos'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: () =>
                context.openScreen(VetReportView(petId: widget.petId)),
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Informe veterinario'),
          ),
        ],
      ),
    );
  }

  bool _matchesHistoryFilters(CareEventModel event) {
    if (_typeFilter != null && event.type != _typeFilter) return false;
    if (_statusFilter != null && event.status != _statusFilter) return false;
    return switch (_dateFilter) {
      _HistoryDateFilter.all => true,
      _HistoryDateFilter.past => event.eventDate.isBefore(DateTime.now()),
      _HistoryDateFilter.future => event.eventDate.isAfter(DateTime.now()),
    };
  }
}

enum _HistoryDateFilter { all, past, future }

class _HistoryFilters extends StatelessWidget {
  const _HistoryFilters({
    required this.typeFilter,
    required this.statusFilter,
    required this.dateFilter,
    required this.onTypeChanged,
    required this.onStatusChanged,
    required this.onDateChanged,
  });

  final CareEventType? typeFilter;
  final CareEventStatus? statusFilter;
  final _HistoryDateFilter dateFilter;
  final ValueChanged<CareEventType?> onTypeChanged;
  final ValueChanged<CareEventStatus?> onStatusChanged;
  final ValueChanged<_HistoryDateFilter> onDateChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<CareEventType?>(
          value: typeFilter,
          decoration: const InputDecoration(labelText: 'Tipo'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todos')),
            for (final type in CareEventType.values)
              DropdownMenuItem(value: type, child: Text(type.label)),
          ],
          onChanged: onTypeChanged,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<CareEventStatus?>(
          value: statusFilter,
          decoration: const InputDecoration(labelText: 'Estado'),
          items: [
            const DropdownMenuItem(value: null, child: Text('Todos')),
            for (final status in CareEventStatus.values)
              DropdownMenuItem(value: status, child: Text(status.label)),
          ],
          onChanged: onStatusChanged,
        ),
        const SizedBox(height: 10),
        SegmentedButton<_HistoryDateFilter>(
          selected: {dateFilter},
          segments: const [
            ButtonSegment(value: _HistoryDateFilter.all, label: Text('Todo')),
            ButtonSegment(
              value: _HistoryDateFilter.past,
              label: Text('Pasado'),
            ),
            ButtonSegment(
              value: _HistoryDateFilter.future,
              label: Text('Futuro'),
            ),
          ],
          onSelectionChanged: (value) => onDateChanged(value.first),
        ),
      ],
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
                  if (pet.allergies.isNotEmpty)
                    Text('Alergias: ${pet.allergies}'),
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
