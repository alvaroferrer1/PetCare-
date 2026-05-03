import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/utils/date_text.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/empty_state.dart';

class ActivityView extends ConsumerWidget {
  const ActivityView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateControllerProvider);
    final activity = buildActivityFeed(state);

    return Scaffold(
      appBar: AppBar(title: const Text('Actividad reciente')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Text(
            'Todo lo importante',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Mascotas, vacunas, notas, pesos, informes y alimentos consultados en un unico historial.',
          ),
          const SizedBox(height: 18),
          if (activity.isEmpty)
            const EmptyState(
              icon: Icons.history,
              title: 'Aun no hay actividad',
              message:
                  'Anade una mascota, registra un cuidado o consulta un alimento para empezar.',
            )
          else
            for (final entry in activity.take(40).indexed)
              AnimatedListItem(
                index: entry.$1,
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: entry.$2.color.withValues(alpha: 0.12),
                      child: Icon(entry.$2.icon, color: entry.$2.color),
                    ),
                    title: Text(entry.$2.title),
                    subtitle: Text(entry.$2.subtitle),
                    trailing: Text(formatShortDate(entry.$2.date)),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
