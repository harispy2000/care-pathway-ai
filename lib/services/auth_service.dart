import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../core/api_client.dart';
import '../models/auth_user.dart';
import 'firebase_notification_service.dart';

class AuthService {
  static const String _userKey = "logged_in_user";
  static final ApiClient _apiClient = ApiClient();

  static Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final data = await _apiClient.postJson(ApiConfig.registerUrl, {
      "fullName": fullName,
      "email": email,
      "password": password,
    });

    final user = AuthUser.fromJson(data);
    await saveUser(user);
    await _saveFcmTokenForUser(user.userId);
    return user;
  }

  static Future<AuthUser> login({required String email, required String password}) async {
    final data = await _apiClient.postJson(ApiConfig.loginUrl, {
      "email": email,
      "password": password,
    });

    final user = AuthUser.fromJson(data);
    await saveUser(user);
    await _saveFcmTokenForUser(user.userId);
    return user;
  }

  static Future<void> saveUser(AuthUser user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  static Future<AuthUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return AuthUser.fromJson(jsonDecode(userJson));
  }

  static Future<int?> getCurrentUserId() async => (await getCurrentUser())?.userId;

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  static Future<void> _saveFcmTokenForUser(int userId) async {
    try {
      final token = await FirebaseNotificationService.instance.getToken();
      if (token == null || token.trim().isEmpty) return;
      await _apiClient.postJson(ApiConfig.saveFcmTokenUrl, {
        "userId": userId,
        "fcmToken": token,
      });
    } catch (e) {
      debugPrint("Failed to save FCM token: $e");
    }
  }
}
