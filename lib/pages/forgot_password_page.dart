import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maestro_client_mobile/services/auth_service.dart';
import 'dart:async';

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _usernameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
          title: Text(
          'Lupa Password',
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(209, 0, 40, 78),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  Icon(
                    Icons.lock_outline,
                    size: screenHeight * 0.12,
                    color: Color.fromARGB(209, 0, 40, 78),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'Lupa Password',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(209, 0, 40, 78),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Masukkan username Anda untuk menerima kode OTP!',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.08),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildUsernameField(),
                          SizedBox(height: screenHeight * 0.05),
                          _isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _sendOTP,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(209, 0, 40, 78),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.015,
                                      horizontal: screenWidth * 0.1,
                                    ),
                                  ),
                                  child: Text(
                                    "Kirim Kode OTP",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.045,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameField() {
    
    return TextFormField(
      controller: _usernameController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: "Username",
        prefixIcon: Icon(Icons.person, color: Colors.blueGrey.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color.fromARGB(209, 0, 40, 78)),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Username harus diisi!';
        }
        if (value.trim().length < 3) {
          return 'Username minimal 3 karakter!';
        }
        return null;
      },
    );
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();

    final result = await _authService.sendOtp(
      username: username,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      // Menggunakan nilai default untuk otpId jika tidak ada dalam respons
      final otpId = result['otp_id'] ?? 'default_otp_id';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Kode OTP telah dikirim'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationPage(
            username: username,
            otpId: otpId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal mengirim kode OTP'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

// OTP Verification Page
class OTPVerificationPage extends StatefulWidget {
  final String username;
  final String otpId;

  const OTPVerificationPage({Key? key, required this.username, required this.otpId}) : super(key: key);

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Timer? _clipboardCheckTimer;

  // Variable untuk melacak apakah OTP baru sedang diminta
  bool _isRequestingNewOTP = false;

  @override
  void initState() {
    super.initState();
    // Mulai timer untuk memeriksa clipboard secara berkala
    _clipboardCheckTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!_isRequestingNewOTP) {
        _checkClipboard();
      }
    });
  }

  @override
  void dispose() {
    // Dispose controllers and focus nodes
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    // Batalkan timer
    _clipboardCheckTimer?.cancel();
    super.dispose();
  }
  
  // Fungsi untuk membersihkan semua kotak input OTP
  void _clearOTPFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    // Fokus ke kotak pertama
    _focusNodes[0].requestFocus();
  }
  
  // Fungsi untuk memeriksa clipboard dan mengisi otomatis kode OTP
  Future<void> _checkClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final clipboardText = clipboardData?.text;
      
      // Periksa apakah teks clipboard adalah 6 digit angka (format OTP)
      if (clipboardText != null && 
          clipboardText.length == 6 && 
          RegExp(r'^\d{6}$').hasMatch(clipboardText)) {
        
        // Periksa apakah OTP sudah diisi (untuk menghindari pengisian berulang)
        final currentOtp = _otpControllers.map((c) => c.text).join();
        if (currentOtp != clipboardText) {
          // Isi setiap kotak OTP dengan digit yang sesuai
          for (int i = 0; i < 6; i++) {
            _otpControllers[i].text = clipboardText[i];
          }
          // Hapus fokus dari semua field
          FocusScope.of(context).unfocus();
        }
      }
    } catch (e) {
      // Tangani error jika ada
      print('Error saat memeriksa clipboard: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verifikasi OTP',
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(209, 0, 40, 78),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  Icon(
                    Icons.sms,
                    size: screenHeight * 0.12,
                    color: Color.fromARGB(209, 0, 40, 78),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'Verifikasi OTP',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(209, 0, 40, 78),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Masukkan kode OTP yang dikirim ke\nusername Anda',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.08),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildOTPFields(),
                          SizedBox(height: screenHeight * 0.03),
                          _isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _verifyOTP,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(209, 0, 40, 78),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.015,
                                      horizontal: screenWidth * 0.1,
                                    ),
                                  ),
                                  child: Text(
                                    "Verifikasi OTP",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.045,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                          SizedBox(height: screenHeight * 0.02),
                          TextButton(
                            onPressed: _resendOTP,
                            child: Text(
                              "Kirim Ulang OTP",
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                color: Color.fromARGB(209, 0, 40, 78),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOTPFields() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(6, (index) {
        return Container(
          width: screenWidth * 0.12,
          height: screenHeight * 0.08,
          child: TextFormField(
            controller: _otpControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: TextStyle(
              fontSize: screenWidth * 0.08,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
            decoration: InputDecoration(
              counterText: '',
              contentPadding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.02,
                horizontal: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blueGrey.shade300, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Color.fromARGB(209, 0, 40, 78), width: 2.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blueGrey.shade300, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (value) {
              if (value.length == 1) {
                // Move to next field
                if (index < 5) {
                  _focusNodes[index + 1].requestFocus();
                } else {
                  // Last field, remove focus
                  _focusNodes[index].unfocus();
                }
              } else if (value.isEmpty) {
                // Move to previous field
                if (index > 0) {
                  _focusNodes[index - 1].requestFocus();
                }
              }
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '';
              }
              return null;
            },
          ),
        );
      }),
    );
  }

  Future<void> _verifyOTP() async {
    // Check if all fields are filled
    bool allFieldsFilled = _otpControllers.every((controller) => controller.text.isNotEmpty);
    
    if (!allFieldsFilled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mohon isi semua digit OTP!'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    // Combine all OTP digits
    final enteredOTP = _otpControllers.map((controller) => controller.text).join();

    // Verifikasi OTP menggunakan API
    final result = await _authService.verifyOtp(
      otpId: widget.otpId,
      otp: enteredOTP,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Lanjut ke halaman reset password membawa OTP ID
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResetPasswordPage(
            username: widget.username,
            otpId: widget.otpId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _resendOTP() async {
    // Tandai bahwa kita sedang meminta OTP baru
    setState(() {
      _isRequestingNewOTP = true;
      _isLoading = true;
    });
    
    // Bersihkan semua kotak input OTP
    _clearOTPFields();
    
    // Bersihkan clipboard untuk menghindari auto-paste kode lama
    try {
      await Clipboard.setData(ClipboardData(text: ''));
    } catch (e) {
      print('Error saat membersihkan clipboard: $e');
    }

    final result = await _authService.sendOtp(
      username: widget.username,
    );

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['success']
            ? result['message']
            : 'Gagal mengirim ulang OTP. Coba lagi.'),
        backgroundColor: result['success'] ? Colors.blue : Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
    
    if (result['success']) {
      // Reset flag _isRequestingNewOTP sebelum navigasi
      setState(() {
        _isRequestingNewOTP = false;
      });
      
      // Update otpId jika berhasil
      // Mengambil otpId dari data yang dikembalikan API
      String newOtpId = '';
      if (result['data'] != null && result['data'] is Map<String, dynamic>) {
        newOtpId = result['data']['otp_id'] ?? '';
      }
      
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationPage(
            username: widget.username,
            otpId: newOtpId.isNotEmpty ? newOtpId : widget.otpId, // Gunakan otpId lama jika yang baru kosong
          ),
        ),
      );
    } else {
      // Reset flag jika gagal
      setState(() {
        _isRequestingNewOTP = false;
      });
    }
  }
}

// Reset Password Page
class ResetPasswordPage extends StatefulWidget {
  final String username;
  final String otpId;

  const ResetPasswordPage({Key? key, required this.username, required this.otpId}) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reset Password',
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color.fromARGB(209, 0, 40, 78),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 255, 255, 255)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  Icon(
                    Icons.lock_open,
                    size: screenHeight * 0.12,
                    color: Color.fromARGB(209, 0, 40, 78),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Text(
                    'Password Baru',
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(209, 0, 40, 78),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    'Masukkan password baru Anda',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(screenWidth * 0.08),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildNewPasswordField(),
                          SizedBox(height: screenHeight * 0.02),
                          _buildConfirmPasswordField(),
                          SizedBox(height: screenHeight * 0.03),
                          _isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  onPressed: _resetPassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color.fromARGB(209, 0, 40, 78),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.015,
                                      horizontal: screenWidth * 0.1,
                                    ),
                                  ),
                                  child: Text(
                                    "Reset Password",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.045,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewPasswordField() {
    
    return TextFormField(
      controller: _newPasswordController,
      obscureText: !_isNewPasswordVisible,
      decoration: InputDecoration(
        labelText: "Password Baru",
        prefixIcon: Icon(Icons.lock, color: Colors.blueGrey.shade700),
        suffixIcon: IconButton(
          icon: Icon(
            _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.blueGrey.shade700,
          ),
          onPressed: () {
            setState(() {
              _isNewPasswordVisible = !_isNewPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color.fromARGB(209, 0, 40, 78)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password baru harus diisi!';
        }
        if (value.length < 6) {
          return 'Password minimal 6 karakter!';
        }
        return null;
      },
    );
  }

  Widget _buildConfirmPasswordField() {
    
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      decoration: InputDecoration(
        labelText: "Konfirmasi Password",
        prefixIcon: Icon(Icons.lock_outline, color: Colors.blueGrey.shade700),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.blueGrey.shade700,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color.fromARGB(209, 0, 40, 78)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Konfirmasi password harus diisi!';
        }
        if (value != _newPasswordController.text) {
          return 'Password tidak cocok!';
        }
        return null;
      },
    );
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    final newPassword = _newPasswordController.text.trim();
    final result = await _authService.resetPasswordWithOtp(
      otpId: widget.otpId,
      newPassword: newPassword,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}