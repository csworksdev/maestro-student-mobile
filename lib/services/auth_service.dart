import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Melakukan login ke API dan menyimpan token serta user ID
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = Uri.parse('https://api.maestroswim.com/auth/users/login/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );



      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final accessToken = data['access'];
        final refreshToken = data['refresh'];
        final userId = data['data']['user_id'].toString();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);

        await _storage.write(key: 'token', value: accessToken);
        await _storage.write(key: 'refreshToken', value: refreshToken);
        await _storage.write(key: 'userId', value: userId);



        return {
          'success': true,
          'userId': userId,
          'token': accessToken,
        };
      } else {
        return {'success': false};
      }
    } catch (e) {
      return {'success': false};
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refreshToken');
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: 'userId');
  }
  
  /// Memperbarui access token menggunakan refresh token
  Future<String?> refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        return null;
      }
      
      final url = Uri.parse('https://api.maestroswim.com/auth/users/token/refresh/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];
        
        // Simpan token baru
        await _storage.write(key: 'token', value: newAccessToken);
        return newAccessToken;
      } else {
        // Jika refresh token juga tidak valid, hapus semua token
        await logout();
        return null;
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    }
  }

  Future<String?> getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<bool> isTokenAvailable() async {
    final token = await _storage.read(key: 'token');
    return token != null && token.isNotEmpty;
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await _storage.deleteAll();
  }

  /// Mengirim OTP ke nomor WhatsApp berdasarkan username
  Future<bool> sendOtp({required String username, required String whatsappNumber}) async {
    try {
      final url = Uri.parse('https://api.maestroswim.com/auth/users/send-otp/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'whatsapp_number': whatsappNumber,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Reset password menggunakan OTP
  Future<bool> resetPasswordWithOtp({
    required String otp,
    required String username,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse('https://api.maestroswim.com/auth/users/reset-password/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'otp': otp,
          'username': username,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}