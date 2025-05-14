import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

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
        final token = data['token'];
        final userId = data['data']['user_id'].toString();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);
        await _storage.write(key: 'token', value: token);
        await _storage.write(key: 'userId', value: userId);

        return {
          'success': true,
          'userId': userId,
          'token': token,
        };
      } else {
        debugPrint("Login failed: ${response.body}");
        return {'success': false};
      }
    } catch (e) {
      debugPrint("Login error: $e");
      return {'success': false};
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: 'userId');
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
}
