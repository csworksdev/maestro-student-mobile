import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
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
    bool isRetryAfterRefresh = false,
  }) async {
    String? token;
    if (!isRetryAfterRefresh) {
      token = await _authService.getToken();
      if (token == null) {
        // Coba refresh token jika token awal tidak ada
        print("ℹ️ Token tidak ditemukan, mencoba refresh...");
        token = await _authService.refreshToken();
        if (token == null) {
          throw Exception("Sesi Anda telah berakhir. Silakan login kembali.");
        }
      }
    } else {
      // Jika ini adalah percobaan ulang setelah refresh, kita sudah mendapatkan token baru
      token = await _authService.getToken();
    }

    if (token == null) {
      throw Exception("Sesi Anda telah berakhir. Silakan login kembali.");
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      if (additionalHeaders != null) ...additionalHeaders,
    };

    final uri = Uri.parse(endpoint.startsWith('http') ? endpoint : BASE_URL + endpoint);
    
    try {
      http.Response response;
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

      // Jika token expired, refresh dan ulangi request
      if (response.statusCode == 401) {
        print("🔄 Token expired, mencoba refresh token...");
        final newToken = await _authService.refreshToken();
        if (newToken == null || newToken == token) {
          print("❌ Refresh token gagal atau token tidak berubah.");
          throw Exception("Gagal menyegarkan sesi. Silakan coba lagi.");
        }

        print("✅ Token berhasil di-refresh, mengulang request...");
        
        return _requestWithTokenRefresh(
          method: method,
          endpoint: endpoint,
          body: body,
          additionalHeaders: additionalHeaders,
          retryCount: retryCount,
        );
      }

      // Handle server errors dengan retry
      if (response.statusCode >= 500 && response.statusCode < 600) {
        print("🔴 Server error ${response.statusCode} ($method $endpoint) - Retry $retryCount/$_maxRetries");
        await Future.delayed(_retryDelay);
        return _requestWithTokenRefresh(
          method: method,
          endpoint: endpoint,
          body: body,
          additionalHeaders: additionalHeaders,
          retryCount: retryCount + 1,
          isRetryAfterRefresh: isRetryAfterRefresh,
        );
      }

      return response;

    } on TimeoutException {
      if (retryCount < _maxRetries) {
        print("⏱️ Request timeout ($method $endpoint) - Retry $retryCount/$_maxRetries");
        await Future.delayed(_retryDelay);
        return _requestWithTokenRefresh(
          method: method,
          endpoint: endpoint,
          body: body,
          additionalHeaders: additionalHeaders,
          retryCount: retryCount + 1,
          isRetryAfterRefresh: isRetryAfterRefresh,
        );
      }
      throw Exception("Koneksi internet Anda terlalu lambat. Silakan coba lagi.");
    } on SocketException {
       if (retryCount < _maxRetries) {
        print("🌐 Network error ($method $endpoint) - Retry $retryCount/$_maxRetries");
        await Future.delayed(_retryDelay);
        return _requestWithTokenRefresh(
          method: method,
          endpoint: endpoint,
          body: body,
          additionalHeaders: additionalHeaders,
          retryCount: retryCount + 1,
          isRetryAfterRefresh: isRetryAfterRefresh,
        );
      }
      throw Exception("Tidak ada koneksi internet. Periksa WiFi atau data seluler Anda.");
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