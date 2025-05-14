import 'dart:convert';
import 'package:http/http.dart' as http;

class AbsensiService {
  static const String BASE_URL = "https://api.maestroswim.com/api/presence/";

  static Future<List<dynamic>> fetchAbsensi(String userId) async {
    final url = Uri.parse('$BASE_URL$userId/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else if (response.statusCode == 404) {
        throw Exception("Data absensi tidak ditemukan");
      } else {
        throw Exception("Terjadi kesalahan: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}