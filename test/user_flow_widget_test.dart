import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}
