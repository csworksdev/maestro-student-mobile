

import 'dart:convert';
import 'package:http/http.dart' as http;

class AktivasiAkunService {
  // URL API - Perlu dikonfirmasi dengan tim backend
  // Error 404 menunjukkan endpoint tidak ditemukan
  static const String BASE_URL = "https://api.maestroswim.com/api";

  /// Mengirim kode OTP untuk aktivasi akun
  Future<Map<String, dynamic>> sendOTP(String phone) async {
    try {
      final url = Uri.parse('https://api.maestroswim.com/auth/users/activation_send_otp/');
      print('🔐 Mengirim permintaan OTP untuk nomor: $phone');
      
      final response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{'phone': phone}),
      );

      // Periksa status code terlebih dahulu
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          
          // Format respons sesuai dengan API
          return {
            'success': responseData['status'] ?? false,
            'message': responseData['message'] ?? 'Kode OTP berhasil dikirim ke WhatsApp nomor $phone',
            'data': responseData['data'] ?? {
              'otp_id': '',
              'phone': phone,
              'expires_at': ''
            },
            'meta': responseData['meta'] ?? {},
            'error': responseData['error'] ?? []
          };
        } catch (e) {
          // Jika gagal parsing JSON tapi status code OK
          return {
            'success': false,
            'message': 'Format respons tidak valid: ${response.body.substring(0, 50)}...',
            'data': {},
            'meta': {},
            'error': ['Format respons tidak valid']
          };
        }
      } else {
        // Coba parse response body, jika gagal tampilkan response body mentah
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': false,
            'message': responseData['message'] ?? 'Gagal mengirim kode OTP (${response.statusCode})',
            'data': {},
            'meta': {},
            'error': responseData['error'] ?? ['Gagal mengirim kode OTP']
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Gagal mengirim kode OTP (${response.statusCode})',
            'data': {},
            'meta': {},
            'error': ['Gagal mengirim kode OTP: ${response.statusCode}']
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengirim kode OTP: ${e.toString()}',
        'data': {},
        'meta': {},
        'error': ['Gagal mengirim kode OTP: ${e.toString()}']
      };
    }
  }
  
  /// Mengirim OTP ke nomor WhatsApp berdasarkan username
  Future<Map<String, dynamic>> sendOtpByUsername({required String username}) async {
    try {
      final url = Uri.parse('https://api.maestroswim.com/auth/users/send_otp/');
      print('🔐 Mengirim permintaan OTP untuk username: $username');
      
      final response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'username': username,
        }),
      );

      // Periksa status code terlebih dahulu
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          
          // Format respons sesuai dengan API
          return {
            'success': responseData['status'] ?? false,
            'message': responseData['message'] ?? 'Kode OTP berhasil dikirim',
            'data': responseData['data'] ?? {
              'otp_id': '',
              'phone': '',
              'expires_at': ''
            },
            'meta': responseData['meta'] ?? {},
            'error': responseData['error'] ?? []
          };
        } catch (e) {
          // Jika gagal parsing JSON tapi status code OK
          return {
            'success': false,
            'message': 'Format respons tidak valid: ${response.body.substring(0, 50)}...',
            'data': {},
            'meta': {},
            'error': ['Format respons tidak valid']
          };
        }
      } else {
        // Coba parse response body, jika gagal tampilkan response body mentah
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': false,
            'message': responseData['message'] ?? 'Gagal mengirim kode OTP (${response.statusCode})',
            'data': {},
            'meta': {},
            'error': responseData['error'] ?? ['Gagal mengirim kode OTP']
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Gagal mengirim kode OTP (${response.statusCode})',
            'data': {},
            'meta': {},
            'error': ['Gagal mengirim kode OTP: ${response.statusCode}']
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengirim kode OTP: ${e.toString()}',
        'data': {},
        'meta': {},
        'error': ['Gagal mengirim kode OTP: ${e.toString()}']
      };
    }
  }

  /// Verifikasi kode OTP
  Future<Map<String, dynamic>> verifyOTP(String otpId, String otpCode) async {
    try {
      final url = Uri.parse('https://api.maestroswim.com/auth/users/activation_verification_otp/');
      print('🔐 Memverifikasi OTP dengan ID: $otpId dan kode: $otpCode');
      
      final response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'otp_id': otpId,
          'otp': otpCode,
        }),
      );

      // Periksa status code terlebih dahulu
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          
          // Format respons sesuai dengan API
          return {
            'success': responseData['status'] ?? false,
            'message': responseData['message'] ?? 'Verifikasi Kode OTP berhasil',
            'data': responseData['data'] ?? {
              'otp_id': otpId,
              'phone': ''
            },
            'meta': responseData['meta'] ?? {},
            'error': responseData['error'] ?? []
          };
        } catch (e) {
          // Jika gagal parsing JSON tapi status code OK
          return {
            'success': false,
            'message': 'Format respons tidak valid: ${response.body.substring(0, 50)}...',
            'data': {},
            'meta': {},
            'error': ['Format respons tidak valid']
          };
        }
      } else {
        // Coba parse response body, jika gagal tampilkan response body mentah
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': false,
            'message': responseData['message'] ?? 'Kode OTP tidak valid (${response.statusCode})',
            'data': {},
            'meta': {},
            'error': responseData['error'] ?? ['Kode OTP tidak valid']
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Gagal memverifikasi OTP (${response.statusCode})',
            'data': {},
            'meta': {},
            'error': ['Gagal memverifikasi OTP: ${response.statusCode}']
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memverifikasi OTP: ${e.toString()}',
        'data': {},
        'meta': {},
        'error': ['Gagal memverifikasi OTP: ${e.toString()}']
      };
    }
  }

  /// Registrasi akun baru setelah verifikasi OTP
  Future<Map<String, dynamic>> registerAccount({
    required String otpId,
    required String phone,
    required String username,
    required String password,
    required String email,
  }) async {
    try {
      final url = Uri.parse('https://api.maestroswim.com/auth/users/activation_register/');
      print('🔐 Registrasi akun untuk username: $username dengan nomor: $phone');
      
      final response = await http.post(
        url,
        headers: <String, String>{'Content-Type': 'application/json'},
        body: jsonEncode(<String, String>{
          'otp_id': otpId,
          'phone': phone,
          'username': username,
          'password': password,
          'email': email,
        }),
      );

      // Periksa status code terlebih dahulu
      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          
          // Format respons sesuai dengan API
          return {
            'success': responseData['status'] ?? false,
            'message': responseData['message'] ?? 'Registrasi akun berhasil',
            'data': responseData['data'] ?? {},
            'meta': responseData['meta'] ?? {},
            'error': responseData['error'] ?? []
          };
        } catch (e) {
          // Jika gagal parsing JSON tapi status code OK
          return {
            'success': false,
            'message': 'Format respons tidak valid: ${response.body.substring(0, 50)}...',
            'data': {},
            'meta': {},
            'error': ['Format respons tidak valid']
          };
        }
      } else {
        // Coba parse response body, jika gagal tampilkan response body mentah
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': false,
            'message': responseData['message'] ?? 'Gagal registrasi akun (${response.statusCode})',
            'data': {},
            'meta': {},
            'error': responseData['error'] ?? ['Gagal registrasi akun']
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Gagal registrasi akun (${response.statusCode})',
            'data': {},
            'meta': {},
            'error': ['Gagal registrasi akun: ${response.statusCode}']
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal registrasi akun: ${e.toString()}',
        'data': {},
        'meta': {},
        'error': ['Gagal registrasi akun: ${e.toString()}']
      };
    }
  }
}