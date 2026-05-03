import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../models/weight_log_model.dart';

class WeightView extends ConsumerStatefulWidget {
  const WeightView({required this.petId, super.key});

  final String petId;

  @override
  ConsumerState<WeightView> createState() => _WeightViewState();
}

class _WeightViewState extends ConsumerState<WeightView> {
  final _weight = TextEditingController();
  final _notes = TextEditingController();

  @override
  void dispose() {
    _weight.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateControllerProvider);
    final logs = state.weightLogs
        .where((log) => log.petId == widget.petId)
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Peso')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          SizedBox(height: 180, child: _WeightChart(logs: logs)),
          const SizedBox(height: 14),
          TextField(
            controller: _weight,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Peso kg'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _notes,
            decoration: const InputDecoration(labelText: 'Notas'),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () async {
              final profile = state.profile;
              final value = double.tryParse(_weight.text.replaceAll(',', '.'));
              if (profile == null || value == null) return;
              await ref
                  .read(appStateControllerProvider.notifier)
                  .addWeightLog(
                    WeightLogModel(
                      id: '',
                      userId: profile.id,
                      petId: widget.petId,
                      weight: value,
                      loggedAt: DateTime.now(),
                      notes: _notes.text.trim(),
                    ),
                  );
              _weight.clear();
              _notes.clear();
            },
            icon: const Icon(Icons.monitor_weight_outlined),
            label: const Text('Guardar peso'),
          ),
          const SizedBox(height: 18),
          for (final log in logs.reversed)
            Card(
              child: ListTile(
                title: Text('${log.weight.toStringAsFixed(1)} kg'),
                subtitle: Text(log.notes),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.logs});

  final List<WeightLogModel> logs;

  @override
  Widget build(BuildContext context) {
    if (logs.length < 2) {
      return const Card(
        child: Center(
          child: Text('Anade al menos dos pesos para ver la grafica.'),
        ),
      );
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomPaint(
          painter: _WeightChartPainter(logs),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  _WeightChartPainter(this.logs);

  final List<WeightLogModel> logs;

  @override
  void paint(Canvas canvas, Size size) {
    final weights = logs.map((log) => log.weight).toList();
    final min = weights.reduce((a, b) => a < b ? a : b);
    final max = weights.reduce((a, b) => a > b ? a : b);
    final range = (max - min).abs() < 0.1 ? 1 : max - min;
    final paint = Paint()
      ..color = Colors.green
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;
    final path = Path();
    for (var i = 0; i < logs.length; i++) {
      final x = size.width * (i / (logs.length - 1));
      final y = size.height - ((logs[i].weight - min) / range * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) => true;
}
