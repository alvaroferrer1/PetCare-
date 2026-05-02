import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/app_section.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/metric_card.dart';
import '../../models/care_event_model.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateControllerProvider);
    final pets = state.pets;
    final reminders = state.pendingEvents.take(4).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('PetCare'),
        actions: [
          IconButton(
            onPressed: () => context.go('/profile'),
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/pets/new'),
        icon: const Icon(Icons.add),
        label: const Text('Mascota'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(appStateControllerProvider.notifier).refreshRemoteData(),
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            _HeroHeader(petCount: pets.length),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    icon: Icons.pets,
                    label: 'Mascotas',
                    value: '${pets.length}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MetricCard(
                    icon: Icons.schedule,
                    label: 'Pendientes',
                    value: '${state.pendingEvents.length}',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MetricCard(
                    icon: Icons.note_alt_outlined,
                    label: 'Notas',
                    value: '${state.notes.length}',
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.event_available,
                    label: 'Recordatorios',
                    onTap: () => context.go('/reminders'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.restaurant_menu,
                    label: 'Food Safety',
                    onTap: () => context.go('/food'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.auto_awesome,
                    label: 'Asistente IA',
                    onTap: () => context.go('/assistant'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.verified_user_outlined,
                    label: 'Guia segura',
                    onTap: () => context.go('/resources'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            AppSection(
              title: 'Tus mascotas',
              child: pets.isEmpty
                  ? EmptyState(
                      icon: Icons.pets,
                      title: 'Aun no hay mascotas',
                      message: 'Crea tu primera mascota para empezar.',
                      action: FilledButton(
                        onPressed: () => context.go('/pets/new'),
                        child: const Text('Anadir mascota'),
                      ),
                    )
                  : Column(
                      children: [
                        for (final entry in pets.indexed)
                          AnimatedListItem(
                            index: entry.$1,
                            child: Card(
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: entry.$2.photoUrl == null
                                      ? null
                                      : NetworkImage(entry.$2.photoUrl!),
                                  child: entry.$2.photoUrl == null
                                      ? const Icon(Icons.pets)
                                      : null,
                                ),
                                title: Text(entry.$2.name),
                                subtitle: Text(
                                  '${entry.$2.species.label} · ${entry.$2.breed.isEmpty ? 'Raza sin definir' : entry.$2.breed}',
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => context.go('/pets/${entry.$2.id}'),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
            const SizedBox(height: 26),
            AppSection(
              title: 'Proximos recordatorios',
              child: reminders.isEmpty
                  ? const EmptyState(
                      icon: Icons.event_available,
                      title: 'Nada pendiente',
                      message: 'Los cuidados pendientes apareceran aqui.',
                    )
                  : Column(
                      children: [
                        for (final entry in reminders.indexed)
                          AnimatedListItem(
                            index: entry.$1,
                            child: _ReminderTile(event: entry.$2),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.petCount});

  final int petCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D6A4F), Color(0xFF40916C)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cuidados claros, mascotas mejor acompanadas',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '$petCount mascotas registradas',
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          const Icon(Icons.favorite, color: Colors.white, size: 48),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 10),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReminderTile extends ConsumerWidget {
  const _ReminderTile({required this.event});

  final CareEventModel event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(event.title),
        subtitle: Text(DateFormat.yMMMd('es').format(event.eventDate)),
        trailing: IconButton(
          icon: const Icon(Icons.check_circle_outline),
          onPressed: () => ref
              .read(appStateControllerProvider.notifier)
              .completeEvent(event.id),
        ),
      ),
    );
  }
}
