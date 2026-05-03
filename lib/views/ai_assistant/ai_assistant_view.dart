import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/constants/app_copy.dart';
import '../../core/widgets/empty_state.dart';

class AiAssistantView extends ConsumerStatefulWidget {
  const AiAssistantView({super.key});

  @override
  ConsumerState<AiAssistantView> createState() => _AiAssistantViewState();
}

class _AiAssistantViewState extends ConsumerState<AiAssistantView> {
  String? _selectedPetId;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appStateControllerProvider);
    final pets = state.pets;

    return Scaffold(
      appBar: AppBar(title: const Text('Asistente IA')),
      body: pets.isEmpty
          ? const EmptyState(
              icon: Icons.auto_awesome,
              title: 'Necesitas una mascota',
              message: 'Crea una mascota antes de generar resumenes.',
            )
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedPetId ?? pets.first.id,
                  decoration: const InputDecoration(labelText: 'Mascota'),
                  items: pets
                      .map(
                        (pet) => DropdownMenuItem(
                          value: pet.id,
                          child: Text(pet.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedPetId = value),
                ),
                const SizedBox(height: 16),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(AppCopy.aiNotice),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loading ? null : _generate,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(
                    _loading ? 'Generando...' : 'Generate care summary',
                  ),
                ),
                const SizedBox(height: 18),
                if (_loading) const LinearProgressIndicator(),
                if (!_loading)
                  _SummaryCard(petId: _selectedPetId ?? pets.first.id),
              ],
            ),
    );
  }

  Future<void> _generate() async {
    final state = ref.read(appStateControllerProvider);
    if (state.pets.isEmpty) return;
    final petId = _selectedPetId ?? state.pets.first.id;
    setState(() => _loading = true);
    try {
      await ref.read(appStateControllerProvider.notifier).generateSummary(petId);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo generar el resumen ahora mismo.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _SummaryCard extends ConsumerWidget {
  const _SummaryCard({required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summary = ref.watch(appStateControllerProvider).summaries[petId];
    if (summary == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(18),
          child: Text('Aun no hay resumen para esta mascota.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Resumen', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(summary.summary),
            const Divider(height: 28),
            _ListBlock(title: 'Prioridades', items: summary.priorities),
            _ListBlock(
              title: 'Preguntas para el veterinario',
              items: summary.vetQuestions,
            ),
            _ListBlock(
              title: 'Recomendaciones generales',
              items: summary.generalRecommendations,
            ),
            Text(summary.safetyNotice),
          ],
        ),
      ),
    );
  }
}

class _ListBlock extends StatelessWidget {
  const _ListBlock({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        ...items.map((item) => Text('• $item')),
        const SizedBox(height: 14),
      ],
    );
  }
}
