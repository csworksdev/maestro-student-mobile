import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maestro_client_mobile/pages/registrasi_akun_page.dart';
import 'package:maestro_client_mobile/services/aktivasi_akun_service.dart';
import 'dart:async';

class VerifikasiOTPPage extends StatefulWidget {
  final String phoneNumber;
  final String otpId;

  const VerifikasiOTPPage({required this.phoneNumber, required this.otpId});

  @override
  _VerifikasiOTPPageState createState() => _VerifikasiOTPPageState();
}

class _VerifikasiOTPPageState extends State<VerifikasiOTPPage> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _isLoading = false;
  late String _otpId;
  
  // Timer untuk memeriksa clipboard secara berkala
  Timer? _clipboardCheckTimer;
  
  // Variable untuk melacak apakah OTP baru sedang diminta
  bool _isRequestingNewOTP = false;
  
  @override
  void initState() {
    super.initState();
    _otpId = widget.otpId;
    
    // Mulai timer untuk memeriksa clipboard secara berkala
    _clipboardCheckTimer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      if (!_isRequestingNewOTP) {
        _checkClipboard();
      }
    });
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
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    
    // Batalkan timer
    _clipboardCheckTimer?.cancel();
    
    super.dispose();
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
                    'Masukkan kode OTP yang dikirim ke\nnomor WhatsApp ${widget.phoneNumber}', 
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
                    child: Column( 
                      mainAxisSize: MainAxisSize.min, 
                      children: [ 
                        _buildOTPFields(screenWidth), 
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
                ], 
              ), 
            ), 
          ), 
        ), 
      ),
    );
  }

  Widget _buildOTPFields(double screenWidth) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(
            6,
            (index) => SizedBox(
              width: screenWidth * 0.12, // Memperbesar lebar kotak
              height: screenWidth * 0.14, // Menambahkan tinggi yang cukup
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _focusNodes[index],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                style: TextStyle(
                  fontSize: screenWidth * 0.06, // Ukuran font responsif
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: "",
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenWidth * 0.02, // Padding vertikal yang lebih kecil
                    horizontal: 0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Color.fromARGB(209, 0, 40, 78), width: 2),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    if (index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    } else {
                      _focusNodes[index].unfocus();
                    }
                  }
                  // Jika kotak dikosongkan dan bukan kotak pertama, pindah fokus ke kotak sebelumnya
                  else if (value.isEmpty && index > 0) {
                    _focusNodes[index - 1].requestFocus();
                  }
                },
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Future<void> _verifyOTP() async {
    String otp = _otpControllers.map((controller) => controller.text).join();
    
    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Masukkan 6 digit kode OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Menggunakan service untuk verifikasi OTP
      final aktivasiService = AktivasiAkunService();
      final result = await aktivasiService.verifyOTP(_otpId, otp);
      
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Navigasi ke halaman registrasi akun
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegistrasiAkunPage(
              phoneNumber: widget.phoneNumber,
              otpId: _otpId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Kode OTP tidak valid. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi.'),
          backgroundColor: Colors.red,
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
    
    try {
      final aktivasiService = AktivasiAkunService();
      final result = await aktivasiService.sendOTP(widget.phoneNumber);
      
      setState(() {
        _isLoading = false;
        _isRequestingNewOTP = false;
        // Update otpId jika berhasil mengirim ulang
        if (result['success']) {
          final data = result['data'];
          if (data != null && data is Map<String, dynamic> && data.containsKey('otp_id') && data['otp_id'] != null) {
            _otpId = data['otp_id'];
          }
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Kode OTP baru telah dikirim ke nomor WhatsApp Anda'),
          backgroundColor: result['success'] ? Colors.blue : Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isRequestingNewOTP = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim ulang OTP. Silakan coba lagi.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}