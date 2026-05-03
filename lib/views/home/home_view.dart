import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/navigation/safe_navigation.dart';
import '../../core/utils/date_text.dart';
import '../../core/widgets/animated_list_item.dart';
import '../../core/widgets/app_section.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/metric_card.dart';
import '../../models/care_event_model.dart';
import '../activity/activity_view.dart';
import '../ai_assistant/ai_assistant_view.dart';
import '../analytics/analytics_view.dart';
import '../calendar/calendar_view.dart';
import '../care_events/care_type_overview_view.dart';
import '../emergency/emergency_view.dart';
import '../food_safety/food_safety_view.dart';
import '../health/recent_health_view.dart';
import '../pets/pet_detail_view.dart';
import '../pets/pet_form_view.dart';
import '../product_check/product_check_view.dart';
import '../profile/profile_view.dart';
import '../reminders/reminders_view.dart';
import '../reports/vet_visit_prep_view.dart';
import '../resources/care_library_view.dart';
import '../resources/resources_view.dart';
import '../vet_contacts/vet_contacts_view.dart';

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
            onPressed: () => context.openScreen(const ProfileView()),
            icon: const Icon(Icons.person_outline),
            tooltip: 'Perfil',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.openScreen(const PetFormView()),
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
                    onTap: () => context.openScreen(const RemindersView()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.restaurant_menu,
                    label: 'Food Safety',
                    onTap: () => context.openScreen(const FoodSafetyView()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.emergency_outlined,
                    label: 'Emergencia',
                    onTap: () => context.openScreen(const EmergencyView()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.bar_chart,
                    label: 'Estadisticas',
                    onTap: () => context.openScreen(const AnalyticsView()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.menu_book_outlined,
                    label: 'Biblioteca',
                    onTap: () => context.openScreen(const CareLibraryView()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.fact_check_outlined,
                    label: 'Visita vet',
                    onTap: () => context.openScreen(const VetVisitPrepView()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.calendar_month,
                    label: 'Calendario',
                    onTap: () => context.openScreen(const CalendarView()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.monitor_heart_outlined,
                    label: 'Salud reciente',
                    onTap: () => context.openScreen(const RecentHealthView()),
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
                    onTap: () => context.openScreen(const AiAssistantView()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.verified_user_outlined,
                    label: 'Guia segura',
                    onTap: () => context.openScreen(const ResourcesView()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.qr_code_scanner,
                    label: 'Analizar producto',
                    onTap: () => context.openScreen(const ProductCheckView()),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.local_hospital_outlined,
                    label: 'Veterinarios',
                    onTap: () => context.openScreen(const VetContactsView()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.history,
                    label: 'Actividad',
                    onTap: () => context.openScreen(const ActivityView()),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: SizedBox.shrink()),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.vaccines_outlined,
                    label: 'Vacunas',
                    onTap: () => context.openScreen(
                      const CareTypeOverviewView(
                        type: CareEventType.vaccine,
                        title: 'Vacunas',
                        emptyTitle: 'Sin vacunas registradas',
                        emptyMessage:
                            'Crea la primera vacuna para controlar fechas y estado.',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.medication_outlined,
                    label: 'Medicacion',
                    onTap: () => context.openScreen(
                      const CareTypeOverviewView(
                        type: CareEventType.medication,
                        title: 'Medicacion',
                        emptyTitle: 'Sin medicacion',
                        emptyMessage:
                            'Registra medicaciones sin dosis automatizadas ni diagnostico.',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: Icons.restaurant,
                    label: 'Alimentacion',
                    onTap: () => context.openScreen(
                      const CareTypeOverviewView(
                        type: CareEventType.food,
                        title: 'Alimentacion',
                        emptyTitle: 'Sin rutinas de alimentacion',
                        emptyMessage:
                            'Anade rutinas o cambios de comida para llevar seguimiento.',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: Icons.content_cut,
                    label: 'Higiene',
                    onTap: () => context.openScreen(
                      const CareTypeOverviewView(
                        type: CareEventType.grooming,
                        title: 'Higiene',
                        emptyTitle: 'Sin cuidados de higiene',
                        emptyMessage:
                            'Controla peluqueria, banos y cuidados periodicos.',
                      ),
                    ),
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
                      message:
                          'Empieza con una mascota y la app te guiara para registrar sus primeros cuidados.',
                      action: Column(
                        children: [
                          FilledButton.icon(
                            onPressed: () =>
                                context.openScreen(const PetFormView()),
                            icon: const Icon(Icons.add),
                            label: const Text('Anade tu primera mascota'),
                          ),
                          const SizedBox(height: 12),
                          const _NextSteps(),
                        ],
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
                                onTap: () =>
                                    context.openScreen(
                                      PetDetailView(petId: entry.$2.id),
                                    ),
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

class _NextSteps extends StatelessWidget {
  const _NextSteps();

  @override
  Widget build(BuildContext context) {
    const steps = [
      'Crea su primera vacuna',
      'Registra su peso inicial',
      'Anade veterinario de emergencia',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final step in steps)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline, size: 18),
                const SizedBox(width: 8),
                Flexible(child: Text(step)),
              ],
            ),
          ),
      ],
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
        subtitle: Text(formatReadableDate(event.eventDate)),
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
