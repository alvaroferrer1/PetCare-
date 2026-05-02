import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenFoodFactsProduct {
  const OpenFoodFactsProduct({
    required this.name,
    required this.ingredientsText,
  });

  final String name;
  final String ingredientsText;
}

class OpenFoodFactsService {
  OpenFoodFactsService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<OpenFoodFactsProduct?> searchByText(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return null;
    try {
      final uri = Uri.https('world.openfoodfacts.org', '/cgi/search.pl', {
        'search_terms': normalized,
        'search_simple': '1',
        'action': 'process',
        'json': '1',
        'page_size': '1',
        'fields': 'product_name,ingredients_text',
      });
      final response = await _client.get(uri);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final products = data['products'] as List<dynamic>? ?? const [];
      if (products.isEmpty) return null;
      final product = products.first as Map<String, dynamic>;
      return OpenFoodFactsProduct(
        name: (product['product_name'] ?? normalized).toString(),
        ingredientsText: (product['ingredients_text'] ?? '').toString(),
      );
    } catch (_) {
      return null;
    }
  }
}
