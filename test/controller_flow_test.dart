import 'package:flutter_test/flutter_test.dart';
import 'package:petcare_ai_companion/controllers/app_state_controller.dart';
import 'package:petcare_ai_companion/core/config/app_config.dart';
import 'package:petcare_ai_companion/models/care_event_model.dart';
import 'package:petcare_ai_companion/models/food_safety_item_model.dart';
import 'package:petcare_ai_companion/models/health_note_model.dart';
import 'package:petcare_ai_companion/models/pet_model.dart';

void main() {
  const demoConfig = AppConfig(
    supabaseUrl: '',
    supabaseAnonKey: '',
    openAiApiKey: '',
    catApiKey: '',
  );

  test(
    'auth local activa perfil demo si Supabase no esta configurado',
    () async {
      final controller = AppStateController(demoConfig);

      await controller.signIn('demo@petcare.app', 'demopass');

      expect(controller.state.isAuthenticated, isTrue);
      expect(controller.state.profile?.id, 'demo-user');
    },
  );

  test('crear mascota en modo local la anade al estado', () async {
    final controller = AppStateController(demoConfig);
    await controller.signIn('demo@petcare.app', 'demopass');

    await controller.savePet(
      PetModel.empty(
        'demo-user',
      ).copyWith(name: 'Nala', species: PetSpecies.cat, breed: 'Comun europeo'),
    );

    expect(controller.state.pets, hasLength(1));
    expect(controller.state.pets.first.name, 'Nala');
  });

  test('recordatorios pendientes se ordenan por fecha', () async {
    final controller = AppStateController(demoConfig);
    await controller.signIn('demo@petcare.app', 'demopass');
    await controller.savePet(PetModel.empty('demo-user').copyWith(name: 'Max'));
    final pet = controller.state.pets.first;

    await controller.addEvent(_event(pet.id, 'Revision', DateTime(2026, 5, 6)));
    await controller.addEvent(_event(pet.id, 'Vacuna', DateTime(2026, 5, 3)));

    expect(controller.state.pendingEvents.first.title, 'Vacuna');
  });

  test('marcar evento como completado lo quita de pendientes', () async {
    final controller = AppStateController(demoConfig);
    await controller.signIn('demo@petcare.app', 'demopass');
    await controller.savePet(PetModel.empty('demo-user').copyWith(name: 'Max'));
    final pet = controller.state.pets.first;
    await controller.addEvent(_event(pet.id, 'Vacuna', DateTime(2026, 5, 3)));

    await controller.completeEvent(controller.state.events.first.id);

    expect(controller.state.pendingEvents, isEmpty);
    expect(controller.state.events.first.status, CareEventStatus.completed);
  });

  test('guardar nota de salud conserva energia y sintomas', () async {
    final controller = AppStateController(demoConfig);
    await controller.signIn('demo@petcare.app', 'demopass');
    await controller.savePet(
      PetModel.empty('demo-user').copyWith(name: 'Luna'),
    );
    final pet = controller.state.pets.first;
    final now = DateTime.now();

    await controller.addNote(
      HealthNoteModel(
        id: '',
        userId: 'demo-user',
        petId: pet.id,
        symptoms: 'Tos leve',
        mood: 'Normal',
        appetite: 'Bien',
        energyLevel: 4,
        notes: 'Observar evolucion',
        noteDate: now,
        createdAt: now,
        updatedAt: now,
      ),
    );

    expect(controller.state.notes.first.symptoms, 'Tos leve');
    expect(controller.state.notes.first.energyLevel, 4);
  });

  test('food safety devuelve unknown cuando no hay coincidencia', () {
    final controller = AppStateController(demoConfig);

    final result = controller.searchFood('pan raro', 'dog');

    expect(result.safetyLevel, FoodSafetyLevel.unknown);
  });

  test('food safety encuentra coincidencias exactas en espanol', () {
    final controller = AppStateController(demoConfig);

    final toxic = controller.searchFood('cebolla', 'cat');
    final safe = controller.searchFood('arroz', 'dog');

    expect(toxic.safetyLevel, FoodSafetyLevel.toxic);
    expect(safe.safetyLevel, FoodSafetyLevel.safe);
  });

  test(
    'food safety para gatos desconocido no llama fuente externa de perros',
    () async {
      final controller = AppStateController(demoConfig);

      final result = await controller.searchFoodWithExternalFallback(
        'comida inventada',
        'cat',
      );

      expect(result.safetyLevel, FoodSafetyLevel.unknown);
      expect(result.source, 'Base local sin coincidencia');
    },
  );

  test('guardar perfil actualiza datos del dueno en modo local', () async {
    final controller = AppStateController(demoConfig);
    await controller.signIn('demo@petcare.app', 'demopass');

    await controller.saveProfile(
      controller.state.profile!.copyWith(
        fullName: 'Alvaro Ferrer',
        emergencyVetName: 'Clinica Central',
      ),
    );

    expect(controller.state.profile?.fullName, 'Alvaro Ferrer');
    expect(controller.state.profile?.emergencyVetName, 'Clinica Central');
  });

  test('resumen IA local incluye aviso de seguridad', () async {
    final controller = AppStateController(demoConfig);
    await controller.signIn('demo@petcare.app', 'demopass');
    await controller.savePet(PetModel.empty('demo-user').copyWith(name: 'Max'));

    final summary = await controller.generateSummary(
      controller.state.pets.first.id,
    );

    expect(summary.summary, contains('Max'));
    expect(summary.safetyNotice, isNotEmpty);
  });

  test('analisis de producto detecta ingredientes de riesgo locales', () async {
    final controller = AppStateController(demoConfig);

    final result = await controller.checkProductIngredients(
      'chocolate, arroz',
      'dog',
    );

    expect(
      result.matchedRisks.any((item) => item.foodName == 'chocolate'),
      isTrue,
    );
    expect(result.highestLevel, FoodSafetyLevel.toxic);
  });
}

CareEventModel _event(String petId, String title, DateTime date) {
  final now = DateTime.now();
  return CareEventModel(
    id: '',
    userId: 'demo-user',
    petId: petId,
    type: CareEventType.vaccine,
    title: title,
    description: '',
    eventDate: date,
    status: CareEventStatus.pending,
    createdAt: now,
    updatedAt: now,
  );
}
