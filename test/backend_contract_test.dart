import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('schema Supabase contiene tablas, RLS y trigger de usuarios', () {
    final schema = File('supabase/schema.sql').readAsStringSync();
    final requiredTables = [
      'profiles',
      'pets',
      'care_events',
      'health_notes',
      'food_safety_items',
      'ai_summaries',
      'product_checks',
      'vet_contacts',
      'pet_documents',
      'weight_logs',
    ];

    for (final table in requiredTables) {
      expect(schema, contains('create table if not exists public.$table'));
      expect(
        schema,
        contains('alter table public.$table enable row level security'),
      );
    }
    expect(schema, contains('create trigger on_auth_user_created'));
    expect(schema, contains('barcode text default'));
    expect(schema, contains('image_url text default'));
  });

  test('seed incluye alimentos base para perros y gatos', () {
    final seed = File('supabase/seed.sql').readAsStringSync();

    for (final food in [
      'chocolate',
      'cebolla',
      'ajo',
      'uvas',
      'pasas',
      'leche',
      'atun con moderacion',
      'pollo cocido sin huesos',
      'arroz',
      'zanahoria',
      'calabaza',
    ]) {
      expect(seed, contains(food));
    }
    expect(seed, contains("'dog', 'toxic'"));
    expect(seed, contains("'cat', 'safe'"));
  });

  test('edge function exige JSON seguro y usa secreto del servidor', () {
    final function = File(
      'supabase/functions/generate-care-summary/index.ts',
    ).readAsStringSync();

    expect(function, contains('Deno.env.get("OPENAI_API_KEY")'));
    expect(function, contains('json_schema'));
    expect(function, contains('No diagnostiques'));
    expect(function, contains('no recomiendes medicamentos'));
    expect(function, contains('safety_notice'));
  });
}
