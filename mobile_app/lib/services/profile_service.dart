import '../config/api_config.dart';
import '../core/api_client.dart';
import '../models/patient_profile.dart';
import 'auth_service.dart';

class ProfileService {
  final ApiClient _apiClient = ApiClient();

  Future<PatientProfile?> getProfile() async {
    final userId = await AuthService.getCurrentUserId();
    if (userId == null) return null;

    try {
      final data = await _apiClient.getJson(ApiConfig.profileUrl(userId));
      return PatientProfile.fromJson(data);
    } catch (e) {
      if (e.toString().toLowerCase().contains("404")) return null;
      rethrow;
    }
  }

  Future<PatientProfile> saveProfile({
    required int age,
    required String gender,
    required String phoneNumber,
    required String bloodGroup,
    required String existingConditions,
    required String medications,
    required String allergies,
    required String emergencyContactName,
    required String emergencyContactNumber,
  }) async {
    final userId = await AuthService.getCurrentUserId();
    if (userId == null) throw Exception("User not logged in");

    final profile = PatientProfile(
      userId: userId,
      age: age,
      gender: gender,
      phoneNumber: phoneNumber,
      bloodGroup: bloodGroup,
      existingConditions: existingConditions,
      medications: medications,
      allergies: allergies,
      emergencyContactName: emergencyContactName,
      emergencyContactNumber: emergencyContactNumber,
    );

    final data = await _apiClient.postJson(ApiConfig.saveProfileUrl, profile.toJson());
    return PatientProfile.fromJson(data);
  }
}
