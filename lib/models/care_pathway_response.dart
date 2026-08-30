class CarePathwayResponse {
  final String triageLevel;
  final int riskScore;
  final String possibleCondition;
  final String recommendedAction;
  final String safetyAdvice;
  final List<String> matchedFactors;
  final List<String> redFlags;
  final List<String> careSteps;

  CarePathwayResponse({
    required this.triageLevel,
    required this.riskScore,
    required this.possibleCondition,
    required this.recommendedAction,
    required this.safetyAdvice,
    required this.matchedFactors,
    required this.redFlags,
    required this.careSteps,
  });

  factory CarePathwayResponse.fromJson(Map<String, dynamic> json) {
    return CarePathwayResponse(
      triageLevel: json["triageLevel"] ?? "",
      riskScore: json["riskScore"] ?? 0,
      possibleCondition: json["possibleCondition"] ?? "",
      recommendedAction: json["recommendedAction"] ?? "",
      safetyAdvice: json["safetyAdvice"] ?? "",
      matchedFactors: List<String>.from(json["matchedFactors"] ?? []),
      redFlags: List<String>.from(json["redFlags"] ?? []),
      careSteps: List<String>.from(json["careSteps"] ?? []),
    );
  }
}
