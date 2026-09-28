import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
  };

  Future<Map<String, dynamic>> getJson(String url) async {
    final response = await http.get(Uri.parse(url), headers: _headers);
    return _handleMapResponse(response);
  }

  Future<List<dynamic>> getList(String url) async {
    final response = await http.get(Uri.parse(url), headers: _headers);
    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> postJson(String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleMapResponse(response);
  }

  Map<String, dynamic> _handleMapResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw Exception(_errorMessage(response));
  }

  List<dynamic> _handleListResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) return [];
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception(_errorMessage(response));
  }

  String _errorMessage(http.Response response) {
    if (response.body.trim().isEmpty) {
      return "Request failed with status ${response.statusCode}";
    }
    return response.body;
  }
}
