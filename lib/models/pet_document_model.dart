class PetDocumentModel {
  const PetDocumentModel({
    required this.id,
    required this.userId,
    required this.petId,
    required this.title,
    required this.documentType,
    required this.fileUrl,
    required this.notes,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String petId;
  final String title;
  final String documentType;
  final String fileUrl;
  final String notes;
  final DateTime createdAt;

  factory PetDocumentModel.fromMap(Map<String, dynamic> map) {
    return PetDocumentModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      petId: map['pet_id'] as String,
      title: (map['title'] ?? '') as String,
      documentType: (map['document_type'] ?? 'other') as String,
      fileUrl: (map['file_url'] ?? '') as String,
      notes: (map['notes'] ?? '') as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'pet_id': petId,
      'title': title,
      'document_type': documentType,
      'file_url': fileUrl,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
