import 'food_safety_item_model.dart';

class ProductCheckModel {
  const ProductCheckModel({
    required this.query,
    required this.productName,
    required this.ingredients,
    required this.matchedRisks,
    required this.source,
  });

  final String query;
  final String productName;
  final String ingredients;
  final List<FoodSafetyItemModel> matchedRisks;
  final String source;

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
}
