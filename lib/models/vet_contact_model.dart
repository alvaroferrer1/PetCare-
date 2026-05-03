class VetContactModel {
  const VetContactModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.clinic,
    required this.phone,
    required this.notes,
    required this.isEmergency,
  });

  final String id;
  final String userId;
  final String name;
  final String clinic;
  final String phone;
  final String notes;
  final bool isEmergency;

  factory VetContactModel.fromMap(Map<String, dynamic> map) {
    return VetContactModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: (map['name'] ?? '') as String,
      clinic: (map['clinic'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      notes: (map['notes'] ?? '') as String,
      isEmergency: (map['is_emergency'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'name': name,
      'clinic': clinic,
      'phone': phone,
      'notes': notes,
      'is_emergency': isEmergency,
    };
  }
}
