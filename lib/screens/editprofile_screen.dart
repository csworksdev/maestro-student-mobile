import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final String fullname;
  final String nickname;
  final String dob;
  final String bankAccount;
  final String email;
  final String phoneNumber;

  EditProfileScreen({
    required this.fullname,
    required this.nickname,
    required this.dob,
    required this.bankAccount,
    required this.email,
    required this.phoneNumber,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController fullnameController;
  late TextEditingController nicknameController;
  late TextEditingController dobController;
  late TextEditingController bankAccountController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void initState() {
    super.initState();
    fullnameController = TextEditingController(text: widget.fullname);
    nicknameController = TextEditingController(text: widget.nickname);
    dobController = TextEditingController(text: widget.dob);
    bankAccountController = TextEditingController(text: widget.bankAccount);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phoneNumber.startsWith('0')
        ? widget.phoneNumber.replaceFirst('0', '+62')
        : widget.phoneNumber);
  }

  @override
  void dispose() {
    fullnameController.dispose();
    nicknameController.dispose();
    dobController.dispose();
    bankAccountController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.tryParse(dobController.text) ?? DateTime(2000);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = picked.toIso8601String().substring(0, 10);
    }
  }

  Future<void> updateProfile() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mendapatkan ID pengguna."),
        backgroundColor: Colors.red,  
        ),
      );
      return;
    }

    if (!emailController.text.contains('@') || !emailController.text.contains('.')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email tidak valid!"),
        backgroundColor: Colors.red,  
        ),
      );
      return;
    }

    String phone = phoneController.text;
    if (phone.startsWith('+62')) {
      phone = '0${phone.substring(3)}';
    }

    final apiUrl = 'https://api.maestroswim.com/api/trainer/$userId/';
    final body = {
      "fullname": fullnameController.text,
      "nickname": nicknameController.text,
      "dob": dobController.text,
      "bank_account": bankAccountController.text,
      "email": emailController.text,
      "phone": phone,
    };

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Profil berhasil diperbarui!"),
            backgroundColor: Colors.green,
          ),
        );
                Navigator.pop(context);
      } else {
        print("Gagal update: ${response.body}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memperbarui profil!"),
          backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan.")),
      );
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, bool isDarkMode) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[900]),
      prefixIcon: Icon(
        icon,
        color: isDarkMode ? Colors.orange : const Color.fromARGB(240, 0, 53, 102),
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
        title: Text('Edit Data Siswa', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            buildTextField("Nama Lengkap", fullnameController, Icons.person, isDarkMode),
            buildTextField("Nama Panggilan", nicknameController, Icons.person_outline, isDarkMode),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: buildTextField("Tanggal Lahir", dobController, Icons.calendar_month_outlined, isDarkMode),
              ),
            ),
            buildTextField("Rekening Bank", bankAccountController, Icons.account_balance, isDarkMode, TextInputType.number),
            buildTextField("Email", emailController, Icons.email, isDarkMode, TextInputType.emailAddress),
            buildTextField("Nomor HP", phoneController, Icons.phone, isDarkMode, TextInputType.phone),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () async {
                final shouldSave = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Konfirmasi'),
                      content: Text('Apakah Anda yakin ingin menyimpan perubahan?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); 
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red, 
                          ),
                          child: Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green, 
                          ),
                          child: Text('Ya'),
                        ),
                      ],
                    );
                  },
                );

                if (shouldSave == true) {
                  updateProfile(); 
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDarkMode
                    ? Colors.orange
                    : const Color.fromARGB(240, 0, 53, 102),
                foregroundColor: Colors.white,
              ),
              child: Text('Simpan Perubahan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isDarkMode, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _buildInputDecoration(label, icon, isDarkMode),
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }
}
