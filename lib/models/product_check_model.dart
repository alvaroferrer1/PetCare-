import 'food_safety_item_model.dart';

class ProductCheckModel {
  const ProductCheckModel({
    required this.query,
    required this.species,
    required this.productName,
    required this.ingredients,
    required this.barcode,
    required this.imageUrl,
    required this.matchedRisks,
    required this.source,
    required this.createdAt,
  });

  final String query;
  final String species;
  final String productName;
  final String ingredients;
  final String barcode;
  final String imageUrl;
  final List<FoodSafetyItemModel> matchedRisks;
  final String source;
  final DateTime createdAt;

  bool get hasRisks => matchedRisks.isNotEmpty;

  FoodSafetyLevel get highestLevel {
    if (matchedRisks.any((item) => item.safetyLevel == FoodSafetyLevel.toxic)) {
      return FoodSafetyLevel.toxic;
    }
    if (matchedRisks.any(
      (item) => item.safetyLevel == FoodSafetyLevel.caution,
    )) {
      return FoodSafetyLevel.caution;
    }
    return FoodSafetyLevel.unknown;
  }

  factory ProductCheckModel.fromMap(Map<String, dynamic> map) {
    final risks = map['matched_risks'] as List<dynamic>? ?? const [];
    return ProductCheckModel(
      query: (map['query'] ?? '') as String,
      species: (map['species'] ?? 'dog') as String,
      productName: (map['product_name'] ?? '') as String,
      ingredients: (map['ingredients'] ?? '') as String,
      barcode: (map['barcode'] ?? '') as String,
      imageUrl: (map['image_url'] ?? '') as String,
      matchedRisks: risks
          .whereType<Map>()
          .map(
            (item) => FoodSafetyItemModel(
              id: '',
              foodName: (item['food_name'] ?? '') as String,
              normalizedName: normalizeFoodName(
                (item['food_name'] ?? '') as String,
              ),
              species: (map['species'] ?? 'dog') as String,
              safetyLevel: FoodSafetyLevel.values.firstWhere(
                (level) => level.name == item['safety_level'],
                orElse: () => FoodSafetyLevel.unknown,
              ),
              description: (item['description'] ?? '') as String,
              source: (item['source'] ?? '') as String,
            ),
          )
          .toList(),
      source: (map['source'] ?? '') as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}
