import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:maestro_client_mobile/services/auth_service.dart';

class ApiClient {
  static const String BASE_URL = "https://api.maestroswim.com/api/";
  final AuthService _authService = AuthService();
  
  // Metode untuk melakukan HTTP request dengan refresh token otomatis
  Future<http.Response> _requestWithTokenRefresh({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
  }) async {
    // Dapatkan token
    String? token = await _authService.getToken();
    if (token == null) {
      throw Exception("Token tidak ditemukan. Harap login kembali.");
    }
    
    // Buat headers
    Map<String, String> headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    
    // Tambahkan headers tambahan jika ada
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    
    // Buat URI
    final uri = Uri.parse(endpoint.startsWith('http') ? endpoint : BASE_URL + endpoint);
    
    // Lakukan request
    http.Response response;
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          uri, 
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'PUT':
        response = await http.put(
          uri, 
          headers: headers,
          body: body != null ? json.encode(body) : null,
        );
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception("Metode HTTP tidak didukung: $method");
    }
    
    // Jika token tidak valid (401), coba refresh token dan ulangi request
    if (response.statusCode == 401) {
      // Coba refresh token
      final newToken = await _authService.refreshToken();
      if (newToken == null) {
        throw Exception("Gagal memperbarui token. Harap login kembali.");
      }
      
      // Update header dengan token baru
      headers['Authorization'] = 'Bearer $newToken';
      
      // Ulangi request dengan token baru
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri, 
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri, 
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception("Metode HTTP tidak didukung: $method");
      }
    }
    
    return response;
  }
  
  // GET request dengan refresh token
  Future<http.Response> get(String endpoint, {Map<String, String>? headers}) async {
    return _requestWithTokenRefresh(
      method: 'GET',
      endpoint: endpoint,
      additionalHeaders: headers,
    );
  }
  
  // POST request dengan refresh token
  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return _requestWithTokenRefresh(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      additionalHeaders: headers,
    );
  }
  
  // PUT request dengan refresh token
  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) async {
    return _requestWithTokenRefresh(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      additionalHeaders: headers,
    );
  }
  
  // DELETE request dengan refresh token
  Future<http.Response> delete(String endpoint, {Map<String, String>? headers}) async {
    return _requestWithTokenRefresh(
      method: 'DELETE',
      endpoint: endpoint,
      additionalHeaders: headers,
    );
  }
}

class ApiService {
  static const String BASE_URL = "https://api.maestroswim.com/api/";
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiClient _apiClient = ApiClient();

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    final response = await _apiClient.get('trainer/$userId/');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }
  
  Future<Map<String, dynamic>> login(String username, String password) async {
    final String url = "https://api.maestroswim.com/auth/users/login/";

    try {
      final response = await _apiClient.post(
        url,
        body: {
          "username": username,
          "password": password
        }
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Login failed with status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }
}
