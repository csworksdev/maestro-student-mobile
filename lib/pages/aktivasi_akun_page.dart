import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:maestro_client_mobile/pages/verifikasi_otp_page.dart';
import 'package:maestro_client_mobile/services/aktivasi_akun_service.dart';

class AktivasiAkunPage extends StatefulWidget {
  @override
  _AktivasiAkunPageState createState() => _AktivasiAkunPageState();
}

class _AktivasiAkunPageState extends State<AktivasiAkunPage> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
          title: Text(
          'Aktivasi Akun',
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
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_add_alt_1,
                  size: screenHeight * 0.15,
                  color: Color.fromARGB(209, 0, 40, 78),
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  "Aktivasi Akun",
                  style: TextStyle(
                    fontSize: screenWidth * 0.06,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(209, 0, 40, 78),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                    Text(
                    'Masukkan nomor WhatsApp Anda untuk menerima kode OTP!',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 255, 255, 255)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueGrey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.04,
                    horizontal: screenWidth * 0.08,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPhoneField(),
                        SizedBox(height: screenHeight * 0.04),
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
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: "Nomor WhatsApp",
        hintText: "Contoh: 08123456789",
        prefixIcon: Icon(Icons.phone_android, color: Colors.blueGrey.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey.shade300),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Nomor WhatsApp harus diisi';
        }
        if (value.length < 10 || value.length > 13) {
          return 'Nomor WhatsApp tidak valid';
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

    try {
      // Menggunakan service untuk mengirim OTP
      String phoneNumber = _phoneController.text;
      final aktivasiService = AktivasiAkunService();
      final result = await aktivasiService.sendOTP(phoneNumber);
      
      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Navigasi ke halaman verifikasi OTP dengan otpId
        // Pastikan data dan otp_id ada dan tidak null
        final data = result['data'];
        String otpId = '';
        
        if (data != null && data is Map<String, dynamic> && data.containsKey('otp_id')) {
          otpId = data['otp_id'] ?? '';
        }
        
        if (otpId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('OTP ID tidak ditemukan. Silakan coba lagi.'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerifikasiOTPPage(
              phoneNumber: phoneNumber,
              otpId: otpId,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal mengirim OTP. Silakan coba lagi.'),
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
}