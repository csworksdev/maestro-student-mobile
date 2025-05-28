import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/auth_provider.dart';

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
double scaleWidth(BuildContext context, double value) => value * screenWidth(context) / 375; // 375 = width iPhone 11
double scaleHeight(BuildContext context, double value) => value * screenHeight(context) / 812; // 812 = height iPhone 11

class EditDataSiswa extends StatefulWidget {
  final int id;
  final String nama;
  final String kelas;
  final String kolam;
  final String phoneNumber;
  final int index;

  EditDataSiswa({
    required this.id,
    required this.nama,
    required this.kelas,
    required this.kolam,
    required this.phoneNumber,
    required this.index,
  });

  @override
  _EditDataSiswaState createState() => _EditDataSiswaState();
}

class _EditDataSiswaState extends State<EditDataSiswa> {
  late TextEditingController namaController;
  late TextEditingController nicknameController;
  late TextEditingController parentController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController pobController;
  late TextEditingController parentIdController;
  late TextEditingController branchController;
  late String selectedKolam;

  String? selectedGender;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    namaController = TextEditingController(text: widget.nama);
    nicknameController = TextEditingController();
    parentController = TextEditingController();
    phoneController = TextEditingController(
      text: widget.phoneNumber.startsWith('0')
          ? widget.phoneNumber.replaceFirst('0', '+62')
          : widget.phoneNumber,
    );
    addressController = TextEditingController();
    pobController = TextEditingController();
    parentIdController = TextEditingController();
    branchController = TextEditingController();
    selectedGender = null;
    selectedDate = null;
  }

  @override
  void dispose() {
    namaController.dispose();
    nicknameController.dispose();
    parentController.dispose();
    phoneController.dispose();
    addressController.dispose();
    pobController.dispose();
    parentIdController.dispose();
    branchController.dispose();
    super.dispose();
  }

  Future<void> updateProfile() async {
    // Mapping gender
    String? genderApi;
    if (selectedGender == 'Laki-laki') {
      genderApi = 'male';
    } else if (selectedGender == 'Perempuan') {
      genderApi = 'female';
    } else {
      genderApi = '';
    }

    // Format phone ke +62
    String phoneApi = phoneController.text;
    if (phoneApi.startsWith('0')) {
      phoneApi = '+62' + phoneApi.substring(1);
    }
    // Hapus spasi jika ada
    phoneApi = phoneApi.replaceAll(' ', '');

    // parent_id sebagai integer
    int? parentIdApi;
    try {
      parentIdApi = int.tryParse(parentIdController.text);
    } catch (_) {
      parentIdApi = null;
    }

    final Map<String, dynamic> payload = {
      'fullname': namaController.text,
      'nickname': nicknameController.text,
      'gender': genderApi,
      'parent': parentController.text,
      'phone': phoneApi,
      'address': addressController.text,
      'dob': selectedDate != null ? selectedDate!.toIso8601String().substring(0, 10) : '',
      'pob': pobController.text,
      'parent_id': parentIdApi,
      'branch': branchController.text,
    };
    print('DEBUG: Payload yang dikirim: ' + payload.toString()); // Debug log
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      final response = await http.put(
        Uri.parse('https://api.maestroswim.com/api/student/${widget.id}/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );
      print('DEBUG: Status code: ' + response.statusCode.toString()); // Debug log
      print('DEBUG: Response body: ' + response.body); // Debug log
      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil berhasil diperbarui!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, payload); // Kembalikan data ke halaman utama
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui profil!\n${response.body}'), backgroundColor: Colors.red, duration: Duration(seconds: 5)),
        );
      }
    } catch (e) {
      print('DEBUG: Error saat mengirim data: ' + e.toString()); // Debug log
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.red),
      );
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon, bool isDarkMode, BuildContext context) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.grey[900], fontSize: scaleWidth(context, 16)),
      prefixIcon: Icon(
        icon,
        color: isDarkMode ? Colors.orange : const Color.fromARGB(240, 0, 53, 102),
        size: scaleWidth(context, 20),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(scaleWidth(context, 20)),
        borderSide: BorderSide(color: isDarkMode ? Colors.white24 : Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(scaleWidth(context, 20)),
        borderSide: BorderSide(color: isDarkMode ? Colors.white24 : Colors.black12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(scaleWidth(context, 20)),
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
        padding: EdgeInsets.all(scaleWidth(context, 20.0)),
        child: Column(
          children: [
            buildTextField("Nama", namaController, Icons.person, isDarkMode, context),
            buildTextField("Panggilan", nicknameController, Icons.person_outline, isDarkMode, context),
            Padding(
              padding: EdgeInsets.symmetric(vertical: scaleHeight(context, 10)),
              child: DropdownButtonFormField<String>(
                value: selectedGender,
                decoration: _buildInputDecoration("Gender", Icons.wc, isDarkMode, context),
                items: [
                  DropdownMenuItem(value: "Laki-laki", child: Text("Laki-laki", style: TextStyle(fontSize: scaleWidth(context, 16)))),
                  DropdownMenuItem(value: "Perempuan", child: Text("Perempuan", style: TextStyle(fontSize: scaleWidth(context, 16)))),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: scaleWidth(context, 16)),
                dropdownColor: backgroundColor,
              ),
            ),
            buildTextField("Orang Tua", parentController, Icons.people, isDarkMode, context),
            buildTextField("No WhatsApp", phoneController, Icons.phone, isDarkMode, context, TextInputType.phone),
            buildTextField("Alamat", addressController, Icons.home, isDarkMode, context),
            Padding(
              padding: EdgeInsets.symmetric(vertical: scaleHeight(context, 10)),
              child: GestureDetector(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime(2010, 1, 1),
                    firstDate: DateTime(1990),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextField(
                    controller: TextEditingController(
                      text: selectedDate != null
                          ? "${selectedDate!.day.toString().padLeft(2, '0')}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.year}"
                          : '',
                    ),
                    decoration: _buildInputDecoration("Tanggal Lahir", Icons.cake, isDarkMode, context),
                    style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: scaleWidth(context, 16)),
                  ),
                ),
              ),
            ),
            buildTextField("Tempat Lahir", pobController, Icons.location_city, isDarkMode, context),
            buildTextField("Branch", branchController, Icons.account_tree, isDarkMode, context),
            SizedBox(height: scaleHeight(context, 40)),
            ElevatedButton(
              onPressed: () async {
                final shouldSave = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Konfirmasi', style: TextStyle(fontSize: scaleWidth(context, 18))),
                      content: Text('Apakah Anda yakin ingin menyimpan perubahan?', style: TextStyle(fontSize: scaleWidth(context, 16))),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); 
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red, 
                          ),
                          child: Text('Batal', style: TextStyle(fontSize: scaleWidth(context, 14))),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.green, 
                          ),
                          child: Text('Ya', style: TextStyle(fontSize: scaleWidth(context, 14))),
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
              child: Text('Simpan Perubahan', style: TextStyle(fontSize: scaleWidth(context, 16))),
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
    bool isDarkMode,
    BuildContext context, [
    TextInputType keyboardType = TextInputType.text,
  ]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: scaleHeight(context, 10)),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _buildInputDecoration(label, icon, isDarkMode, context),
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: scaleWidth(context, 16)),
      ),
    );
  }
}