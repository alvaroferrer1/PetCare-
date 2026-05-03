import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'controllers/app_state_controller.dart';
import 'core/theme/app_theme.dart';
import 'views/auth/auth_view.dart';
import 'views/home/home_view.dart';
import 'views/onboarding/onboarding_view.dart';

class PetCareApp extends ConsumerWidget {
  const PetCareApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateControllerProvider);
    final screen = !state.onboardingDone
        ? const OnboardingView()
        : state.isAuthenticated
            ? const HomeView()
            : const AuthView();

    return MaterialApp(
      title: 'PetCare AI Companion',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey('${state.onboardingDone}-${state.isAuthenticated}'),
          child: screen,
        ),
      ),
    );
  }
}
