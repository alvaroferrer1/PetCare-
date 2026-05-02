import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petcare_ai_companion/app.dart';
import 'package:petcare_ai_companion/core/config/app_config.dart';

void main() {
  testWidgets('flujo visual onboarding login y food safety', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(
              supabaseUrl: '',
              supabaseAnonKey: '',
              openAiApiKey: '',
              catApiKey: '',
            ),
          ),
        ],
        child: const PetCareApp(),
      ),
    );

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('Bienvenido de nuevo'), findsOneWidget);

    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('PetCare'), findsOneWidget);

    await tester.tap(find.text('Food Safety'));
    await tester.pumpAndSettle();

    expect(find.text('Busca antes de compartir comida'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'arroz');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    expect(find.text('Seguro'), findsWidgets);
  });

  testWidgets('home navega a recordatorios y guia segura', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(
              supabaseUrl: '',
              supabaseAnonKey: '',
              openAiApiKey: '',
              catApiKey: '',
            ),
          ),
        ],
        child: const PetCareApp(),
      ),
    );

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Recordatorios'));
    await tester.pumpAndSettle();
    expect(find.text('Plan de cuidados'), findsOneWidget);

    final context = tester.element(find.text('Plan de cuidados'));
    GoRouter.of(context).go('/home');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guia segura'));
    await tester.pumpAndSettle();
    expect(find.text('Centro de confianza'), findsOneWidget);
  });

  testWidgets('home navega a analisis de producto', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(
              supabaseUrl: '',
              supabaseAnonKey: '',
              openAiApiKey: '',
              catApiKey: '',
            ),
          ),
        ],
        child: const PetCareApp(),
      ),
    );

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -500));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Analizar producto'));
    await tester.pumpAndSettle();

    expect(find.text('Producto e ingredientes'), findsOneWidget);
  });

  testWidgets('registro valida email, nombre y contrasena', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(
              supabaseUrl: '',
              supabaseAnonKey: '',
              openAiApiKey: '',
              catApiKey: '',
            ),
          ),
        ],
        child: const PetCareApp(),
      ),
    );

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No tengo cuenta, registrarme'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre completo'),
      '1234',
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'mal');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Contrasena'),
      '123',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirmar contrasena'),
      '456',
    );
    await tester.tap(find.text('Registrarme'));
    await tester.pumpAndSettle();

    expect(find.text('El nombre no puede ser solo numeros.'), findsOneWidget);
    expect(find.text('Introduce un email valido.'), findsOneWidget);
    expect(
      find.text('La contrasena debe tener minimo 8 caracteres.'),
      findsOneWidget,
    );
    expect(find.text('Las contrasenas no coinciden.'), findsOneWidget);
  });
}
