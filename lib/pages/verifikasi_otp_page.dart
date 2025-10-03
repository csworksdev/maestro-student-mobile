import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maestro_client_mobile/pages/registrasi_akun_page.dart';
import 'package:maestro_client_mobile/services/aktivasi_akun_service.dart';

class VerifikasiOTPPage extends StatefulWidget {
  final String phoneNumber;

  VerifikasiOTPPage({required this.phoneNumber});

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

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
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
    return Row(
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
            },
          ),
        ),
      ),
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
      final result = await aktivasiService.verifyOTP(widget.phoneNumber, otp);
      
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Navigasi ke halaman registrasi akun
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegistrasiAkunPage(phoneNumber: widget.phoneNumber),
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
    setState(() {
      _isLoading = true;
    });
    
    try {
      final aktivasiService = AktivasiAkunService();
      final result = await aktivasiService.sendOTP(widget.phoneNumber);
      
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Kode OTP baru telah dikirim ke nomor WhatsApp Anda'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim ulang OTP. Silakan coba lagi.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}