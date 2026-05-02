import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/app_state_controller.dart';
import '../views/ai_assistant/ai_assistant_view.dart';
import '../views/auth/auth_view.dart';
import '../views/care_events/care_event_form_view.dart';
import '../views/food_safety/food_safety_view.dart';
import '../views/health_notes/health_note_form_view.dart';
import '../views/home/home_view.dart';
import '../views/onboarding/onboarding_view.dart';
import '../views/pets/pet_detail_view.dart';
import '../views/pets/pet_form_view.dart';
import '../views/profile/profile_view.dart';
import '../views/reminders/reminders_view.dart';
import '../views/resources/resources_view.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final state = ref.watch(appStateControllerProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, routerState) {
      final location = routerState.uri.path;
      if (!state.onboardingDone && location != '/') return '/';
      if (state.onboardingDone &&
          !state.isAuthenticated &&
          location != '/auth') {
        return '/auth';
      }
      if (state.isAuthenticated && (location == '/' || location == '/auth')) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, __) => const OnboardingView()),
      GoRoute(path: '/auth', builder: (_, __) => const AuthView()),
      GoRoute(path: '/home', builder: (_, __) => const HomeView()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileView()),
      GoRoute(path: '/reminders', builder: (_, __) => const RemindersView()),
      GoRoute(path: '/resources', builder: (_, __) => const ResourcesView()),
      GoRoute(path: '/food', builder: (_, __) => const FoodSafetyView()),
      GoRoute(path: '/assistant', builder: (_, __) => const AiAssistantView()),
      GoRoute(path: '/pets/new', builder: (_, __) => const PetFormView()),
      GoRoute(
        path: '/pets/:id',
        builder: (_, state) =>
            PetDetailView(petId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/pets/:id/edit',
        builder: (_, state) => PetFormView(petId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/pets/:id/events/new',
        builder: (_, state) =>
            CareEventFormView(petId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/pets/:id/notes/new',
        builder: (_, state) =>
            HealthNoteFormView(petId: state.pathParameters['id']!),
      ),
    ],
  );
});
