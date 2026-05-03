import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  const runRealSupabaseTests = bool.fromEnvironment('RUN_SUPABASE_REAL_TESTS');

  test(
    'flujo real Supabase: registro, login, mascota, food safety, evento e IA',
    () async {
      await dotenv.load(fileName: '.env');
      final url = dotenv.env['SUPABASE_URL'] ?? '';
      final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
      expect(url, isNotEmpty);
      expect(anonKey, isNotEmpty);

      SharedPreferences.setMockInitialValues({});
      await Supabase.initialize(url: url, anonKey: anonKey);
      final client = Supabase.instance.client;
      final stamp = DateTime.now().microsecondsSinceEpoch;
      final email = 'petcare.test.$stamp@gmail.com';
      const password = 'PetCareTest123!';

      AuthResponse signUp;
      try {
        signUp = await client.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': 'Test PetCare'},
        );
      } catch (error) {
        expect(error.toString(), contains('over_email_send_rate_limit'));
        return;
      }
      expect(signUp.user, isNotNull);

      await client.auth.signOut();
      User? user;
      try {
        final signIn = await client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        user = signIn.user;
      } catch (error) {
        expect(error.toString(), contains('email_not_confirmed'));
        return;
      }
      expect(user, isNotNull);

      await client.from('profiles').upsert({
        'id': user!.id,
        'email': email,
        'full_name': 'Test PetCare',
      });

      final petRows = await client.from('pets').insert({
        'user_id': user.id,
        'name': 'Demo QA',
        'species': 'dog',
        'breed': 'beagle',
        'weight': 12.5,
      }).select();
      expect(petRows, isNotEmpty);
      final petId = petRows.first['id'] as String;

      final foodRows = await client
          .from('food_safety_items')
          .select('food_name,safety_level')
          .eq('species', 'dog')
          .eq('normalized_name', 'chocolate');
      expect(foodRows.first['safety_level'], 'toxic');

      final eventRows = await client.from('care_events').insert({
        'user_id': user.id,
        'pet_id': petId,
        'type': 'vaccine',
        'title': 'Vacuna test',
        'event_date': DateTime.now().toIso8601String(),
        'status': 'pending',
      }).select();
      expect(eventRows, isNotEmpty);

      final ai = await client.functions.invoke(
        'generate-care-summary',
        body: {
          'pet': {'id': petId, 'name': 'Demo QA', 'species': 'dog'},
          'recent_events': eventRows,
          'health_notes': [],
          'pending_reminders': eventRows,
        },
      );
      expect(ai.data, isA<Map>());
      expect((ai.data as Map)['safety_notice'], isNotNull);
    },
    skip: runRealSupabaseTests
        ? null
        : 'Opt-in: ejecutar con --dart-define=RUN_SUPABASE_REAL_TESTS=true',
  );
}
