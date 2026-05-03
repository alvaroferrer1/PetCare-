import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../controllers/app_state_controller.dart';
import '../../core/constants/app_copy.dart';
import '../../core/widgets/petcare_logo.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  final _controller = PageController();
  int _page = 0;

  static const _slides = [
    _OnboardingSlide(
      icon: Icons.pets,
      title: 'PetCare AI Companion',
      text:
          'Centraliza mascotas, vacunas, visitas, notas de salud y recordatorios en un unico panel.',
    ),
    _OnboardingSlide(
      icon: Icons.event_available,
      title: 'Historial y control',
      text:
          'Cada mascota tiene eventos, filtros por estado, timeline, peso, documentos e informes para el veterinario.',
    ),
    _OnboardingSlide(
      icon: Icons.restaurant_menu,
      title: 'Alimentos y productos',
      text:
          'Consulta alimentos seguros, con precaucion o toxicos y analiza productos reales con Open Pet Food Facts.',
    ),
    _OnboardingSlide(
      icon: Icons.auto_awesome,
      title: 'IA responsable',
      text:
          'Genera resumenes de cuidados, prioridades y preguntas utiles sin diagnosticar ni sustituir al veterinario.',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('Saltar'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) =>
                      _SlidePage(slide: _slides[index], showLogo: index == 0),
                ),
              ),
              const SizedBox(height: 18),
              const _NoticeCard(),
              const SizedBox(height: 18),
              Row(
                children: [
                  for (var index = 0; index < _slides.length; index++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: _page == index ? 28 : 9,
                      height: 9,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: _page == index
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  const Spacer(),
                  SizedBox(
                    width: 150,
                    child: FilledButton.icon(
                      onPressed: _page == _slides.length - 1 ? _finish : _next,
                      icon: Icon(
                        _page == _slides.length - 1
                            ? Icons.check
                            : Icons.arrow_forward,
                      ),
                      label: Text(
                        _page == _slides.length - 1 ? 'Empezar' : 'Siguiente',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _next() {
    _controller.nextPage(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() {
    ref.read(appStateControllerProvider.notifier).completeOnboarding();
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;
}

class _SlidePage extends StatelessWidget {
  const _SlidePage({required this.slide, required this.showLogo});

  final _OnboardingSlide slide;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 520),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 22 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showLogo) ...[
            const PetCareLogo(),
            const SizedBox(height: 28),
          ] else ...[
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                slide.icon,
                size: 42,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 28),
          ],
          Text(
            slide.title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 16),
          Text(slide.text, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.health_and_safety_outlined),
            SizedBox(width: 12),
            Expanded(child: Text(AppCopy.aiNotice)),
          ],
        ),
      ),
    );
  }
}
