class ApiConfig {
  // Change this one line when your API URL changes.
  static const String baseUrl = "http://localhost:5193";

  static String get registerUrl => "$baseUrl/api/auth/register";
  static String get loginUrl => "$baseUrl/api/auth/login";
  static String get saveFcmTokenUrl => "$baseUrl/api/auth/save-fcm-token";

  static String get analyzeUrl => "$baseUrl/api/care-pathway/analyze";

  static String historyUrl({int? userId}) {
    if (userId == null) return "$baseUrl/api/care-pathway/history";
    return "$baseUrl/api/care-pathway/history?userId=$userId";
  }

  static String historyByIdUrl({required int id, int? userId}) {
    if (userId == null) return "$baseUrl/api/care-pathway/history/$id";
    return "$baseUrl/api/care-pathway/history/$id?userId=$userId";
  }

  static String profileUrl(int userId) => "$baseUrl/api/profile/$userId";
  static String get saveProfileUrl => "$baseUrl/api/profile";
}
