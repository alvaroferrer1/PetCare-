import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:petcare_ai_companion/models/food_safety_item_model.dart';
import 'package:petcare_ai_companion/services/cat_api_service.dart';
import 'package:petcare_ai_companion/services/dog_api_service.dart';
import 'package:petcare_ai_companion/services/dog_food_api_service.dart';
import 'package:petcare_ai_companion/services/open_food_facts_service.dart';

void main() {
  group('Dog CEO API', () {
    test('parsea razas y las ordena', () async {
      final service = DogApiService(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'message': {'beagle': [], 'akita': []},
            }),
            200,
          ),
        ),
      );

      expect(await service.fetchBreeds(), ['akita', 'beagle']);
    });

    test('usa fallback cuando falla', () async {
      final service = DogApiService(
        client: MockClient((_) async => http.Response('error', 500)),
      );

      expect(await service.fetchBreeds(), contains('labrador'));
    });
  });

  group('The Cat API', () {
    test('parsea razas y las ordena', () async {
      final service = CatApiService(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode([
              {'name': 'Siamese'},
              {'name': 'Bengal'},
            ]),
            200,
          ),
        ),
      );

      expect(await service.fetchBreeds(), ['Bengal', 'Siamese']);
    });

    test('usa fallback cuando falla', () async {
      final service = CatApiService(
        client: MockClient((_) async => http.Response('error', 500)),
      );

      expect(await service.fetchBreeds(), contains('Maine Coon'));
    });
  });

  group('Open Pet Food Facts', () {
    test('busca producto por texto en el dominio de mascotas', () async {
      Uri? requestedUri;
      final service = OpenFoodFactsService(
        client: MockClient((request) async {
          requestedUri = request.url;
          return http.Response(
            jsonEncode({
              'products': [
                {
                  'code': '123',
                  'product_name': 'Cat food tuna',
                  'ingredients_text': 'tuna, rice',
                  'image_url': 'https://example.com/cat.png',
                },
              ],
            }),
            200,
          );
        }),
      );

      final product = await service.searchByText('cat food');

      expect(requestedUri?.host, 'world.openpetfoodfacts.org');
      expect(product?.name, 'Cat food tuna');
      expect(product?.code, '123');
      expect(product?.imageUrl, contains('cat.png'));
    });

    test('busca producto por codigo de barras', () async {
      final service = OpenFoodFactsService(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'status': 1,
              'product': {
                'product_name': 'Dog food',
                'ingredients_text': 'chicken, rice',
                'image_url': 'https://example.com/dog.png',
              },
            }),
            200,
          ),
        ),
      );

      final product = await service.searchByBarcode('20106836');

      expect(product?.code, '20106836');
      expect(product?.ingredientsText, contains('rice'));
    });
  });

  group('DogFoodApi', () {
    test('convierte respuesta externa a nivel safe/toxic', () async {
      final service = DogFoodApiService(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({
              'name': 'banana',
              'safe': 'yes',
              'toxic': 'no',
              'obs': 'Safe in moderation',
            }),
            200,
          ),
        ),
      );

      final item = await service.search('banana');

      expect(item?.species, 'dog');
      expect(item?.safetyLevel, FoodSafetyLevel.safe);
      expect(item?.source, contains('dogFoodApi'));
    });
  });
}
