enum CareEventType {
  vaccine('Vacuna'),
  vetVisit('Visita veterinaria'),
  medication('Medicacion'),
  food('Alimentacion'),
  grooming('Peluqueria'),
  deworming('Desparasitacion'),
  other('Otro');

  const CareEventType(this.label);
  final String label;

  String get dbValue {
    return switch (this) {
      CareEventType.vetVisit => 'vet_visit',
      _ => name,
    };
  }

  static CareEventType fromDb(String value) {
    if (value == 'vet_visit') return CareEventType.vetVisit;
    return CareEventType.values.firstWhere(
      (item) => item.name == value,
      orElse: () => CareEventType.other,
    );
  }
}

enum CareEventStatus {
  pending('Pendiente'),
  completed('Completado'),
  cancelled('Cancelado');

  const CareEventStatus(this.label);
  final String label;

  static CareEventStatus fromDb(String value) =>
      CareEventStatus.values.firstWhere(
        (item) => item.name == value,
        orElse: () => CareEventStatus.pending,
      );
}

class CareEventModel {
  const CareEventModel({
    required this.id,
    required this.userId,
    required this.petId,
    required this.type,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String petId;
  final CareEventType type;
  final String title;
  final String description;
  final DateTime eventDate;
  final CareEventStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory CareEventModel.fromMap(Map<String, dynamic> map) {
    return CareEventModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      petId: map['pet_id'] as String,
      type: CareEventType.fromDb(map['type'] as String),
      title: map['title'] as String,
      description: (map['description'] ?? '') as String,
      eventDate: DateTime.parse(map['event_date'] as String),
      status: CareEventStatus.fromDb(map['status'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id.isNotEmpty) 'id': id,
      'user_id': userId,
      'pet_id': petId,
      'type': type.dbValue,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CareEventModel copyWith({
    String? id,
    CareEventStatus? status,
    DateTime? updatedAt,
  }) {
    return CareEventModel(
      id: id ?? this.id,
      userId: userId,
      petId: petId,
      type: type,
      title: title,
      description: description,
      eventDate: eventDate,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
