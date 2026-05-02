import 'package:flutter_test/flutter_test.dart';
import 'package:petcare_ai_companion/controllers/app_state_controller.dart';
import 'package:petcare_ai_companion/models/care_event_model.dart';
import 'package:petcare_ai_companion/models/food_safety_item_model.dart';
import 'package:petcare_ai_companion/models/pet_model.dart';

void main() {
  group('Food Safety', () {
    test('normaliza nombres de alimentos', () {
      expect(normalizeFoodName('  Cooked   Chicken  '), 'cooked chicken');
    });

    test('seed contiene alimentos toxicos para perros y gatos', () {
      final dogChocolate = FoodSafetySeed.items.firstWhere(
        (item) => item.species == 'dog' && item.normalizedName == 'chocolate',
      );
      final catOnion = FoodSafetySeed.items.firstWhere(
        (item) => item.species == 'cat' && item.normalizedName == 'onion',
      );

      expect(dogChocolate.safetyLevel, FoodSafetyLevel.toxic);
      expect(catOnion.safetyLevel, FoodSafetyLevel.toxic);
    });

    test('seed incluye alimentos comunes en espanol', () {
      final dogRice = FoodSafetySeed.items.firstWhere(
        (item) => item.species == 'dog' && item.normalizedName == 'arroz',
      );
      final catMilk = FoodSafetySeed.items.firstWhere(
        (item) => item.species == 'cat' && item.normalizedName == 'leche',
      );

      expect(dogRice.safetyLevel, FoodSafetyLevel.safe);
      expect(catMilk.safetyLevel, FoodSafetyLevel.caution);
    });
  });

  group('Modelos', () {
    test('PetModel serializa species correctamente', () {
      final now = DateTime(2026);
      final pet = PetModel(
        id: 'pet-1',
        userId: 'user-1',
        name: 'Luna',
        species: PetSpecies.cat,
        breed: 'Siamese',
        birthDate: null,
        weight: 4.2,
        photoUrl: null,
        notes: 'Tranquila',
        createdAt: now,
        updatedAt: now,
      );

      expect(pet.toMap()['species'], 'cat');
      expect(pet.toMap()['name'], 'Luna');
    });

    test('CareEventType convierte vetVisit a valor de base de datos', () {
      expect(CareEventType.vetVisit.dbValue, 'vet_visit');
      expect(CareEventType.fromDb('vet_visit'), CareEventType.vetVisit);
    });
  });
}
