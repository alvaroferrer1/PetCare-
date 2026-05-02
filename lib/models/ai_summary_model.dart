class AiSummaryModel {
  const AiSummaryModel({
    required this.summary,
    required this.priorities,
    required this.vetQuestions,
    required this.generalRecommendations,
    required this.safetyNotice,
    required this.createdAt,
  });

  final String summary;
  final List<String> priorities;
  final List<String> vetQuestions;
  final List<String> generalRecommendations;
  final String safetyNotice;
  final DateTime createdAt;

  factory AiSummaryModel.fromJson(Map<String, dynamic> json) {
    return AiSummaryModel(
      summary: (json['summary'] ?? '') as String,
      priorities: List<String>.from(json['priorities'] ?? const []),
      vetQuestions: List<String>.from(json['vet_questions'] ?? const []),
      generalRecommendations: List<String>.from(
        json['general_recommendations'] ?? const [],
      ),
      safetyNotice: (json['safety_notice'] ?? '') as String,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      'priorities': priorities,
      'vet_questions': vetQuestions,
      'general_recommendations': generalRecommendations,
      'safety_notice': safetyNotice,
    };
  }
}
