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
    } catch (e) {
      _isLoggedIn = false;
      _userId = null;
      _token = null;
    }

    notifyListeners();
  }
}