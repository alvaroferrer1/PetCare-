import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/food_safety_item_model.dart';

class DogFoodApiService {
  DogFoodApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<FoodSafetyItemModel?> search(String foodName) async {
    final normalized = normalizeFoodName(foodName);
    if (normalized.isEmpty) return null;

    try {
      final response = await _client.get(
        Uri.parse('https://dog-food-api.onrender.com/api/$normalized'),
      );
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final toxic = (data['toxic'] ?? '').toString().toLowerCase();
      final safe = (data['safe'] ?? data['dafe'] ?? '')
          .toString()
          .toLowerCase();
      final level = toxic.contains('yes') || toxic.contains('true')
          ? FoodSafetyLevel.toxic
          : safe.contains('yes') || safe.contains('true')
          ? FoodSafetyLevel.safe
          : FoodSafetyLevel.caution;

      return FoodSafetyItemModel(
        id: 'dog-food-api-$normalized',
        foodName: (data['name'] ?? foodName).toString(),
        normalizedName: normalized,
        species: 'dog',
        safetyLevel: level,
        description: (data['obs'] ?? 'Resultado externo de Dog Food API.')
            .toString(),
        source: 'Dog Food API - https://github.com/NicoletaSerban/dogFoodApi',
      );
    } catch (_) {
      return null;
    }
  }
}
