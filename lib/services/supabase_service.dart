import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseClient? get client {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
}
