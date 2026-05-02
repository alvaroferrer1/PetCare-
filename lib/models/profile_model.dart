class ProfileModel {
  const ProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.emergencyVetName,
    required this.emergencyVetPhone,
  });

  final String id;
  final String email;
  final String fullName;
  final String phone;
  final String emergencyVetName;
  final String emergencyVetPhone;

  factory ProfileModel.demo() {
    return const ProfileModel(
      id: 'demo-user',
      email: 'demo@petcare.app',
      fullName: 'Alvaro Ferrer',
      phone: '',
      emergencyVetName: 'Veterinario habitual',
      emergencyVetPhone: '',
    );
  }

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      email: (map['email'] ?? '') as String,
      fullName: (map['full_name'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      emergencyVetName: (map['emergency_vet_name'] ?? '') as String,
      emergencyVetPhone: (map['emergency_vet_phone'] ?? '') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'emergency_vet_name': emergencyVetName,
      'emergency_vet_phone': emergencyVetPhone,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  ProfileModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? emergencyVetName,
    String? emergencyVetPhone,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      emergencyVetName: emergencyVetName ?? this.emergencyVetName,
      emergencyVetPhone: emergencyVetPhone ?? this.emergencyVetPhone,
    );
  }
}
