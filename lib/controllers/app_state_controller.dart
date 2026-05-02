import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';
import '../models/ai_summary_model.dart';
import '../models/care_event_model.dart';
import '../models/food_safety_item_model.dart';
import '../models/health_note_model.dart';
import '../models/pet_model.dart';
import '../models/profile_model.dart';
import '../services/openai_service.dart';
import '../services/dog_food_api_service.dart';

class AppState {
  const AppState({
    required this.loading,
    required this.onboardingDone,
    required this.profile,
    required this.pets,
    required this.events,
    required this.notes,
    required this.foodItems,
    required this.summaries,
    this.error,
  });

  factory AppState.initial() {
    return AppState(
      loading: false,
      onboardingDone: false,
      profile: null,
      pets: const [],
      events: const [],
      notes: const [],
      foodItems: FoodSafetySeed.items,
      summaries: const {},
    );
  }

  final bool loading;
  final bool onboardingDone;
  final ProfileModel? profile;
  final List<PetModel> pets;
  final List<CareEventModel> events;
  final List<HealthNoteModel> notes;
  final List<FoodSafetyItemModel> foodItems;
  final Map<String, AiSummaryModel> summaries;
  final String? error;

  bool get isAuthenticated => profile != null;

  List<CareEventModel> get pendingEvents {
    final items = events
        .where((event) => event.status == CareEventStatus.pending)
        .toList();
    items.sort((a, b) => a.eventDate.compareTo(b.eventDate));
    return items;
  }

