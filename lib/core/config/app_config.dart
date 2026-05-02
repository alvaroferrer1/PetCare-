import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppConfig {
  const AppConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.openAiApiKey,
    required this.catApiKey,
  });

  factory AppConfig.fromEnv() {
    return AppConfig(
      supabaseUrl: dotenv.env['SUPABASE_URL'] ?? '',
      supabaseAnonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
      openAiApiKey: dotenv.env['OPENAI_API_KEY'] ?? '',
      catApiKey: dotenv.env['THE_CAT_API_KEY'] ?? '',
    );
  }

  final String supabaseUrl;
  final String supabaseAnonKey;
  final String openAiApiKey;
  final String catApiKey;

  bool get hasSupabase =>
      supabaseUrl.startsWith('https://') && supabaseAnonKey.isNotEmpty;

  bool get hasOpenAi => openAiApiKey.isNotEmpty;
}

final appConfigProvider = Provider<AppConfig>((ref) => AppConfig.fromEnv());
