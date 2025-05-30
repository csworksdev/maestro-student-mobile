import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class EditDataSiswaScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const EditDataSiswaScreen({super.key, required this.studentData});

  @override
  State<EditDataSiswaScreen> createState() => _EditDataSiswaScreenState();
}

class _EditDataSiswaScreenState extends State<EditDataSiswaScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController fullnameController;
  late TextEditingController nicknameController;
  late TextEditingController genderController;
  late TextEditingController parentController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController dobController;
  late TextEditingController pobController;
  late TextEditingController branchNameController;

  bool isLoading = false;

  late double screenWidth;
  late double screenHeight;

  double scaleWidth(double value) => screenWidth / 375 * value;
  double scaleHeight(double value) => screenHeight / 812 * value;

  @override
  void initState() {
    super.initState();
    fullnameController = TextEditingController(text: widget.studentData['fullname']);
    nicknameController = TextEditingController(text: widget.studentData['nickname']);
    genderController = TextEditingController(text: widget.studentData['gender']);
    parentController = TextEditingController(text: widget.studentData['parent']);
    phoneController = TextEditingController(text: widget.studentData['phone']);
    addressController = TextEditingController(text: widget.studentData['address']);
    dobController = TextEditingController(text: widget.studentData['dob']);
    pobController = TextEditingController(text: widget.studentData['pob']);
    branchNameController = TextEditingController(text: widget.studentData['branch_name']);
  }

  @override
  void dispose() {
    fullnameController.dispose();
    nicknameController.dispose();
    genderController.dispose();
    parentController.dispose();
    phoneController.dispose();
    addressController.dispose();
    dobController.dispose();
    pobController.dispose();
    branchNameController.dispose();
    super.dispose();
  }

  Future<void> updateStudentData() async {
    setState(() => isLoading = true);
    final url = Uri.parse("https://api.maestroswim.com/api/student/");

    final body = {
      "student_id": widget.studentData['student_id'],
      "fullname": fullnameController.text,
      "nickname": nicknameController.text,
      "gender": genderController.text,
      "parent": parentController.text,
      "phone": phoneController.text,
      "address": addressController.text,
      "dob": dobController.text,
      "pob": pobController.text,
      "branch_name": branchNameController.text,
      "created_at": widget.studentData['created_at'] ?? "",
      "parent_id": widget.studentData['parent_id'] ?? "",
      "branch": widget.studentData['branch'] ?? "",
    };

    debugPrint("Sending data to API: ${jsonEncode(body)}");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      debugPrint("Response status: ${response.statusCode}");
      debugPrint("Response body: ${response.body}");

if (response.statusCode == 200 || response.statusCode == 201) {
  if (context.mounted) {
    await ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Data siswa berhasil diperbarui',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context, body);
  }
} else {
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Gagal memperbarui data siswa',
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e', style: GoogleFonts.poppins())),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: scaleHeight(8)),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: GoogleFonts.poppins(fontSize: scaleWidth(14)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(),
          contentPadding: EdgeInsets.symmetric(
            horizontal: scaleWidth(16),
            vertical: scaleHeight(12),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(scaleWidth(12)),
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Wajib diisi' : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: Text('Edit Data Siswa',
            style: GoogleFonts.poppins(
                fontSize: scaleWidth(18), fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(scaleWidth(16)),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildTextField("Nama Lengkap", fullnameController),
                    buildTextField("Nama Panggilan", nicknameController),
                    buildTextField("Jenis Kelamin (L/P)", genderController),
                    buildTextField("Nama Orang Tua", parentController),
                    buildTextField("Telepon", phoneController, keyboardType: TextInputType.phone),
                    buildTextField("Alamat", addressController),
                    buildTextField("Tempat Lahir", pobController),
                    buildTextField("Tanggal Lahir (YYYY-MM-DD)", dobController, keyboardType: TextInputType.datetime),
                    buildTextField("Cabang", branchNameController),
                    SizedBox(height: scaleHeight(24)),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            updateStudentData();
                          }
                        },
                        icon: Icon(Icons.save, size: scaleWidth(20)),
                        label: Text(
                          "Simpan Perubahan",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: scaleWidth(14),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0069CC),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: scaleHeight(14),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(scaleWidth(12)),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
