import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:petcare_ai_companion/app.dart';
import 'package:petcare_ai_companion/core/config/app_config.dart';
import 'package:petcare_ai_companion/models/care_event_model.dart';
import 'package:petcare_ai_companion/views/activity/activity_view.dart';
import 'package:petcare_ai_companion/views/analytics/analytics_view.dart';
import 'package:petcare_ai_companion/views/care_events/care_type_overview_view.dart';
import 'package:petcare_ai_companion/views/emergency/emergency_view.dart';
import 'package:petcare_ai_companion/views/product_check/product_check_view.dart';
import 'package:petcare_ai_companion/views/reminders/reminders_view.dart';
import 'package:petcare_ai_companion/views/resources/resources_view.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('es');
  });

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

    expect(find.text('Historial y control'), findsNothing);
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('Historial y control'), findsOneWidget);

    await tester.tap(find.text('Saltar'));
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

  testWidgets('modo demo carga mascotas y recordatorios para la grabacion', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(
            const AppConfig(
              supabaseUrl: 'https://demo.supabase.co',
              supabaseAnonKey: 'demo-key',
              openAiApiKey: '',
              catApiKey: '',
            ),
          ),
        ],
        child: const PetCareApp(),
      ),
    );

    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar en demo para video'));
    await tester.pumpAndSettle();

    expect(find.text('PetCare'), findsOneWidget);
    expect(find.text('2'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Luna'),
      420,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Luna'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text('Recordatorio vacuna rabia'),
      420,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Recordatorio vacuna rabia'), findsOneWidget);
  });

  testWidgets('pantallas de recordatorios y guia segura renderizan', (
    tester,
  ) async {
    await _pumpScreen(tester, const RemindersView());
    expect(find.text('Plan de cuidados'), findsOneWidget);

    await _pumpScreen(tester, const ResourcesView());
    expect(find.text('Centro de confianza'), findsOneWidget);
  });

  testWidgets('pantalla de analisis de producto renderiza', (tester) async {
    await _pumpScreen(tester, const ProductCheckView());
    expect(find.text('Producto e ingredientes'), findsOneWidget);
  });

  testWidgets('pantalla de actividad reciente renderiza', (tester) async {
    await _pumpScreen(tester, const ActivityView());
    expect(find.text('Actividad reciente'), findsOneWidget);
    expect(find.text('Todo lo importante'), findsOneWidget);
  });

  testWidgets('pantalla de vacunas renderiza', (tester) async {
    await _pumpScreen(
      tester,
      const CareTypeOverviewView(
        type: CareEventType.vaccine,
        title: 'Vacunas',
        emptyTitle: 'Sin vacunas registradas',
        emptyMessage: 'Crea la primera vacuna para controlar fechas y estado.',
      ),
    );
    expect(find.text('Vacunas'), findsWidgets);
  });

  testWidgets('pantallas de emergencia y estadisticas renderizan', (
    tester,
  ) async {
    await _pumpScreen(tester, const EmergencyView());
    expect(find.text('Actua con calma'), findsOneWidget);

    await _pumpScreen(tester, const AnalyticsView());
    expect(find.text('Resumen global'), findsOneWidget);
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

    await tester.tap(find.text('Saltar'));
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

Future<void> _pumpScreen(WidgetTester tester, Widget child) async {
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
      child: MaterialApp(home: child),
    ),
  );
  await tester.pump();
}
