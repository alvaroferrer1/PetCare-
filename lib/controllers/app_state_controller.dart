import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';
import '../models/ai_summary_model.dart';
import '../models/activity_item_model.dart';
import '../models/care_event_model.dart';
import '../models/food_safety_item_model.dart';
import '../models/health_note_model.dart';
import '../models/pet_model.dart';
import '../models/pet_document_model.dart';
import '../models/profile_model.dart';
import '../models/product_check_model.dart';
import '../models/vet_contact_model.dart';
import '../models/weight_log_model.dart';
import '../services/dog_food_api_service.dart';
import '../services/open_food_facts_service.dart';
import '../services/openai_service.dart';

class AppState {
  const AppState({
    required this.loading,
    required this.onboardingDone,
    required this.profile,
    required this.pets,
    required this.events,
    required this.notes,
    required this.foodItems,
    required this.vetContacts,
    required this.documents,
    required this.weightLogs,
    required this.productChecks,
    required this.summaries,
    this.error,
    this.message,
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
      vetContacts: const [],
      documents: const [],
      weightLogs: const [],
      productChecks: const [],
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
  final List<VetContactModel> vetContacts;
  final List<PetDocumentModel> documents;
  final List<WeightLogModel> weightLogs;
  final List<ProductCheckModel> productChecks;
  final Map<String, AiSummaryModel> summaries;
  final String? error;
  final String? message;

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
    List<VetContactModel>? vetContacts,
    List<PetDocumentModel>? documents,
    List<WeightLogModel>? weightLogs,
    Map<String, AiSummaryModel>? summaries,
    List<ProductCheckModel>? productChecks,
    String? error,
    bool clearError = false,
    String? message,
    bool clearMessage = false,
  }) {
    return AppState(
      loading: loading ?? this.loading,
      onboardingDone: onboardingDone ?? this.onboardingDone,
      profile: clearProfile ? null : profile ?? this.profile,
      pets: pets ?? this.pets,
      events: events ?? this.events,
      notes: notes ?? this.notes,
      foodItems: foodItems ?? this.foodItems,
      vetContacts: vetContacts ?? this.vetContacts,
      documents: documents ?? this.documents,
      weightLogs: weightLogs ?? this.weightLogs,
      productChecks: productChecks ?? this.productChecks,
      summaries: summaries ?? this.summaries,
      error: clearError ? null : error ?? this.error,
      message: clearMessage ? null : message ?? this.message,
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
    state = state.copyWith(loading: true, clearError: true, clearMessage: true);
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
      if (register && response.session == null) {
        state = state.copyWith(
          loading: false,
          message:
              'Cuenta creada. Revisa tu email para confirmar el registro antes de iniciar sesion.',
        );
        return;
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
      final vetContacts = await client
          .from('vet_contacts')
          .select()
          .eq('user_id', profile.id)
          .order('is_emergency', ascending: false);
      final documents = await client
          .from('pet_documents')
          .select()
          .eq('user_id', profile.id)
          .order('created_at', ascending: false);
      final weightLogs = await client
          .from('weight_logs')
          .select()
          .eq('user_id', profile.id)
          .order('logged_at');
      final productChecks = await client
          .from('product_checks')
          .select()
          .eq('user_id', profile.id)
          .order('created_at', ascending: false);
      state = state.copyWith(
        loading: false,
        profile: profiles.isEmpty
            ? profile
            : ProfileModel.fromMap(profiles.first),
        pets: pets.map(PetModel.fromMap).toList(),
        events: events.map(CareEventModel.fromMap).toList(),
        notes: notes.map(HealthNoteModel.fromMap).toList(),
        foodItems: food.map(FoodSafetyItemModel.fromMap).toList(),
        vetContacts: vetContacts.map(VetContactModel.fromMap).toList(),
        documents: documents.map(PetDocumentModel.fromMap).toList(),
        weightLogs: weightLogs.map(WeightLogModel.fromMap).toList(),
        productChecks: productChecks.map(ProductCheckModel.fromMap).toList(),
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

  Future<void> saveVetContact(VetContactModel contact) async {
    final item = contact.id.isEmpty
        ? VetContactModel(
            id: _localId('vet'),
            userId: contact.userId,
            name: contact.name,
            clinic: contact.clinic,
            phone: contact.phone,
            notes: contact.notes,
            isEmergency: contact.isEmergency,
          )
        : contact;
    final client = _client;
    if (client != null && state.profile != null) {
      final data = item.toMap();
      if (contact.id.isEmpty || contact.id.startsWith('local-')) {
        await client.from('vet_contacts').insert(data..remove('id'));
      } else {
        await client.from('vet_contacts').update(data).eq('id', contact.id);
      }
      await refreshRemoteData();
      return;
    }
    state = state.copyWith(vetContacts: [...state.vetContacts, item]);
  }

  Future<void> addDocument(PetDocumentModel document) async {
    final item = PetDocumentModel(
      id: document.id.isEmpty ? _localId('doc') : document.id,
      userId: document.userId,
      petId: document.petId,
      title: document.title,
      documentType: document.documentType,
      fileUrl: document.fileUrl,
      notes: document.notes,
      createdAt: document.createdAt,
    );
    final client = _client;
    if (client != null &&
        state.profile != null &&
        !document.petId.startsWith('local-')) {
      await client.from('pet_documents').insert(item.toMap()..remove('id'));
      await refreshRemoteData();
      return;
    }
    state = state.copyWith(documents: [item, ...state.documents]);
  }

  Future<void> addWeightLog(WeightLogModel log) async {
    final item = WeightLogModel(
      id: log.id.isEmpty ? _localId('weight') : log.id,
      userId: log.userId,
      petId: log.petId,
      weight: log.weight,
      loggedAt: log.loggedAt,
      notes: log.notes,
    );
    final client = _client;
    if (client != null &&
        state.profile != null &&
        !log.petId.startsWith('local-')) {
      await client.from('weight_logs').insert(item.toMap()..remove('id'));
      await refreshRemoteData();
      return;
    }
    state = state.copyWith(weightLogs: [...state.weightLogs, item]);
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

  Future<ProductCheckModel> checkProductIngredients(
    String query,
    String species, {
    bool byBarcode = false,
  }) async {
    final product = byBarcode
        ? await OpenFoodFactsService().searchByBarcode(query)
        : await OpenFoodFactsService().searchByText(query);
    final ingredients = normalizeFoodName(product?.ingredientsText ?? query);
    final risks = state.foodItems.where((item) {
      if (item.species != species) return false;
      if (item.safetyLevel == FoodSafetyLevel.safe) return false;
      return ingredients.contains(item.normalizedName);
    }).toList();

    final result = ProductCheckModel(
      query: query,
      species: species,
      productName: product?.name ?? query,
      ingredients: product?.ingredientsText.isNotEmpty == true
          ? product!.ingredientsText
          : 'No se encontraron ingredientes en Open Food Facts. Se muestra resultado orientativo.',
      barcode: product?.code ?? '',
      imageUrl: product?.imageUrl ?? '',
      matchedRisks: risks,
      source: product == null
          ? 'Open Pet Food Facts sin coincidencia'
          : 'Open Pet Food Facts - https://world.openpetfoodfacts.org',
      createdAt: DateTime.now(),
    );
    final client = _client;
    final profile = state.profile;
    if (client != null && profile != null) {
      await client.from('product_checks').insert({
        'user_id': profile.id,
        'species': species,
        'query': result.query,
        'product_name': result.productName,
        'ingredients': result.ingredients,
        'barcode': result.barcode,
        'image_url': result.imageUrl,
        'matched_risks': result.matchedRisks
            .map(
              (item) => {
                'food_name': item.foodName,
                'safety_level': item.safetyLevel.name,
                'description': item.description,
                'source': item.source,
              },
            )
            .toList(),
        'source': result.source,
      });
    }
    state = state.copyWith(productChecks: [result, ...state.productChecks]);
    return result;
  }

  Future<AiSummaryModel> generateSummary(String petId) async {
    final matches = state.pets.where((item) => item.id == petId);
    if (matches.isEmpty) {
      throw StateError('No se pudo cargar la mascota para generar la IA.');
    }
    final pet = matches.first;
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
    if (message.contains('Email not confirmed')) {
      return 'Email pendiente de confirmar. Revisa tu correo antes de iniciar sesion.';
    }
    if (message.contains('email rate limit') ||
        message.contains('over_email_send_rate_limit')) {
      return 'Supabase ha limitado el envio de emails. Espera unos minutos o desactiva la confirmacion de email para la demo.';
    }
    return 'Algo no ha ido bien. Revisa los datos e intentalo de nuevo.';
  }

  String _localId(String prefix) =>
      'local-$prefix-${DateTime.now().microsecondsSinceEpoch}';
}

List<ActivityItemModel> buildActivityFeed(AppState state) {
  final petsById = {for (final pet in state.pets) pet.id: pet.name};
  final items = <ActivityItemModel>[
    for (final pet in state.pets)
      ActivityItemModel(
        title: 'Mascota creada',
        subtitle: pet.name,
        date: pet.createdAt,
        icon: Icons.pets,
        color: Colors.green,
      ),
    for (final event in state.events.where(
      (event) =>
          event.type == CareEventType.vaccine &&
          event.status == CareEventStatus.completed,
    ))
      ActivityItemModel(
        title: 'Vacuna completada',
        subtitle: '${event.title} · ${petsById[event.petId] ?? 'Mascota'}',
        date: event.updatedAt,
        icon: Icons.vaccines_outlined,
        color: Colors.blue,
      ),
    for (final note in state.notes)
      ActivityItemModel(
        title: 'Nota de salud añadida',
        subtitle:
            '${petsById[note.petId] ?? 'Mascota'} · ${note.symptoms.isEmpty ? 'Sin sintomas' : note.symptoms}',
        date: note.createdAt,
        icon: Icons.monitor_heart_outlined,
        color: Colors.teal,
      ),
    for (final log in state.weightLogs)
      ActivityItemModel(
        title: 'Peso registrado',
        subtitle:
            '${petsById[log.petId] ?? 'Mascota'} · ${log.weight.toStringAsFixed(1)} kg',
        date: log.loggedAt,
        icon: Icons.monitor_weight_outlined,
        color: Colors.orange,
      ),
    for (final summary in state.summaries.entries)
      ActivityItemModel(
        title: 'Informe generado',
        subtitle: petsById[summary.key] ?? 'Mascota',
        date: summary.value.createdAt,
        icon: Icons.picture_as_pdf_outlined,
        color: Colors.deepPurple,
      ),
    for (final check in state.productChecks)
      ActivityItemModel(
        title: 'Alimento consultado',
        subtitle:
            '${check.productName} · ${check.species == 'dog' ? 'Perro' : 'Gato'}',
        date: check.createdAt,
        icon: Icons.restaurant_menu,
        color: check.hasRisks ? Colors.red : Colors.green,
      ),
  ];
  items.sort((a, b) => b.date.compareTo(a.date));
  return items;
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
