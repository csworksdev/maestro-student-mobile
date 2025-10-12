import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:maestro_client_mobile/services/auth_service.dart';

class ApiClient {
  static const String BASE_URL = "https://api.maestroswim.com/";
  final AuthService _authService = AuthService();

  // Request dengan auto refresh token
  Future<http.Response> _requestWithTokenRefresh({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    try {
      String? token = await _authService.getToken();
      if (token == null) {
        throw Exception("Token tidak ditemukan. Silakan login kembali.");
      }

      Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      if (additionalHeaders != null) {
        headers.addAll(additionalHeaders);
      }

      final uri = Uri.parse(endpoint.startsWith('http') ? endpoint : BASE_URL + endpoint);
      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: body != null ? json.encode(body) : null);
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: body != null ? json.encode(body) : null);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception("Metode HTTP tidak didukung: $method");
      }

      // Jika token expired, refresh dan ulangi request
      if (response.statusCode == 401) {
        final newToken = await _authService.refreshToken();
        if (newToken == null) {
          throw Exception("Gagal memperbarui token. Silakan login kembali.");
        }

        headers['Authorization'] = 'Bearer $newToken';
        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(uri, headers: headers);
            break;
          case 'POST':
            response = await http.post(uri, headers: headers, body: body != null ? json.encode(body) : null);
            break;
          case 'PUT':
            response = await http.put(uri, headers: headers, body: body != null ? json.encode(body) : null);
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: headers);
            break;
        }
      }

      return response;
    } catch (e) {
      print("❌ Error API request ($method $endpoint): $e");
      rethrow;
    }
  }

  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    return _requestWithTokenRefresh(method: 'GET', endpoint: endpoint, additionalHeaders: headers);
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return _requestWithTokenRefresh(method: 'POST', endpoint: endpoint, body: body, additionalHeaders: headers);
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return _requestWithTokenRefresh(method: 'PUT', endpoint: endpoint, body: body, additionalHeaders: headers);
  }

  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    return _requestWithTokenRefresh(method: 'DELETE', endpoint: endpoint, additionalHeaders: headers);
  }
}

class ApiService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiClient _apiClient = ApiClient();

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<Map<String, String>> getHeaders() async {
    String? token = await getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    final response = await _apiClient.get('trainer/$userId/');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("⚠️ Gagal load profile: ${response.statusCode}");
      throw Exception('Failed to load profile');
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    const String url = "https://api.maestroswim.com/auth/users/login/";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("⚠️ Login gagal: ${response.statusCode}, body: ${response.body}");
        throw Exception("Login failed with status: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Login error: $e");
      throw Exception("Login failed: $e");
    }
  }
}
