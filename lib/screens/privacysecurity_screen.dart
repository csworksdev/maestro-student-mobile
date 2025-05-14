import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PrivacySecurityScreen extends StatefulWidget {
  @override
  _PrivacySecurityScreenState createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController(); // Tambahkan controller untuk username
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isCurrentPasswordHidden = true;
  bool _isNewPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;

  Future<void> _changePasswordAPI(String username, String oldPassword, String newPassword) async {
    const String apiUrl = 'https://api.maestroswim.com/auth/users/change_password/';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password berhasil diubah!'),
            backgroundColor: Colors.green,
          ),
        );

        _clearInputFields();
      } else {

        final error = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengubah password: ${error['detail'] ?? 'Terjadi kesalahan'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _clearInputFields() {
    _usernameController.clear();
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
  }

  void _showConfirmationDialog() {
    if (_formKey.currentState!.validate()) {

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Konfirmasi'),
            content: Text('Apakah Anda yakin ingin mengubah password?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                },
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                  _changePassword(); 
                },
                child: Text('Ya'),
              ),
            ],
          );
        },
      );
    } else {
 
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Harap isi semua field dengan benar!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _changePassword() {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text; 
      final oldPassword = _currentPasswordController.text;
      final newPassword = _newPasswordController.text;

      _changePasswordAPI(username, oldPassword, newPassword);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, bool isDarkMode) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[900]),
      prefixIcon: Icon(
        icon,
        color: isDarkMode
            ? Colors.orange 
            : const Color.fromARGB(240, 0, 53, 102), 
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: isDarkMode ? Colors.white24 : Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: isDarkMode ? Colors.white24 : Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: const Color.fromARGB(240, 0, 53, 102)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Sandi & Keamanan',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [

                TextFormField(
                  controller: _usernameController,
                  decoration: _buildInputDecoration(
                    'Username',
                    Icons.person,
                    isDarkMode,
                  ),
                  style: TextStyle(color: textColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap masukkan username Anda';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: _currentPasswordController,
                  decoration: _buildInputDecoration(
                    'Password Sekarang',
                    Icons.lock,
                    isDarkMode,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isCurrentPasswordHidden ? Icons.visibility : Icons.visibility_off,
                        color: isDarkMode ? Colors.white70 : Colors.grey[700],
                      ),
                      onPressed: () {
                        setState(() {
                          _isCurrentPasswordHidden = !_isCurrentPasswordHidden;
                        });
                      },
                    ),
                  ),
                  obscureText: _isCurrentPasswordHidden,
                  style: TextStyle(color: textColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap masukkan password Anda saat ini';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: _newPasswordController,
                  decoration: _buildInputDecoration(
                    'Password Baru',
                    Icons.lock_outline,
                    isDarkMode,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordHidden ? Icons.visibility : Icons.visibility_off,
                        color: isDarkMode ? Colors.white70 : Colors.grey[700],
                      ),
                      onPressed: () {
                        setState(() {
                          _isNewPasswordHidden = !_isNewPasswordHidden;
                        });
                      },
                    ),
                  ),
                  obscureText: _isNewPasswordHidden,
                  style: TextStyle(color: textColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap masukkan password baru Anda';
                    }
                    if (value.length < 6) {
                      return 'Password harus memiliki minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: _buildInputDecoration(
                    'Konfirmasi Password',
                    Icons.lock_reset,
                    isDarkMode,
                  ).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordHidden ? Icons.visibility : Icons.visibility_off,
                        color: isDarkMode ? Colors.white70 : Colors.grey[700],
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordHidden = !_isConfirmPasswordHidden;
                        });
                      },
                    ),
                  ),
                  obscureText: _isConfirmPasswordHidden,
                  style: TextStyle(color: textColor),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harap konfirmasi password baru Anda';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Password tidak cocok';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Colors.orange 
                        : const Color.fromARGB(240, 0, 53, 102),
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Ganti Password'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}