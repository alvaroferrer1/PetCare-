class WeightLogModel {
  const WeightLogModel({
    required this.id,
    required this.userId,
    required this.petId,
    required this.weight,
    required this.loggedAt,
    required this.notes,
  });

  final String id;
  final String userId;
  final String petId;
  final double weight;
  final DateTime loggedAt;
  final String notes;

  factory WeightLogModel.fromMap(Map<String, dynamic> map) {
    return WeightLogModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      petId: map['pet_id'] as String,
      weight: (map['weight'] as num).toDouble(),
      loggedAt: DateTime.parse(map['logged_at'] as String),
      notes: (map['notes'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'pet_id': petId,
      'weight': weight,
      'logged_at': loggedAt.toIso8601String(),
      'notes': notes,
    };
  }
}
