import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static const String _lanIp = '192.168.1.6';

  static const String _envBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    if (_envBaseUrl.isNotEmpty) return _envBaseUrl;
    return kIsWeb ? 'http://localhost:5193' : 'http://$_lanIp:5193';
  }

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
