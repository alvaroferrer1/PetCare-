import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/constants/app_copy.dart';
import '../../core/utils/date_text.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/metric_card.dart';
import '../../models/care_event_model.dart';
import '../../models/weight_log_model.dart';

class WellbeingView extends ConsumerWidget {
  const WellbeingView({required this.petId, super.key});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateControllerProvider);
    final matches = state.pets.where((item) => item.id == petId);
    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bienestar')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('No se pudo cargar esta mascota.'),
          ),
        ),
      );
    }
    final pet = matches.first;
    final notes = state.notes.where((item) => item.petId == petId).toList()
      ..sort((a, b) => b.noteDate.compareTo(a.noteDate));
    final weights =
        state.weightLogs.where((item) => item.petId == petId).toList()
          ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
    final pending =
        state.events
            .where(
              (event) =>
                  event.petId == petId &&
                  event.status == CareEventStatus.pending,
            )
            .toList()
          ..sort((a, b) => a.eventDate.compareTo(b.eventDate));
    final avgEnergy = notes.isEmpty
        ? 0.0
        : notes.map((note) => note.energyLevel).reduce((a, b) => a + b) /
              notes.length;
    final latest = notes.isEmpty ? null : notes.first;
    final alerts = _buildAlerts(avgEnergy, latest?.symptoms ?? '', pending);

    return Scaffold(
      appBar: AppBar(title: Text('Bienestar de ${pet.name}')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  icon: Icons.bolt_outlined,
                  label: 'Energia media',
                  value: notes.isEmpty ? '-' : avgEnergy.toStringAsFixed(1),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: MetricCard(
                  icon: Icons.restaurant_outlined,
                  label: 'Apetito',
                  value: latest?.appetite.isEmpty == false
                      ? latest!.appetite
                      : '-',
                  color: Colors.teal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _Panel(
            title: 'Ultimos sintomas',
            child: notes.isEmpty
                ? const EmptyState(
                    icon: Icons.monitor_heart_outlined,
                    title: 'Sin notas',
                    message:
                        'Registra sintomas, apetito y energia para ver tendencias.',
                  )
                : Column(
                    children: [
                      for (final note in notes.take(4))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            note.symptoms.isEmpty
                                ? 'Sin sintomas registrados'
                                : note.symptoms,
                          ),
                          subtitle: Text(
                            '${formatReadableDate(note.noteDate)} · Energia ${note.energyLevel}/5 · ${note.mood}',
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 18),
          _Panel(
            title: 'Evolucion del peso',
            child: weights.isEmpty
                ? const Text('Registra el primer peso para ver evolucion.')
                : _WeightTrend(weights: weights),
          ),
          const SizedBox(height: 18),
          _Panel(
            title: 'Proximos cuidados',
            child: pending.isEmpty
                ? const Text('No hay cuidados pendientes para esta mascota.')
                : Column(
                    children: [
                      for (final event in pending.take(4))
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.schedule),
                          title: Text(event.title),
                          subtitle: Text(
                            '${event.type.label} · ${formatReadableDate(event.eventDate)}',
                          ),
                        ),
                    ],
                  ),
          ),
          const SizedBox(height: 18),
          _Panel(
            title: 'Alertas suaves',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final alert in alerts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(alert)),
                      ],
                    ),
                  ),
                const Divider(height: 24),
                const Text(AppCopy.veterinaryNotice),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<String> _buildAlerts(
    double avgEnergy,
    String symptoms,
    List<CareEventModel> pending,
  ) {
    final alerts = <String>[];
    if (avgEnergy > 0 && avgEnergy < 2.5) {
      alerts.add(
        'La energia media es baja. Observa evolucion y consulta si empeora.',
      );
    }
    if (symptoms.trim().isNotEmpty) {
      alerts.add(
        'Hay sintomas recientes registrados. Prepara preguntas para el veterinario.',
      );
    }
    if (pending.isNotEmpty &&
        pending.first.eventDate.isBefore(DateTime.now())) {
      alerts.add('Hay cuidados pendientes con fecha vencida.');
    }
    if (alerts.isEmpty) {
      alerts.add('No hay alertas destacadas con los datos registrados.');
    }
    return alerts;
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _WeightTrend extends StatelessWidget {
  const _WeightTrend({required this.weights});

  final List<WeightLogModel> weights;

  @override
  Widget build(BuildContext context) {
    final first = weights.first.weight;
    final last = weights.last.weight;
    final diff = last - first;
    final maxWeight = last > first ? last : first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Inicial: ${first.toStringAsFixed(1)} kg'),
        Text('Actual: ${last.toStringAsFixed(1)} kg'),
        Text(
          'Cambio: ${diff >= 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        for (final item in weights.take(6))
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: maxWeight <= 0
                        ? 0
                        : (item.weight / maxWeight).clamp(0.0, 1.0),
                  ),
                ),
                const SizedBox(width: 10),
                Text('${item.weight.toStringAsFixed(1)} kg'),
              ],
            ),
          ),
      ],
    );
  }
}
