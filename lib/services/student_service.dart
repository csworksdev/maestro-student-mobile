import 'dart:convert';
import 'dart:developer' as developer;

import 'package:maestro_client_mobile/models/student_profile.dart';
import 'api_service.dart';

class StudentService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getTrainerProfile(String userId) async {
    final response = await _apiClient.get('trainer/$userId/');

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print("⚠️ Gagal load profile: ${response.statusCode}");
      throw Exception('Gagal memuat profil. Silakan coba lagi.');
    }
  }

  // Mendapatkan daftar semua siswa
  Future<List<StudentProfile>> getStudents() async {
    try {
      // Gunakan ApiClient agar token otomatis diambil/di-refresh
      final response = await _apiClient.get('siswa/students/');

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.toLowerCase().contains('application/json')) {
        final snippet = response.body.length > 200
            ? response.body.substring(0, 200)
            : response.body;
        developer.log(
          'Non-JSON response for getStudents [${response.statusCode}]: $snippet',
          name: 'StudentService',
        );
        throw Exception('Gagal memuat data siswa. Silakan coba lagi.');
      }

      dynamic decoded;
      try {
        decoded = json.decode(response.body);
      } catch (e) {
        developer.log('Gagal decode JSON getStudents: ${response.body}',
            name: 'StudentService', error: e);
        throw Exception('Gagal memuat data siswa. Silakan coba lagi.');
      }

      final Map<String, dynamic> responseData =
          decoded is Map<String, dynamic>
              ? decoded
              : {
                  'data': decoded,
                  'status': response.statusCode == 200,
                };

      if (response.statusCode == 200 &&
          (responseData['status'] == true || responseData['status'] == 200)) {
        final List<dynamic> studentsData = responseData['data'] ?? [];
        return studentsData
            .map((data) => StudentProfile.fromJson(data))
            .toList();
      } else {
        developer.log(
          'API Error getStudents: ${response.statusCode} - ${responseData['message'] ?? 'Tidak ada pesan error'}',
          name: 'StudentService',
          error: responseData,
        );
        throw Exception('Gagal memuat data siswa. Silakan coba lagi.');
      }
    } catch (e) {
      developer.log('Error getStudents: $e', name: 'StudentService', error: e);
      // Jika error sudah berupa Exception dengan pesan user-friendly, lempar ulang
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception('Gagal memuat data siswa. Silakan coba lagi.');
    }
  }

  // Mendapatkan detail siswa berdasarkan ID
  Future<StudentProfile> getStudentDetail(String studentId) async {
    try {
      final response = await _apiClient.get('siswa/students/$studentId/');

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.toLowerCase().contains('application/json')) {
        final snippet = response.body.length > 200
            ? response.body.substring(0, 200)
            : response.body;
        developer.log(
          'Non-JSON response for getStudentDetail [${response.statusCode}]: $snippet',
          name: 'StudentService',
        );
        throw Exception('Respons bukan JSON (status ${response.statusCode}).');
      }

      dynamic decoded;
      try {
        decoded = json.decode(response.body);
      } catch (e) {
        developer.log('Gagal decode JSON getStudentDetail: ${response.body}',
            name: 'StudentService', error: e);
        throw Exception('Format JSON tidak valid.');
      }

      final Map<String, dynamic> responseData =
          decoded is Map<String, dynamic>
              ? decoded
              : {
                  'data': decoded,
                  'status': response.statusCode == 200,
                };

      if (response.statusCode == 200 &&
          (responseData['status'] == true || responseData['status'] == 200)) {
        return StudentProfile.fromJson(responseData['data']);
      } else {
        developer.log(
          'API Error getStudentDetail: ${response.statusCode} - ${responseData['message'] ?? 'Tidak ada pesan error'}',
          name: 'StudentService',
          error: responseData,
        );
        throw Exception(responseData['message'] ??
            'Gagal mendapatkan detail siswa (status ${response.statusCode}).');
      }
    } catch (e) {
      developer.log('Error getStudentDetail: $e',
          name: 'StudentService', error: e);
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  // Memperbarui data siswa
  Future<StudentProfile> updateStudent(
      String studentId, StudentProfile student) async {
    try {
      final response = await _apiClient.put(
        'siswa/students/$studentId/',
        body: student.toJson(),
      );

      final contentType = response.headers['content-type'] ?? '';
      if (!contentType.toLowerCase().contains('application/json')) {
        final snippet = response.body.length > 200
            ? response.body.substring(0, 200)
            : response.body;
        developer.log(
          'Non-JSON response for updateStudent [${response.statusCode}]: $snippet',
          name: 'StudentService',
        );
        throw Exception('Respons bukan JSON (status ${response.statusCode}).');
      }

      dynamic decoded;
      try {
        decoded = json.decode(response.body);
      } catch (e) {
        developer.log('Gagal decode JSON updateStudent: ${response.body}',
            name: 'StudentService', error: e);
        throw Exception('Format JSON tidak valid.');
      }

      final Map<String, dynamic> responseData =
          decoded is Map<String, dynamic>
              ? decoded
              : {
                  'data': decoded,
                  'status': response.statusCode == 200,
                };

      if (response.statusCode == 200 &&
          (responseData['status'] == true || responseData['status'] == 200)) {
        return StudentProfile.fromJson(responseData['data']);
      } else {
        throw Exception(responseData['message'] ??
            'Gagal memperbarui data siswa (status ${response.statusCode}).');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}