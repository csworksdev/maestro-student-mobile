import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:maestro_client_mobile/services/auth_service.dart';

class ApiClient {
  static const String BASE_URL = "https://api.maestroswim.com/";
  final AuthService _authService = AuthService();
  
  // Konfigurasi timeout dan retry
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 2);

  // Request dengan auto refresh token, timeout, dan retry mechanism
  Future<http.Response> _requestWithTokenRefresh({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    Map<String, String>? additionalHeaders,
    int retryCount = 0,
  }) async {
    try {
      String? token = await _authService.getToken();
      if (token == null) {
        throw Exception("Sesi Anda telah berakhir. Silakan login kembali.");
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

      try {
        // Tambahkan timeout untuk setiap request
        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(uri, headers: headers).timeout(_timeout);
            break;
          case 'POST':
            response = await http.post(uri, headers: headers, body: body != null ? json.encode(body) : null).timeout(_timeout);
            break;
          case 'PUT':
            response = await http.put(uri, headers: headers, body: body != null ? json.encode(body) : null).timeout(_timeout);
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: headers).timeout(_timeout);
            break;
          default:
            throw Exception("Metode HTTP tidak didukung: $method");
        }
      } on TimeoutException {
        print("⏱️ Request timeout ($method $endpoint) - Retry $retryCount/$_maxRetries");
        if (retryCount < _maxRetries) {
          await Future.delayed(_retryDelay);
          return _requestWithTokenRefresh(
            method: method,
            endpoint: endpoint,
            body: body,
            additionalHeaders: additionalHeaders,
            retryCount: retryCount + 1,
          );
        }
        throw Exception("Koneksi internet Anda terlalu lambat. Silakan coba lagi.");
      } on SocketException {
        print("🌐 Network error ($method $endpoint) - Retry $retryCount/$_maxRetries");
        if (retryCount < _maxRetries) {
          await Future.delayed(_retryDelay);
          return _requestWithTokenRefresh(
            method: method,
            endpoint: endpoint,
            body: body,
            additionalHeaders: additionalHeaders,
            retryCount: retryCount + 1,
          );
        }
        throw Exception("Tidak ada koneksi internet. Periksa WiFi atau data seluler Anda.");
      }

      // Jika token expired, refresh dan ulangi request
      if (response.statusCode == 401) {
        print("🔄 Token expired, mencoba refresh token...");
        final newToken = await _authService.refreshToken();
        if (newToken == null) {
          print("❌ Refresh token gagal");
          throw Exception("Sesi Anda telah berakhir. Silakan login kembali.");
        }

        print("✅ Token berhasil di-refresh, mengulang request...");
        headers['Authorization'] = 'Bearer $newToken';
        
        try {
          switch (method.toUpperCase()) {
            case 'GET':
              response = await http.get(uri, headers: headers).timeout(_timeout);
              break;
            case 'POST':
              response = await http.post(uri, headers: headers, body: body != null ? json.encode(body) : null).timeout(_timeout);
              break;
            case 'PUT':
              response = await http.put(uri, headers: headers, body: body != null ? json.encode(body) : null).timeout(_timeout);
              break;
            case 'DELETE':
              response = await http.delete(uri, headers: headers).timeout(_timeout);
              break;
          }
        } on TimeoutException {
          throw Exception("Koneksi internet Anda terlalu lambat. Silakan coba lagi.");
        } on SocketException {
          throw Exception("Tidak ada koneksi internet. Periksa WiFi atau data seluler Anda.");
        }
      }

      // Handle server errors dengan retry
      if (response.statusCode >= 500 && response.statusCode < 600) {
        print("🔴 Server error ${response.statusCode} ($method $endpoint) - Retry $retryCount/$_maxRetries");
        if (retryCount < _maxRetries) {
          await Future.delayed(_retryDelay);
          return _requestWithTokenRefresh(
            method: method,
            endpoint: endpoint,
            body: body,
            additionalHeaders: additionalHeaders,
            retryCount: retryCount + 1,
          );
        }
        throw Exception("Server sedang sibuk. Silakan tunggu beberapa saat dan coba lagi.");
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
      throw Exception('Gagal memuat profil. Silakan coba lagi.');
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    const String url = "https://api.maestroswim.com/auth/users/login/";

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"username": username, "password": password}),
      ).timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        print("⚠️ Login gagal: Username atau password salah");
        throw Exception("Username atau password salah. Silakan coba lagi.");
      } else {
        print("⚠️ Login gagal: ${response.statusCode}, body: ${response.body}");
        throw Exception("Login gagal. Silakan coba lagi.");
      }
    } on TimeoutException {
      print("⏱️ Login timeout");
      throw Exception("Koneksi internet Anda terlalu lambat. Silakan coba lagi.");
    } on SocketException {
      print("🌐 Login network error");
      throw Exception("Tidak ada koneksi internet. Periksa WiFi atau data seluler Anda.");
    } catch (e) {
      print("❌ Login error: $e");
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception("Terjadi kesalahan. Silakan coba lagi.");
    }
  }
}
