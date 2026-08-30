class CarePathwayRequest {
  final int? userId;
  final int age;
  final String gender;
  final String symptoms;
  final String duration;
  final String severity;
  final String existingConditions;
  final String medications;

  CarePathwayRequest({
    required this.userId,
    required this.age,
    required this.gender,
    required this.symptoms,
    required this.duration,
    required this.severity,
    required this.existingConditions,
    required this.medications,
  });

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "age": age,
        "gender": gender,
        "symptoms": symptoms,
        "duration": duration,
        "severity": severity,
        "existingConditions": existingConditions,
        "medications": medications,
      };
}
