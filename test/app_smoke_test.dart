import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petcare_ai_companion/app.dart';
import 'package:petcare_ai_companion/core/config/app_config.dart';
import 'package:petcare_ai_companion/core/widgets/petcare_logo.dart';

void main() {
  testWidgets('muestra onboarding inicial', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            AppConfig(
              supabaseUrl: '',
              supabaseAnonKey: '',
              openAiApiKey: '',
              catApiKey: '',
            ),
          ),
        ],
        child: PetCareApp(),
      ),
    );

    expect(find.text('PetCare AI Companion'), findsOneWidget);
    expect(find.byType(PetCareLogo), findsOneWidget);
  });
}
