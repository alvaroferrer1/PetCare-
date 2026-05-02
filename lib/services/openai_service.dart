import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/app_copy.dart';
import '../models/ai_summary_model.dart';

class OpenAiService {
  OpenAiService({required String apiKey, http.Client? client})
    : _apiKey = apiKey,
      _client = client ?? http.Client();

  final String _apiKey;
  final http.Client _client;

  Future<AiSummaryModel> generateCareSummary({
    required Map<String, dynamic> payload,
  }) async {
    if (_apiKey.isEmpty) {
      return _fallbackSummary(payload);
    }

    final response = await _client.post(
      Uri.parse('https://api.openai.com/v1/responses'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': 'gpt-4.1-mini',
        'input': [
          {
            'role': 'system',
            'content':
                'Eres un asistente de organizacion de cuidados de mascotas. No diagnostiques, no recomiendes medicamentos ni dosis, y recomienda veterinario ante sintomas preocupantes. Responde solo JSON valido.',
          },
          {'role': 'user', 'content': jsonEncode(payload)},
        ],
        'text': {
          'format': {
            'type': 'json_schema',
            'name': 'care_summary',
            'schema': {
              'type': 'object',
              'additionalProperties': false,
              'properties': {
                'summary': {'type': 'string'},
                'priorities': {
                  'type': 'array',
                  'items': {'type': 'string'},
                },
                'vet_questions': {
                  'type': 'array',
                  'items': {'type': 'string'},
                },
                'general_recommendations': {
                  'type': 'array',
                  'items': {'type': 'string'},
                },
                'safety_notice': {'type': 'string'},
              },
              'required': [
                'summary',
                'priorities',
                'vet_questions',
                'general_recommendations',
                'safety_notice',
              ],
            },
          },
        },
      }),
    );

    if (response.statusCode >= 400) {
      return _fallbackSummary(payload);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final output = data['output'] as List<dynamic>? ?? const [];
    final first = output.firstOrNull as Map<String, dynamic>?;
    final content = first?['content'] as List<dynamic>? ?? const [];
    final text = (content.firstOrNull as Map<String, dynamic>?)?['text'];
    if (text is! String || text.isEmpty) return _fallbackSummary(payload);

    return AiSummaryModel.fromJson(jsonDecode(text) as Map<String, dynamic>);
  }

  AiSummaryModel _fallbackSummary(Map<String, dynamic> payload) {
    final pet = payload['pet'] as Map<String, dynamic>? ?? const {};
    final name = (pet['name'] ?? 'tu mascota') as String;
    return AiSummaryModel(
      summary:
          'Resumen local: revisa los cuidados recientes de $name y mantén actualizado su historial antes de la siguiente visita veterinaria.',
      priorities: const [
        'Revisar recordatorios pendientes ordenados por fecha.',
        'Actualizar peso, vacunas y medicaciones si han cambiado.',
      ],
      vetQuestions: const [
        '¿Hay alguna vacuna o desparasitacion pendiente?',
        '¿Los sintomas registrados requieren revision presencial?',
      ],
      generalRecommendations: const [
        'Mantener una rutina de observacion de apetito, energia y animo.',
      ],
      safetyNotice: AppCopy.aiNotice,
      createdAt: DateTime.now(),
    );
  }
}
