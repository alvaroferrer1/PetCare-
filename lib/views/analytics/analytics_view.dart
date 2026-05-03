import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/widgets/metric_card.dart';
import '../../models/care_event_model.dart';
import '../../models/food_safety_item_model.dart';

class AnalyticsView extends ConsumerWidget {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateControllerProvider);
    final completed = state.events
        .where((event) => event.status == CareEventStatus.completed)
        .length;
    final toxicChecks = state.productChecks
        .where((check) => check.highestLevel == FoodSafetyLevel.toxic)
        .length;
    final avgEnergy = state.notes.isEmpty
        ? 0.0
        : state.notes.map((note) => note.energyLevel).reduce((a, b) => a + b) /
              state.notes.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Estadisticas')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Resumen global',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  icon: Icons.check_circle_outline,
                  label: 'Completados',
                  value: '$completed',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  icon: Icons.pending_actions,
                  label: 'Pendientes',
                  value: '${state.pendingEvents.length}',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  icon: Icons.bolt_outlined,
                  label: 'Energia media',
                  value: state.notes.isEmpty
                      ? '-'
                      : avgEnergy.toStringAsFixed(1),
                  color: Colors.teal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'Riesgos comida',
                  value: '$toxicChecks',
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _BreakdownCard(
            title: 'Cuidados por tipo',
            rows: {
              for (final type in CareEventType.values)
                type.label: state.events
                    .where((event) => event.type == type)
                    .length,
            },
          ),
          const SizedBox(height: 12),
          _BreakdownCard(
            title: 'Mascotas con alergias',
            rows: {
              for (final pet in state.pets)
                pet.name: pet.allergies.isEmpty ? 0 : 1,
            },
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  const _BreakdownCard({required this.title, required this.rows});

  final String title;
  final Map<String, int> rows;

  @override
  Widget build(BuildContext context) {
    final max = rows.values.fold<int>(1, (a, b) => b > a ? b : a);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            for (final entry in rows.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(width: 120, child: Text(entry.key)),
                    Expanded(
                      child: LinearProgressIndicator(value: entry.value / max),
                    ),
                    const SizedBox(width: 10),
                    Text('${entry.value}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
