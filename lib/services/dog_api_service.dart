import 'dart:convert';

import 'package:http/http.dart' as http;

class DogApiService {
  DogApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _fallbackBreeds = ['labrador', 'beagle', 'boxer', 'poodle'];

  Future<List<String>> fetchBreeds() async {
    try {
      final response = await _client.get(
        Uri.parse('https://dog.ceo/api/breeds/list/all'),
      );
      if (response.statusCode != 200) return _fallbackBreeds;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final message = data['message'] as Map<String, dynamic>;
      return message.keys.toList()..sort();
    } catch (_) {
      return _fallbackBreeds;
    }
  }

  Future<String?> fetchBreedImage(String breed) async {
    try {
      final normalized = breed.trim().toLowerCase();
      if (normalized.isEmpty) return null;
      final response = await _client.get(
        Uri.parse('https://dog.ceo/api/breed/$normalized/images/random'),
      );
      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}
