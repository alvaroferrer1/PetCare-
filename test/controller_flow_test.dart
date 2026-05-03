import 'package:flutter_test/flutter_test.dart';
import 'package:petcare_ai_companion/controllers/app_state_controller.dart';
import 'package:petcare_ai_companion/core/config/app_config.dart';
import 'package:petcare_ai_companion/models/ai_summary_model.dart';
import 'package:petcare_ai_companion/models/care_event_model.dart';
import 'package:petcare_ai_companion/models/food_safety_item_model.dart';
import 'package:petcare_ai_companion/models/health_note_model.dart';
import 'package:petcare_ai_companion/models/pet_document_model.dart';
import 'package:petcare_ai_companion/models/pet_model.dart';
import 'package:petcare_ai_companion/models/product_check_model.dart';
import 'package:petcare_ai_companion/models/vet_contact_model.dart';
import 'package:petcare_ai_companion/models/weight_log_model.dart';

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

  test('dos sesiones locales mantienen datos separados', () async {
    final firstUser = AppStateController(demoConfig);
    final secondUser = AppStateController(demoConfig);
    await firstUser.signIn('uno@petcare.app', 'demopass');
    await secondUser.signIn('dos@petcare.app', 'demopass');

    await firstUser.savePet(PetModel.empty('demo-user').copyWith(name: 'Max'));
    await secondUser.savePet(
      PetModel.empty('demo-user').copyWith(name: 'Nala'),
    );

    expect(firstUser.state.pets.single.name, 'Max');
    expect(secondUser.state.pets.single.name, 'Nala');
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

  test('guarda contactos, documentos y pesos en modo local', () async {
    final controller = AppStateController(demoConfig);
    await controller.signIn('demo@petcare.app', 'demopass');
    await controller.savePet(
      PetModel.empty('demo-user').copyWith(name: 'Nala', allergies: 'pollo'),
    );
    final pet = controller.state.pets.first;
    final now = DateTime.now();

    await controller.saveVetContact(
      const VetContactModel(
        id: '',
        userId: 'demo-user',
        name: 'Dra. Ruiz',
        clinic: 'Clinica Centro',
        phone: '600000000',
        notes: '',
        isEmergency: true,
      ),
    );
    await controller.addDocument(
      PetDocumentModel(
        id: '',
        userId: 'demo-user',
        petId: pet.id,
        title: 'Cartilla',
        documentType: 'vaccine_card',
        fileUrl: '',
        notes: '',
        createdAt: now,
      ),
    );
    await controller.addWeightLog(
      WeightLogModel(
        id: '',
        userId: 'demo-user',
        petId: pet.id,
        weight: 4.8,
        loggedAt: now,
        notes: 'Control',
      ),
    );

    expect(controller.state.vetContacts, hasLength(1));
    expect(controller.state.documents, hasLength(1));
    expect(controller.state.weightLogs.first.weight, 4.8);
  });

  test('actividad reciente agrupa acciones clave del cuidado', () {
    final now = DateTime.now();
    final pet = PetModel.empty('demo-user').copyWith(
      id: 'pet-1',
      name: 'Nala',
      createdAt: now.subtract(const Duration(days: 4)),
    );
    final state = AppState.initial().copyWith(
      pets: [pet],
      events: [
        _event(
          pet.id,
          'Rabia',
          now.subtract(const Duration(days: 1)),
        ).copyWith(status: CareEventStatus.completed, updatedAt: now),
      ],
      notes: [
        HealthNoteModel(
          id: 'note-1',
          userId: 'demo-user',
          petId: pet.id,
          symptoms: 'Tos',
          mood: 'Normal',
          appetite: 'Bien',
          energyLevel: 3,
          notes: '',
          noteDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      ],
      weightLogs: [
        WeightLogModel(
          id: 'weight-1',
          userId: 'demo-user',
          petId: pet.id,
          weight: 4.8,
          loggedAt: now,
          notes: '',
        ),
      ],
      summaries: {
        pet.id: AiSummaryModel(
          summary: 'Resumen',
          priorities: const [],
          vetQuestions: const [],
          generalRecommendations: const [],
          safetyNotice: 'Aviso',
          createdAt: now,
        ),
      },
      productChecks: [
        ProductCheckModel(
          query: 'chocolate',
          species: 'dog',
          productName: 'chocolate',
          ingredients: 'chocolate',
          barcode: '',
          imageUrl: '',
          matchedRisks: const [],
          source: 'test',
          createdAt: now,
        ),
      ],
    );

    final titles = buildActivityFeed(state).map((item) => item.title);

    expect(titles, contains('Mascota creada'));
    expect(titles, contains('Vacuna completada'));
    expect(titles, contains('Nota de salud añadida'));
    expect(titles, contains('Peso registrado'));
    expect(titles, contains('Informe generado'));
    expect(titles, contains('Alimento consultado'));
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
