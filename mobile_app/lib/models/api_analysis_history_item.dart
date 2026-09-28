class ApiAnalysisHistoryItem {
  final int id;
  final int? userId;
  final String symptoms;
  final String triageLevel;
  final int riskScore;
  final String recommendedAction;
  final DateTime createdAt;

  ApiAnalysisHistoryItem({
    required this.id,
    required this.userId,
    required this.symptoms,
    required this.triageLevel,
    required this.riskScore,
    required this.recommendedAction,
    required this.createdAt,
  });

  factory ApiAnalysisHistoryItem.fromJson(Map<String, dynamic> json) {
    return ApiAnalysisHistoryItem(
      id: json["id"] ?? 0,
      userId: json["userId"],
      symptoms: json["symptoms"] ?? "",
      triageLevel: json["triageLevel"] ?? "",
      riskScore: json["riskScore"] ?? 0,
      recommendedAction: json["recommendedAction"] ?? "",
      createdAt: DateTime.tryParse(json["createdAt"] ?? "") ?? DateTime.now(),
    );
  }
}
