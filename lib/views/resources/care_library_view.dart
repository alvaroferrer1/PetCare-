import 'package:flutter/material.dart';

import '../../core/constants/app_copy.dart';

class CareLibraryView extends StatelessWidget {
  const CareLibraryView({super.key});

  @override
  Widget build(BuildContext context) {
    const sections = [
      _LibrarySection(
        title: 'Vacunas',
        icon: Icons.vaccines_outlined,
        points: [
          'Registra fecha, nombre y estado.',
          'Marca como completada solo cuando se haya realizado.',
          'Guarda dudas para la visita veterinaria.',
        ],
      ),
      _LibrarySection(
        title: 'Medicacion',
        icon: Icons.medication_outlined,
        points: [
          'La app organiza recordatorios, no propone dosis.',
          'Anota solo indicaciones dadas por veterinario.',
          'Registra efectos observados sin diagnosticar.',
        ],
      ),
      _LibrarySection(
        title: 'Alimentacion',
        icon: Icons.restaurant_menu,
        points: [
          'Usa Food Safety para alimentos basicos.',
          'Usa productos para revisar ingredientes disponibles.',
          'Ante ingestion peligrosa, contacta con veterinario.',
        ],
      ),
      _LibrarySection(
        title: 'Salud diaria',
        icon: Icons.monitor_heart_outlined,
        points: [
          'Registra energia, apetito, animo y sintomas.',
          'Observa tendencias, no conclusiones medicas.',
          'Prepara preguntas claras para el veterinario.',
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Biblioteca de cuidados')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Guia rapida',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(AppCopy.veterinaryNotice),
          const SizedBox(height: 18),
          for (final section in sections) section,
        ],
      ),
    );
  }
}

class _LibrarySection extends StatelessWidget {
  const _LibrarySection({
    required this.title,
    required this.icon,
    required this.points,
  });

  final String title;
  final IconData icon;
  final List<String> points;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 10),
            for (final point in points)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(point)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
