import 'dart:convert';
import 'dart:developer' as developer;

import 'package:maestro_client_mobile/models/student_package.dart';
import 'package:maestro_client_mobile/services/api_service.dart';

class PackageService {
  final ApiClient _apiClient = ApiClient();

  Future<List<StudentPackage>> getOngoingPackages() async {
    return _fetchPackages('siswa/packages/ongoing/');
  }

  Future<List<StudentPackage>> getTodoPackages() async {
    return _fetchPackages('siswa/packages/todo/');
  }

  Future<List<StudentPackage>> getDonePackages() async {
    return _fetchPackages('siswa/packages/done/');
  }

  Future<List<StudentPackage>> _fetchPackages(String endpoint) async {
    try {
      final response = await _apiClient.get(endpoint);

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.toLowerCase().contains('application/json')) {
        final snippet = response.body.length > 200 ? response.body.substring(0, 200) : response.body;
        developer.log('Non-JSON response for $endpoint [${response.statusCode}]: $snippet', name: 'PackageService');
        throw Exception('Gagal memuat data. Silakan coba lagi.');
      }

      dynamic decoded;
      try {
        decoded = json.decode(response.body);
      } catch (e) {
        developer.log('Gagal decode JSON $endpoint: ${response.body}', name: 'PackageService', error: e);
        throw Exception('Gagal memuat data. Silakan coba lagi.');
      }

      final Map<String, dynamic> responseData = decoded is Map<String, dynamic>
          ? decoded
          : {
              'data': decoded,
              'status': response.statusCode == 200,
            };

      if (response.statusCode == 200 && (responseData['status'] == true || responseData['status'] == 200)) {
        final List<dynamic> dataList = responseData['data'] ?? [];
        return dataList.map((e) => StudentPackage.fromJson(e as Map<String, dynamic>)).toList();
      }

      developer.log('API Error $endpoint: ${response.statusCode} - ${responseData['message'] ?? 'Tidak ada pesan error'}',
          name: 'PackageService', error: responseData);
      throw Exception('Gagal memuat data. Silakan coba lagi.');
    } catch (e) {
      developer.log('Error fetchPackages($endpoint): $e', name: 'PackageService', error: e);
      // Jika error sudah berupa Exception dengan pesan user-friendly, lempar ulang
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Gagal memuat data. Silakan coba lagi.');
    }
  }
}
