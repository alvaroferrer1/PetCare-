import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/widgets/empty_state.dart';

class RecentHealthView extends ConsumerWidget {
  const RecentHealthView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateControllerProvider);
    final notes = state.notes.take(12).toList();
    final avgEnergy = notes.isEmpty
        ? 0.0
        : notes.map((note) => note.energyLevel).reduce((a, b) => a + b) /
              notes.length;
    final symptoms = notes
        .where((note) => note.symptoms.trim().isNotEmpty)
        .length;

    return Scaffold(
      appBar: AppBar(title: const Text('Salud reciente')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Tendencias',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TrendCard(
                  label: 'Energia media',
                  value: avgEnergy.toStringAsFixed(1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _TrendCard(
                  label: 'Notas con sintomas',
                  value: '$symptoms',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (notes.isEmpty)
            const EmptyState(
              icon: Icons.monitor_heart_outlined,
              title: 'Sin notas recientes',
              message:
                  'Registra sintomas, apetito y energia para ver tendencias.',
            )
          else
            for (final note in notes)
              Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text('${note.energyLevel}/5')),
                  title: Text(
                    note.symptoms.isEmpty ? 'Sin sintomas' : note.symptoms,
                  ),
                  subtitle: Text(
                    '${note.mood} · ${note.appetite} · ${note.notes}',
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({required this.label, required this.value});

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
