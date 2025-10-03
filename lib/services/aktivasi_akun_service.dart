

class AktivasiAkunService {

  /// Mengirim kode OTP untuk aktivasi akun
  Future<Map<String, dynamic>> sendOTP(String email) async {
    try {
      // Dummy response untuk simulasi pengiriman OTP
      return {
        'success': true,
        'message': 'Kode OTP telah dikirim ke email $email',
        'otp_code': '123456', // Dummy OTP code
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengirim kode OTP: ${e.toString()}',
      };
    }
  }

  /// Verifikasi kode OTP
  Future<Map<String, dynamic>> verifyOTP(String email, String otpCode) async {
    try {
      // Dummy response untuk simulasi verifikasi OTP
      if (otpCode == '123456') { // Dummy validation
        return {
          'success': true,
          'message': 'Verifikasi OTP berhasil',
        };
      } else {
        return {
          'success': false,
          'message': 'Kode OTP tidak valid',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal memverifikasi OTP: ${e.toString()}',
      };
    }
  }

  /// Aktivasi akun setelah verifikasi OTP berhasil
  Future<Map<String, dynamic>> aktivasiAkun(String email, String password) async {
    try {
      // Dummy response untuk simulasi aktivasi akun
      return {
        'success': true,
        'message': 'Akun berhasil diaktivasi',
        'user_id': '12345', // Dummy user ID
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengaktivasi akun: ${e.toString()}',
      };
    }
  }

  /// Registrasi akun baru
  Future<Map<String, dynamic>> registerAccount({
    required String phoneNumber,
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      // Dummy response untuk simulasi registrasi akun
      return {
        'success': true,
        'message': 'Akun berhasil didaftarkan',
        'user_id': '12345', // Dummy user ID
        'username': username,
        'email': email,
        'phone_number': phoneNumber,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mendaftarkan akun: ${e.toString()}',
      };
    }
  }

  /// Reset password
  Future<Map<String, dynamic>> resetPassword(String email, String newPassword, String otpCode) async {
    try {
      // Dummy response untuk simulasi reset password
      if (otpCode == '123456') { // Dummy validation
        return {
          'success': true,
          'message': 'Password berhasil direset',
        };
      } else {
        return {
          'success': false,
          'message': 'Kode OTP tidak valid',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mereset password: ${e.toString()}',
      };
    }
  }
}