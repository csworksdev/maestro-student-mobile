import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maestro_client_mobile/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  String? _userId;
  String? _token;

  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get token => _token;

  AuthProvider() {
    checkLoginStatus();
  }

  Future<bool> login(String username, String password) async {
    try {
      final result = await _authService.login(username, password);

      if (result['success']) {
        _isLoggedIn = true;
        _userId = result['userId'];
        _token = result['token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', _userId!);
        if (_token != null) await prefs.setString('token', _token!);
        
        // Simpan waktu login sebagai waktu refresh pertama
        await prefs.setInt('last_token_refresh', DateTime.now().millisecondsSinceEpoch);

        notifyListeners();
        return true;
      }
    } catch (e) {
      // Handle error silently
    }

    return false;
  }


  Future<void> logout() async {
    try {
      await _authService.logout(); 
    } catch (e) {
      // Handle error silently
    }

    _isLoggedIn = false;
    _userId = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userId = prefs.getString('userId');
      _token = prefs.getString('token');
      
      // Cek apakah token perlu di-refresh berdasarkan waktu terakhir refresh
      if (_isLoggedIn && _token != null) {
        final lastRefresh = prefs.getInt('last_token_refresh') ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        final minutesSinceRefresh = (now - lastRefresh) / 1000 / 60;
        
        // Jika lebih dari 30 menit sejak refresh terakhir, refresh token
        if (minutesSinceRefresh > 30) {
          print('🔄 Token sudah $minutesSinceRefresh menit, perlu refresh...');
          await refreshTokenIfNeeded();
        }
      }
    } catch (e) {
      _isLoggedIn = false;
      _userId = null;
      _token = null;
    }

    notifyListeners();
  }

  /// Refresh token jika diperlukan (proaktif)
  Future<bool> refreshTokenIfNeeded() async {
    try {
      if (!_isLoggedIn) {
        return false;
      }

      // Coba refresh token
      final newToken = await _authService.refreshToken();
      
      if (newToken != null) {
        _token = newToken;
        
        // Update token di SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', newToken);
        
        notifyListeners();
        return true;
      } else {
        // Jika refresh gagal, logout user
        await logout();
        return false;
      }
    } catch (e) {
      print('⚠️ Error refreshing token: $e');
      return false;
    }
  }
}