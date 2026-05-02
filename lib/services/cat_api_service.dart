import 'dart:convert';

import 'package:http/http.dart' as http;

class CatApiService {
  CatApiService({http.Client? client, String apiKey = ''})
    : _client = client ?? http.Client(),
      _apiKey = apiKey;

  final http.Client _client;
  final String _apiKey;

  static const _fallbackBreeds = ['Siamese', 'Persian', 'Maine Coon', 'Bengal'];

  Future<List<String>> fetchBreeds() async {
    try {
      final response = await _client.get(
        Uri.parse('https://api.thecatapi.com/v1/breeds'),
        headers: _apiKey.isEmpty ? const {} : {'x-api-key': _apiKey},
      );
      if (response.statusCode != 200) return _fallbackBreeds;
      final data = jsonDecode(response.body) as List<dynamic>;
      return data
          .map((item) => (item as Map<String, dynamic>)['name'] as String)
          .toList()
        ..sort();
    } catch (_) {
      return _fallbackBreeds;
    }
  }

  Future<String?> fetchBreedImage(String breed) async {
    try {
      final response = await _client.get(
        Uri.parse('https://api.thecatapi.com/v1/images/search?limit=1'),
        headers: _apiKey.isEmpty ? const {} : {'x-api-key': _apiKey},
      );
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as List<dynamic>;
      if (data.isEmpty) return null;
      return (data.first as Map<String, dynamic>)['url'] as String?;
    } catch (_) {
      return null;
    }
  }
}
