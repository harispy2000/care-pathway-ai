class PatientProfile {
  final int userId;
  final int age;
  final String gender;
  final String phoneNumber;
  final String bloodGroup;
  final String existingConditions;
  final String medications;
  final String allergies;
  final String emergencyContactName;
  final String emergencyContactNumber;

  PatientProfile({
    required this.userId,
    required this.age,
    required this.gender,
    required this.phoneNumber,
    required this.bloodGroup,
    required this.existingConditions,
    required this.medications,
    required this.allergies,
    required this.emergencyContactName,
    required this.emergencyContactNumber,
  });

  factory PatientProfile.fromJson(Map<String, dynamic> json) {
    return PatientProfile(
      userId: json["userId"] ?? 0,
      age: json["age"] ?? 0,
      gender: json["gender"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      bloodGroup: json["bloodGroup"] ?? "",
      existingConditions: json["existingConditions"] ?? "",
      medications: json["medications"] ?? "",
      allergies: json["allergies"] ?? "",
      emergencyContactName: json["emergencyContactName"] ?? "",
      emergencyContactNumber: json["emergencyContactNumber"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "userId": userId,
        "age": age,
        "gender": gender,
        "phoneNumber": phoneNumber,
        "bloodGroup": bloodGroup,
        "existingConditions": existingConditions,
        "medications": medications,
        "allergies": allergies,
        "emergencyContactName": emergencyContactName,
        "emergencyContactNumber": emergencyContactNumber,
      };
}