  AppState copyWith({
    bool? loading,
    bool? onboardingDone,
    ProfileModel? profile,
    bool clearProfile = false,
    List<PetModel>? pets,
    List<CareEventModel>? events,
    List<HealthNoteModel>? notes,
    List<FoodSafetyItemModel>? foodItems,
    Map<String, AiSummaryModel>? summaries,
    String? error,
    bool clearError = false,
  }) {
    return AppState(
      loading: loading ?? this.loading,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      profile: clearProfile ? null : profile ?? this.profile,
      pets: pets ?? this.pets,
      events: events ?? this.events,
      notes: notes ?? this.notes,
      foodItems: foodItems ?? this.foodItems,
      summaries: summaries ?? this.summaries,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AppStateController extends StateNotifier<AppState> {
  AppStateController(this._config) : super(AppState.initial()) {
    _restoreSession();
  }

  final AppConfig _config;

  SupabaseClient? get _client {
    try {
      return _config.hasSupabase ? Supabase.instance.client : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _restoreSession() async {
    final client = _client;
    if (client == null) return;
    final user = client.auth.currentUser;
    if (user == null) return;
    state = state.copyWith(profile: _profileFromUser(user));
    await refreshRemoteData();
  }

  Future<void> completeOnboarding() async {
    state = state.copyWith(onboardingDone: true);
  }

  Future<void> signIn(String email, String password) async {
    await _auth(email, password, register: false);
  }

  Future<void> register(
    String email,
    String password, {
    String fullName = '',
  }) async {
    await _auth(email, password, register: true, fullName: fullName);
  }

  Future<void> _auth(
    String email,
    String password, {
    required bool register,
    String fullName = '',
  }) async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final client = _client;
      if (client == null) {
        state = state.copyWith(
          loading: false,
          profile: ProfileModel.demo(),
          onboardingDone: true,
        );
        return;
      }

      final response = register
          ? await client.auth.signUp(
              email: email,
              password: password,
              data: {'full_name': fullName},
            )
          : await client.auth.signInWithPassword(
              email: email,
              password: password,
            );
      final user = response.user;
      if (user == null) {
        throw const AuthException('No se pudo autenticar el usuario.');
      }
      await client.from('profiles').upsert({
        'id': user.id,
        'email': user.email,
        if (fullName.isNotEmpty) 'full_name': fullName,
        'updated_at': DateTime.now().toIso8601String(),
      });
      state = state.copyWith(
        loading: false,
        onboardingDone: true,
        profile: _profileFromUser(user),
      );
      await refreshRemoteData();
    } catch (error) {
      state = state.copyWith(loading: false, error: _friendlyError(error));
    }
  }

  Future<void> signOut() async {
    await _client?.auth.signOut();
    state = AppState.initial().copyWith(onboardingDone: true);
  }

  Future<void> refreshRemoteData() async {
    final client = _client;
    final profile = state.profile;
    if (client == null || profile == null) return;
    state = state.copyWith(loading: true, clearError: true);
    try {
      final pets = await client
          .from('pets')
          .select()
          .eq('user_id', profile.id)
          .order('created_at');
      final events = await client
          .from('care_events')
          .select()
          .eq('user_id', profile.id)
          .order('event_date');
      final notes = await client
          .from('health_notes')
          .select()
          .eq('user_id', profile.id)
          .order('note_date', ascending: false);
      final food = await client
          .from('food_safety_items')
          .select()
          .order('food_name');
      final profiles = await client
          .from('profiles')
          .select()
          .eq('id', profile.id)
          .limit(1);
      state = state.copyWith(
        loading: false,
        profile: profiles.isEmpty
            ? profile
            : ProfileModel.fromMap(profiles.first),
        pets: pets.map(PetModel.fromMap).toList(),
        events: events.map(CareEventModel.fromMap).toList(),
        notes: notes.map(HealthNoteModel.fromMap).toList(),
        foodItems: food.map(FoodSafetyItemModel.fromMap).toList(),
      );
    } catch (error) {
      state = state.copyWith(loading: false, error: _friendlyError(error));
    }
  }

  Future<void> saveProfile(ProfileModel profile) async {
    final client = _client;
    if (client != null) {
      await client.from('profiles').upsert(profile.toMap());
    }
    state = state.copyWith(profile: profile);
  }

  Future<void> savePet(PetModel pet) async {
    final now = DateTime.now();
    final profile = state.profile ?? ProfileModel.demo();
    final newPet = pet.copyWith(
      id: pet.id.isEmpty ? _localId('pet') : pet.id,
      userId: profile.id,
      createdAt: pet.id.isEmpty ? now : pet.createdAt,
      updatedAt: now,
    );

    final client = _client;
    if (client != null && state.profile != null) {
      final data = newPet.toMap()..remove('id');
      if (pet.id.isEmpty || pet.id.startsWith('local-')) {
        await client.from('pets').insert(data);
      } else {
        await client.from('pets').update(data).eq('id', pet.id);
      }
      await refreshRemoteData();
      return;
    }

    final pets = [...state.pets];
    final index = pets.indexWhere((item) => item.id == pet.id);
    if (index == -1) {
      pets.add(newPet);
    } else {
      pets[index] = newPet;
    }
    state = state.copyWith(pets: pets);
  }

  Future<void> deletePet(String petId) async {
    final client = _client;
    if (client != null && !petId.startsWith('local-')) {
      await client.from('pets').delete().eq('id', petId);
      await refreshRemoteData();
      return;
    }
    state = state.copyWith(
      pets: state.pets.where((pet) => pet.id != petId).toList(),
      events: state.events.where((event) => event.petId != petId).toList(),
      notes: state.notes.where((note) => note.petId != petId).toList(),
    );
  }

  Future<void> addEvent(CareEventModel event) async {
    final item = event.copyWith(id: _localId('event'));
    final client = _client;
    if (client != null && !event.petId.startsWith('local-')) {
      await client.from('care_events').insert(event.toMap()..remove('id'));
      await refreshRemoteData();
      return;
    }
    state = state.copyWith(events: [...state.events, item]);
  }

  Future<void> completeEvent(String eventId) async {
    final updated = state.events.map((event) {
      if (event.id != eventId) return event;
      return event.copyWith(
        status: CareEventStatus.completed,
        updatedAt: DateTime.now(),
      );
    }).toList();
    final client = _client;
    if (client != null && !eventId.startsWith('local-')) {
      await client
          .from('care_events')
          .update({
            'status': CareEventStatus.completed.name,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', eventId);
    }
    state = state.copyWith(events: updated);
  }

  Future<void> addNote(HealthNoteModel note) async {
    final client = _client;
    if (client != null && !note.petId.startsWith('local-')) {
      await client.from('health_notes').insert(note.toMap()..remove('id'));
      await refreshRemoteData();
      return;
    }
    final item = HealthNoteModel(
      id: _localId('note'),
      userId: note.userId,
      petId: note.petId,
      symptoms: note.symptoms,
      mood: note.mood,
      appetite: note.appetite,
      energyLevel: note.energyLevel,
      notes: note.notes,
      noteDate: note.noteDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    state = state.copyWith(notes: [item, ...state.notes]);
  }

  FoodSafetyItemModel searchFood(String query, String species) {
    final normalized = normalizeFoodName(query);
    if (normalized.isEmpty) return FoodSafetyItemModel.unknown(query, species);
    final exact = state.foodItems.where(
      (item) => item.species == species && item.normalizedName == normalized,
    );
    if (exact.isNotEmpty) return exact.first;
    return state.foodItems.firstWhere(
      (item) =>
          item.species == species &&
          (item.normalizedName.contains(normalized) ||
              normalized.contains(item.normalizedName)),
      orElse: () => FoodSafetyItemModel.unknown(query, species),
    );
  }

  Future<FoodSafetyItemModel> searchFoodWithExternalFallback(
    String query,
    String species,
  ) async {
    final local = searchFood(query, species);
    if (local.safetyLevel != FoodSafetyLevel.unknown || species != 'dog') {
      return local;
    }
    final external = await DogFoodApiService().search(query);
    return external ?? local;
  }

  Future<AiSummaryModel> generateSummary(String petId) async {
    final pet = state.pets.firstWhere((item) => item.id == petId);
    final payload = {
      'pet': pet.toMap(),
      'recent_events': state.events
          .where((event) => event.petId == petId)
          .map((event) => event.toMap())
          .toList(),
      'health_notes': state.notes
          .where((note) => note.petId == petId)
          .map((note) => note.toMap())
          .toList(),
      'pending_reminders': state.pendingEvents
          .where((event) => event.petId == petId)
          .map((event) => event.toMap())
          .toList(),
    };

    final client = _client;
    AiSummaryModel summary;
    if (client != null && !petId.startsWith('local-')) {
      try {
        final response = await client.functions.invoke(
          'generate-care-summary',
          body: payload,
        );
        summary = AiSummaryModel.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      } catch (_) {
        summary = await OpenAiService(
          apiKey: '',
        ).generateCareSummary(payload: payload);
      }
    } else {
      summary = await OpenAiService(
        apiKey: '',
      ).generateCareSummary(payload: payload);
    }
    state = state.copyWith(summaries: {...state.summaries, petId: summary});

    if (client != null && !petId.startsWith('local-')) {
      await client.from('ai_summaries').insert({
        'user_id': pet.userId,
        'pet_id': pet.id,
        'summary': summary.toJson(),
      });
    }
    return summary;
  }

  ProfileModel _profileFromUser(User user) {
    return ProfileModel(
      id: user.id,
      email: user.email ?? '',
      fullName: (user.userMetadata?['full_name'] ?? '') as String,
      phone: '',
      emergencyVetName: '',
      emergencyVetPhone: '',
    );
  }

  String _friendlyError(Object error) {
    final message = error.toString();
    if (message.contains('Invalid login')) {
      return 'Email o contrasena incorrectos.';
    }
    return 'Algo no ha ido bien. Revisa los datos e intentalo de nuevo.';
  }

  String _localId(String prefix) =>
      'local-$prefix-${DateTime.now().microsecondsSinceEpoch}';
}

final appStateControllerProvider =
    StateNotifierProvider<AppStateController, AppState>((ref) {
      return AppStateController(ref.watch(appConfigProvider));
    });

class FoodSafetySeed {
  static const _source =
      'Base local curada para MVP academico. Revisar con fuente veterinaria antes de ampliar.';

  static final items = <FoodSafetyItemModel>[
    _item('chocolate', 'dog', FoodSafetyLevel.toxic),
    _item('uvas', 'dog', FoodSafetyLevel.toxic),
    _item('grapes', 'dog', FoodSafetyLevel.toxic),
    _item('pasas', 'dog', FoodSafetyLevel.toxic),
    _item('raisins', 'dog', FoodSafetyLevel.toxic),
    _item('cebolla', 'dog', FoodSafetyLevel.toxic),
    _item('onion', 'dog', FoodSafetyLevel.toxic),
    _item('ajo', 'dog', FoodSafetyLevel.toxic),
    _item('garlic', 'dog', FoodSafetyLevel.toxic),
    _item('xilitol', 'dog', FoodSafetyLevel.toxic),
    _item('xylitol', 'dog', FoodSafetyLevel.toxic),
    _item('alcohol', 'dog', FoodSafetyLevel.toxic),
    _item('cafe', 'dog', FoodSafetyLevel.toxic),
    _item('caffeine', 'dog', FoodSafetyLevel.toxic),
    _item('aguacate', 'dog', FoodSafetyLevel.caution),
    _item('avocado', 'dog', FoodSafetyLevel.caution),
    _item('huevo cocido', 'dog', FoodSafetyLevel.caution),
    _item('yogur natural', 'dog', FoodSafetyLevel.caution),
    _item('pollo cocido sin huesos', 'dog', FoodSafetyLevel.safe),
    _item('cooked chicken without bones', 'dog', FoodSafetyLevel.safe),
    _item('zanahoria', 'dog', FoodSafetyLevel.safe),
    _item('carrot', 'dog', FoodSafetyLevel.safe),
    _item('arroz', 'dog', FoodSafetyLevel.safe),
    _item('rice', 'dog', FoodSafetyLevel.safe),
    _item('calabaza', 'dog', FoodSafetyLevel.safe),
    _item('pumpkin', 'dog', FoodSafetyLevel.safe),
    _item('manzana sin semillas', 'dog', FoodSafetyLevel.safe),
    _item('apple without seeds', 'dog', FoodSafetyLevel.safe),
    _item('chocolate', 'cat', FoodSafetyLevel.toxic),
    _item('cebolla', 'cat', FoodSafetyLevel.toxic),
    _item('onion', 'cat', FoodSafetyLevel.toxic),
    _item('ajo', 'cat', FoodSafetyLevel.toxic),
    _item('garlic', 'cat', FoodSafetyLevel.toxic),
    _item('alcohol', 'cat', FoodSafetyLevel.toxic),
    _item('cafe', 'cat', FoodSafetyLevel.toxic),
    _item('caffeine', 'cat', FoodSafetyLevel.toxic),
    _item('uvas', 'cat', FoodSafetyLevel.caution),
    _item('grapes', 'cat', FoodSafetyLevel.caution),
    _item('leche', 'cat', FoodSafetyLevel.caution),
    _item('milk', 'cat', FoodSafetyLevel.caution),
    _item('atun con moderacion', 'cat', FoodSafetyLevel.caution),
    _item('tuna in moderation', 'cat', FoodSafetyLevel.caution),
    _item('huevo cocido', 'cat', FoodSafetyLevel.caution),
    _item('pollo cocido sin huesos', 'cat', FoodSafetyLevel.safe),
    _item('cooked chicken without bones', 'cat', FoodSafetyLevel.safe),
    _item('calabaza', 'cat', FoodSafetyLevel.safe),
    _item('pumpkin', 'cat', FoodSafetyLevel.safe),
  ];

  static FoodSafetyItemModel _item(
    String name,
    String species,
    FoodSafetyLevel level,
  ) {
    return FoodSafetyItemModel(
      id: '$species-${normalizeFoodName(name)}',
      foodName: name,
      normalizedName: normalizeFoodName(name),
      species: species,
      safetyLevel: level,
      description: switch (level) {
        FoodSafetyLevel.safe =>
          'Alimento considerado seguro en condiciones normales y cantidades adecuadas.',
        FoodSafetyLevel.caution =>
          'Puede requerir precaucion, moderacion o consulta veterinaria.',
        FoodSafetyLevel.toxic =>
          'Alimento peligroso o potencialmente toxico. Evita su consumo.',
        FoodSafetyLevel.unknown => 'No hay informacion suficiente.',
      },
      source: _source,
    );
  }
}
