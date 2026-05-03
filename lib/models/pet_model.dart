enum PetSpecies {
  dog('Perro'),
  cat('Gato');

  const PetSpecies(this.label);
  final String label;

  static PetSpecies fromDb(String value) => PetSpecies.values.firstWhere(
    (item) => item.name == value,
    orElse: () => PetSpecies.dog,
  );
}

class PetModel {
  const PetModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.species,
    required this.breed,
    required this.birthDate,
    required this.weight,
    required this.photoUrl,
    required this.notes,
    required this.allergies,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final PetSpecies species;
  final String breed;
  final DateTime? birthDate;
  final double? weight;
  final String? photoUrl;
  final String notes;
  final String allergies;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory PetModel.empty(String userId) {
    final now = DateTime.now();
    return PetModel(
      id: '',
      userId: userId,
      name: '',
      species: PetSpecies.dog,
      breed: '',
      birthDate: null,
      weight: null,
      photoUrl: null,
      notes: '',
      allergies: '',
      createdAt: now,
      updatedAt: now,
    );
  }

  factory PetModel.fromMap(Map<String, dynamic> map) {
    return PetModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      species: PetSpecies.fromDb(map['species'] as String),
      breed: (map['breed'] ?? '') as String,
      birthDate: map['birth_date'] == null
          ? null
          : DateTime.parse(map['birth_date'] as String),
      weight: (map['weight'] as num?)?.toDouble(),
      photoUrl: map['photo_url'] as String?,
      notes: (map['notes'] ?? '') as String,
      allergies: (map['allergies'] ?? '') as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'name': name,
      'species': species.name,
      'breed': breed,
      'birth_date': birthDate?.toIso8601String().split('T').first,
      'weight': weight,
      'photo_url': photoUrl,
      'notes': notes,
      'allergies': allergies,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PetModel copyWith({
    String? id,
    String? userId,
    String? name,
    PetSpecies? species,
    String? breed,
    DateTime? birthDate,
    double? weight,
    String? photoUrl,
    String? notes,
    String? allergies,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      species: species ?? this.species,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      weight: weight ?? this.weight,
      photoUrl: photoUrl ?? this.photoUrl,
      notes: notes ?? this.notes,
      allergies: allergies ?? this.allergies,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
