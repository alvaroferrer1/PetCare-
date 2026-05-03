enum FoodSafetyLevel {
  safe('Seguro'),
  caution('Precaucion'),
  toxic('Toxico'),
  unknown('Desconocido');

  const FoodSafetyLevel(this.label);
  final String label;

  static FoodSafetyLevel fromDb(String value) =>
      FoodSafetyLevel.values.firstWhere(
        (item) => item.name == value,
        orElse: () => FoodSafetyLevel.unknown,
      );
}

class FoodSafetyItemModel {
  const FoodSafetyItemModel({
    required this.id,
    required this.foodName,
    required this.normalizedName,
    required this.species,
    required this.safetyLevel,
    required this.description,
    required this.source,
  });

  final String id;
  final String foodName;
  final String normalizedName;
  final String species;
  final FoodSafetyLevel safetyLevel;
  final String description;
  final String source;

  factory FoodSafetyItemModel.unknown(String query, String species) {
    return FoodSafetyItemModel(
      id: 'unknown',
      foodName: query,
      normalizedName: normalizeFoodName(query),
      species: species,
      safetyLevel: FoodSafetyLevel.unknown,
      description:
          'No tenemos este alimento en la base curada. No lo consideres seguro hasta consultarlo con una fuente veterinaria fiable.',
      source: 'Base local sin coincidencia',
    );
  }

  factory FoodSafetyItemModel.fromMap(Map<String, dynamic> map) {
    return FoodSafetyItemModel(
      id: map['id'] as String,
      foodName: map['food_name'] as String,
      normalizedName: map['normalized_name'] as String,
      species: map['species'] as String,
      safetyLevel: FoodSafetyLevel.fromDb(map['safety_level'] as String),
      description: (map['description'] ?? '') as String,
      source: (map['source'] ?? '') as String,
    );
  }
}

String normalizeFoodName(String value) {
  return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
