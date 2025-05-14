import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/auth_provider.dart';

class EarningsProvider extends ChangeNotifier {
  List<dynamic> _earnings = [];

  List<dynamic> get earnings => _earnings;

  Future<void> fetchEarnings(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) return;

    final url = Uri.parse('https://api.maestroswim.com/api/earning/list/$userId/');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
          _earnings = responseData['data'];
        } else if (responseData is List) {
          _earnings = responseData;
        } else {
          throw Exception("Format data tidak sesuai");
        }

        notifyListeners();
      } else {
        throw Exception("Gagal mengambil data: ${response.statusCode}");
      }
    } catch (error) {
      print("Error fetching trainer earnings: $error");
      throw Exception("Error: $error");
    }
  }
}
