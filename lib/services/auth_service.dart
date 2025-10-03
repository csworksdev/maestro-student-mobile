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
  Future<Map<String, dynamic>> sendOtp({required String username}) async {
    try {
      final url = Uri.parse('https://api.maestroswim.com/auth/users/send_otp/');
      print('🔐 Mengirim permintaan OTP untuk username: $username');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
        }),
      );

      // Log respons lengkap untuk debugging
      print('📩 Respons OTP [${response.statusCode}]: ${response.body}');

      final responseData = jsonDecode(response.body);
      
      // Mengikuti format JSON yang diharapkan oleh backend
      if (response.statusCode == 200) {
        // Cek status dari response body
        if (responseData['status'] == true) {
          // Tampilkan kode OTP jika ada dalam respons (untuk debugging)
          if (responseData.containsKey('otp')) {
            print('🔑 KODE OTP: ${responseData['otp']}');
          }
          
          print('✅ OTP berhasil dikirim');
          return {
            'success': true,
            'status': responseData['status'],
            'message': responseData['message'] ?? 'OTP sent to your WhatsApp',
            'data': responseData['data'] ?? {
              'status': 'OTP sent to your WhatsApp',
              'otp_id': responseData['data']?['otp_id'] ?? '',
              'phone': responseData['data']?['phone'] ?? '',
              'expires_at': responseData['data']?['expires_at'] ?? '',
            },
            'meta': responseData['meta'] ?? {},
            'error': responseData['error'] ?? [],
          };
        } else {
          // Response dengan status false
          print('❌ Gagal mengirim OTP: ${responseData['message']}');
          return {
            'success': false,
            'status': responseData['status'],
            'message': responseData['message'] ?? 'Pengguna tidak ditemukan',
            'data': responseData['data'] ?? {},
            'meta': responseData['meta'] ?? {},
            'error': responseData['error'] ?? {},
          };
        }
      }
      
      print('❌ Gagal mengirim OTP. Status: ${response.statusCode}');
      return {
        'success': false,
        'status': false,
        'message': 'Gagal mengirim OTP. Silakan coba lagi.',
        'data': {},
        'meta': {},
        'error': {},
      };
    } catch (e) {
      print('🚨 Error saat mengirim OTP: $e');
      return {
        'success': false,
        'status': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
        'data': {},
        'meta': {},
        'error': {},
      };
    }
  }

  /// Verifikasi kode OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String otpId,
    required String otp,
  }) async {
    try {
      final url = Uri.parse('https://api.maestroswim.com/auth/users/verification_otp/');
      print('🔍 Verifikasi OTP: ID=$otpId, Kode=$otp');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'otp_id': otpId,
          'otp': int.parse(otp),
        }),
      );

      // Log respons lengkap untuk debugging
      print('📩 Respons Verifikasi OTP [${response.statusCode}]: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        print('✅ Verifikasi OTP berhasil');
        return {
          'success': true,
          'message': data['data']['message'] ?? 'OTP berhasil diverifikasi',
        };
      }
      
      print('❌ Verifikasi OTP gagal. Status: ${response.statusCode}');
      return {
        'success': false,
        'message': 'Verifikasi OTP gagal. Kode OTP mungkin salah atau sudah kadaluarsa.',
      };
    } catch (e) {
      print('🚨 Error saat verifikasi OTP: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }

  /// Reset password menggunakan OTP
  Future<Map<String, dynamic>> resetPasswordWithOtp({
    required String otpId,
    required String newPassword,
  }) async {
    try {
      final url = Uri.parse('https://api.maestroswim.com/auth/users/reset_password/');
      print('🔄 Reset password dengan OTP ID: $otpId');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'otp_id': otpId,
          'new_password': newPassword,
        }),
      );

      // Log respons untuk debugging
      print('📩 Respons Reset Password [${response.statusCode}]: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        print('✅ Reset password berhasil');
        return {
          'success': true,
          'message': data['message'] ?? 'Password berhasil direset',
        };
      }
      
      print('❌ Gagal reset password. Status: ${response.statusCode}');
      return {
        'success': false,
        'message': 'Gagal mereset password. Silakan coba lagi.',
      };
    } catch (e) {
      print('🚨 Error saat reset password: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
}