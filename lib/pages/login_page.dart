import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/auth_provider.dart';
import 'package:maestro_client_mobile/services/notification_service.dart';
import 'package:maestro_client_mobile/pages/forgot_password_page.dart';
import 'package:maestro_client_mobile/pages/aktivasi_akun_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo_maestro.png',
                      height: screenHeight * 0.30,
                    ),
                    SizedBox(height: screenHeight * 0.04),
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
                        _buildTextField(
                          controller: _usernameController,
                          label: "Username",
                          icon: Icons.person,
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        _buildPasswordField(),
                        SizedBox(height: screenHeight * 0.04),
                        _isLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: _login,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.018,
                                    horizontal: screenWidth * 0.30,
                                  ),
                                ),
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          SizedBox(height: screenHeight * 0.02),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: _aktivitasAkun,
                                child: Text(
                                  "Aktivasi Akun",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: Color.fromARGB(209, 0, 40, 78),
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: _forgotPassword,
                                child: Text(
                                  "Lupa Password?",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.035,
                                    color: Color.fromARGB(209, 0, 40, 78),
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FontStyle.italic,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                    SizedBox(height: screenHeight * 0.04),
                    Text(
                      "© Maestro Swim Mobile 2025",
                      style: TextStyle(
                        fontSize: screenWidth * 0.03,
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blueGrey.shade700),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey.shade300),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label isi terlebih dahulu!';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon: Icon(Icons.lock, color: Colors.blueGrey.shade700),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
            color: Colors.blueGrey.shade700,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blueGrey.shade300),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Password isi terlebih dahulu!';
        }
        return null;
      },
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(username, password);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      // Tampilkan user ID dan token auth di debug console
      print('====== USER ID ======');
      print(authProvider.userId);
      print('====================');
      
      print('====== AUTH TOKEN ======');
      print(authProvider.token);
      print('========================');
      
      // Dapatkan FCM token dan kirim ke server setelah login berhasil
      Future.delayed(Duration.zero, () async {
        try {
          print('Mencoba mendapatkan FCM token...');
          final notificationService = NotificationService();
          
          // Cek apakah token sudah tersimpan di SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          String? fcmToken = prefs.getString('fcm_token');
          
          // Jika tidak ada, dapatkan token baru
          if (fcmToken == null || fcmToken.isEmpty) {
            try {
              // Dapatkan token tanpa vapidKey untuk kompatibilitas Android
              fcmToken = await FirebaseMessaging.instance.getToken();
              
              // Simpan token ke SharedPreferences
              if (fcmToken != null) {
                await prefs.setString('fcm_token', fcmToken);
              }
            } catch (e) {
              print('Error mendapatkan FCM token: $e');
            }
          }
          
          // Tampilkan FCM token di debug console
          print('====== FCM TOKEN ======');
          print(fcmToken ?? 'FCM Token tidak tersedia');
          print('=======================');
          
          // Kirim token ke server jika tersedia
          if (fcmToken != null && fcmToken.isNotEmpty) {
            final success = await notificationService.sendTokenToApi(fcmToken, authProvider.token!);
            if (success) {
              print('FCM token berhasil dikirim ke server!');
            } else {
              print('Gagal mengirim FCM token ke server.');
            }
          }
        } catch (e) {
          // Tangani error FCM token tanpa mengganggu proses login
          print('Error saat mendapatkan FCM token: $e');
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacementNamed(context, '/MainScreen');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login gagal! Username atau password salah.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

    void _forgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ForgotPasswordPage(),
      ),
    );
  }
  
  void _aktivitasAkun() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AktivasiAkunPage(),
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}