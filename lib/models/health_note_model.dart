class HealthNoteModel {
  const HealthNoteModel({
    required this.id,
    required this.userId,
    required this.petId,
    required this.symptoms,
    required this.mood,
    required this.appetite,
    required this.energyLevel,
    required this.notes,
    required this.noteDate,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String petId;
  final String symptoms;
  final String mood;
  final String appetite;
  final int energyLevel;
  final String notes;
  final DateTime noteDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory HealthNoteModel.fromMap(Map<String, dynamic> map) {
    return HealthNoteModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      petId: map['pet_id'] as String,
      symptoms: (map['symptoms'] ?? '') as String,
      mood: (map['mood'] ?? '') as String,
      appetite: (map['appetite'] ?? '') as String,
      energyLevel: (map['energy_level'] ?? 3) as int,
      notes: (map['notes'] ?? '') as String,
      noteDate: DateTime.parse(map['note_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'pet_id': petId,
      'symptoms': symptoms,
      'mood': mood,
      'appetite': appetite,
      'energy_level': energyLevel,
      'notes': notes,
      'note_date': noteDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
