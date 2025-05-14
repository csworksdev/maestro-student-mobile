import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();

  Future<Map<String, dynamic>> login(String username, String password) async {
    final String url = "https://api.maestroswim.com/auth/users/login/";

    try {
      Response response = await _dio.post(url, data: {
        "username": username,
        "password": password
        
      });

      return response.data;
    } catch (e) {
      throw Exception("Login failed: $e");
    }
  }
}
