import 'dart:convert';

import 'package:http/http.dart' as http;

class OpenFoodFactsProduct {
  const OpenFoodFactsProduct({
    required this.name,
    required this.ingredientsText,
    required this.code,
    required this.imageUrl,
  });

  final String name;
  final String ingredientsText;
  final String code;
  final String imageUrl;
}

class OpenFoodFactsService {
  OpenFoodFactsService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<OpenFoodFactsProduct?> searchByText(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return null;
    try {
      final uri = Uri.https('world.openpetfoodfacts.org', '/cgi/search.pl', {
        'search_terms': normalized,
        'search_simple': '1',
        'action': 'process',
        'json': '1',
        'page_size': '1',
        'fields': 'code,product_name,ingredients_text,image_url',
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
        code: (product['code'] ?? '').toString(),
        imageUrl: (product['image_url'] ?? '').toString(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<OpenFoodFactsProduct?> searchByBarcode(String barcode) async {
    final normalized = barcode.trim();
    if (normalized.isEmpty) return null;
    try {
      final uri = Uri.https(
        'world.openpetfoodfacts.org',
        '/api/v0/product/$normalized.json',
      );
      final response = await _client.get(uri);
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (data['status'] != 1) return null;
      final product = data['product'] as Map<String, dynamic>;
      return OpenFoodFactsProduct(
        name: (product['product_name'] ?? normalized).toString(),
        ingredientsText: (product['ingredients_text'] ?? '').toString(),
        code: normalized,
        imageUrl: (product['image_url'] ?? '').toString(),
      );
    } catch (_) {
      return null;
    }
  }
}
