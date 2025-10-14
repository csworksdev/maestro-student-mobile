import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maestro_client_mobile/services/notification_service.dart';

class AuthService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _baseUrl = "https://api.maestroswim.com/auth/users";

  /// Melakukan login ke API dan menyimpan token serta user ID
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = Uri.parse('$_baseUrl/login/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final accessToken = data['access'];
        final refreshToken = data['refresh'];
        final userId = data['data']['user_id'].toString();

        // Tampilkan auth token di debug console
        print('AUTH TOKEN: $accessToken');

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('username', username);

        await _storage.write(key: 'token', value: accessToken);
        await _storage.write(key: 'refreshToken', value: refreshToken);
        await _storage.write(key: 'userId', value: userId);

        // Dapatkan FCM token yang sudah tersimpan dan kirim ke API
        final notificationService = NotificationService();
        final fcmToken = await notificationService.getSavedToken();
        
        if (fcmToken != null) {
          // Kirim FCM token ke API setelah login berhasil
          await notificationService.sendTokenToApi(fcmToken, accessToken);
        } else {
          // Jika token belum tersimpan, coba dapatkan token baru
          final newToken = await notificationService.getToken();
          if (newToken != null) {
            await notificationService.sendTokenToApi(newToken, accessToken);
          }
        }

        return {
          'success': true,
          'userId': userId,
          'token': accessToken,
        };
      } else if (response.statusCode == 401) {
        print("⚠️ Login gagal: Username atau password salah");
        throw Exception("Username atau password salah. Silakan coba lagi.");
      } else {
        print("⚠️ Login gagal: ${response.statusCode}, body: ${response.body}");
        throw Exception("Login gagal. Silakan coba lagi.");
      }
    } on TimeoutException {
      print("⏱️ Login timeout");
      throw Exception("Koneksi internet Anda terlalu lambat. Silakan coba lagi.");
    } on SocketException {
      print("🌐 Login network error");
      throw Exception("Tidak ada koneksi internet. Periksa WiFi atau data seluler Anda.");
    } catch (e) {
      print("❌ Login error: $e");
      if (e.toString().contains('Exception:')) {
        rethrow;
      }
      throw Exception("Terjadi kesalahan. Silakan coba lagi.");
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
        print('❌ Refresh token tidak ditemukan');
        return null;
      }
      
      print('🔄 Mencoba refresh token...');
      final url = Uri.parse('https://api.maestroswim.com/api/token/refresh/');
      
      // Tambahkan timeout untuk refresh token dengan retry
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];
        
        await _storage.write(key: 'token', value: newAccessToken);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('last_token_refresh', DateTime.now().millisecondsSinceEpoch);
        
        print('✅ Token berhasil di-refresh');
        return newAccessToken;
      } else if (response.statusCode == 401) {
        print('❌ Refresh token expired atau tidak valid - logout diperlukan');
        await logout();
        return null;
      } else {
        print('⚠️ Error refresh token: ${response.statusCode}, body: ${response.body}');
        // Melempar exception agar UI bisa menampilkan pesan "Coba Lagi"
        throw Exception('Gagal menyegarkan sesi. Silakan coba lagi.');
      }
    } on TimeoutException {
      print('⏱️ Refresh token timeout');
      throw Exception('Koneksi lambat saat menyegarkan sesi. Coba lagi.');
    } on SocketException {
      print('🌐 Network error saat refresh token');
      throw Exception('Tidak ada koneksi untuk menyegarkan sesi. Coba lagi.');
    } catch (e) {
      print('❌ Error saat refresh token: $e');
      // Melempar ulang exception yang sudah informatif
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Terjadi kesalahan saat menyegarkan sesi.');
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