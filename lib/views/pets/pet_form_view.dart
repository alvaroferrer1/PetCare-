import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/app_state_controller.dart';
import '../../core/config/app_config.dart';
import '../../core/navigation/safe_navigation.dart';
import '../../models/pet_model.dart';
import '../../services/cat_api_service.dart';
import '../../services/dog_api_service.dart';

class PetFormView extends ConsumerStatefulWidget {
  const PetFormView({this.petId, super.key});

  final String? petId;

  @override
  ConsumerState<PetFormView> createState() => _PetFormViewState();
}

class _PetFormViewState extends ConsumerState<PetFormView> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _breed = TextEditingController();
  final _weight = TextEditingController();
  final _photoUrl = TextEditingController();
  final _notes = TextEditingController();
  final _allergies = TextEditingController();
  PetSpecies _species = PetSpecies.dog;
  bool _loadingPhoto = false;
  bool _loadingBreeds = false;
  String? _suggestedPhotoUrl;
  List<String> _breedOptions = const [];

  @override
  void initState() {
    super.initState();
    final existing = _existingPet();
    if (existing != null) {
      _name.text = existing.name;
      _breed.text = existing.breed;
      _weight.text = existing.weight?.toString() ?? '';
      _photoUrl.text = existing.photoUrl ?? '';
      _notes.text = existing.notes;
      _allergies.text = existing.allergies;
      _species = existing.species;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _breed.dispose();
    _weight.dispose();
    _photoUrl.dispose();
    _notes.dispose();
    _allergies.dispose();
    super.dispose();
  }

  PetModel? _existingPet() {
    final id = widget.petId;
    if (id == null) return null;
    final matches = ref
        .read(appStateControllerProvider)
        .pets
        .where((pet) => pet.id == id);
    return matches.isEmpty ? null : matches.first;
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.petId != null;
    return Scaffold(
      appBar: AppBar(title: Text(editing ? 'Editar mascota' : 'Nueva mascota')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            SegmentedButton<PetSpecies>(
              segments: PetSpecies.values
                  .map(
                    (species) => ButtonSegment(
                      value: species,
                      label: Text(species.label),
                      icon: Icon(
                        species == PetSpecies.dog
                            ? Icons.pets
                            : Icons.cruelty_free,
                      ),
                    ),
                  )
                  .toList(),
              selected: {_species},
              onSelectionChanged: (value) => setState(() {
                _species = value.first;
                _breedOptions = const [];
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nombre'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Obligatorio' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _breed,
              decoration: const InputDecoration(labelText: 'Raza'),
            ),
            const SizedBox(height: 10),
            if (_breedOptions.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _breedOptions.contains(_breed.text) ? _breed.text : null,
                decoration: const InputDecoration(
                  labelText: 'Razas sugeridas',
                  prefixIcon: Icon(Icons.list_alt_outlined),
                ),
                items: _breedOptions
                    .take(60)
                    .map(
                      (breed) =>
                          DropdownMenuItem(value: breed, child: Text(breed)),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _breed.text = value);
                    _suggestPhoto(previewOnly: true);
                  }
                },
              ),
            if (_breedOptions.isNotEmpty) const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _loadingBreeds ? null : _loadBreeds,
              icon: _loadingBreeds
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.cloud_download_outlined),
              label: Text(
                _loadingBreeds
                    ? 'Cargando razas...'
                    : 'Cargar razas de ${_species.label.toLowerCase()}',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weight,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Peso kg'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _photoUrl,
              decoration: const InputDecoration(labelText: 'URL de foto'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _loadingPhoto ? null : () => _suggestPhoto(),
              icon: _loadingPhoto
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.image_search),
              label: const Text('Sugerir foto por raza'),
            ),
            if (_suggestedPhotoUrl != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  _suggestedPhotoUrl!,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 8),
              FilledButton.tonalIcon(
                onPressed: () =>
                    setState(() => _photoUrl.text = _suggestedPhotoUrl!),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Usar esta foto'),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Notas'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _allergies,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Alergias o intolerancias',
                hintText: 'Ej. pollo, lactosa, cereales',
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _save,
              child: Text(editing ? 'Guardar cambios' : 'Crear mascota'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final profile = ref.read(appStateControllerProvider).profile;
    final existing = widget.petId == null ? null : _existingPet();
    final now = DateTime.now();
    final pet = (existing ?? PetModel.empty(profile?.id ?? 'demo-user'))
        .copyWith(
          name: _name.text.trim(),
          species: _species,
          breed: _breed.text.trim(),
          weight: double.tryParse(_weight.text.replaceAll(',', '.')),
          photoUrl: _photoUrl.text.trim().isEmpty
              ? null
              : _photoUrl.text.trim(),
          notes: _notes.text.trim(),
          allergies: _allergies.text.trim(),
          updatedAt: now,
        );
    await ref.read(appStateControllerProvider.notifier).savePet(pet);
    if (!mounted) return;
    context.popOrRoot();
  }

  Future<void> _suggestPhoto({bool previewOnly = false}) async {
    setState(() => _loadingPhoto = true);
    final config = ref.read(appConfigProvider);
    final breed = _breed.text.trim();
    final url = _species == PetSpecies.dog
        ? await DogApiService().fetchBreedImage(breed)
        : await CatApiService(apiKey: config.catApiKey).fetchBreedImage(breed);
    if (!mounted) return;
    setState(() {
      _loadingPhoto = false;
      if (url != null) {
        _suggestedPhotoUrl = url;
        if (!previewOnly) _photoUrl.text = url;
      }
    });
    if (url == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo obtener imagen. Puedes pegar una URL manual.',
          ),
        ),
      );
    }
  }

  Future<void> _loadBreeds() async {
    setState(() => _loadingBreeds = true);
    final config = ref.read(appConfigProvider);
    final breeds = _species == PetSpecies.dog
        ? await DogApiService().fetchBreeds()
        : await CatApiService(apiKey: config.catApiKey).fetchBreeds();
    if (!mounted) return;
    setState(() {
      _breedOptions = breeds;
      _loadingBreeds = false;
    });
    if (breeds.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudieron cargar razas.')),
      );
    }
  }
}
