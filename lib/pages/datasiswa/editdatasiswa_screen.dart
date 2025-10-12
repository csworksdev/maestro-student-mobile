import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  String selectedGender = 'L';
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
    selectedGender = widget.studentData['gender'] ?? 'L';
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
    "gender": selectedGender,
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

  try {
    debugPrint("Mengirim data ke API: ${jsonEncode(body)}");
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    debugPrint("Status respons dari API: ${response.statusCode}");
    debugPrint("Respons body: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint("✅ Data berhasil dikirim ke API");

      await saveToLocalStorage(body);
      debugPrint("✅ Data juga disimpan ke SharedPreferences");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data siswa berhasil diperbarui', style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, body);
      }
    } else {
      debugPrint("❌ Gagal memperbarui data siswa. Status code: ${response.statusCode}");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui data siswa', style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    debugPrint("❗ Error saat update data siswa: $e");

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e', style: GoogleFonts.poppins())),
      );
    }
  } finally {
    setState(() => isLoading = false);
  }
}

  Future<void> saveToLocalStorage(Map<String, dynamic> studentData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('studentData', jsonEncode(studentData));
  }

  Widget buildTextField(String label, TextEditingController controller,
      {TextInputType? keyboardType, bool readOnly = false, VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: scaleHeight(8)),
      child: Material(
        elevation: 3,
        shadowColor: const Color.fromARGB(100, 0, 0, 0),
        borderRadius: BorderRadius.circular(scaleWidth(12)),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          readOnly: readOnly,
          onTap: onTap,
          style: GoogleFonts.poppins(fontSize: scaleWidth(14)),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(),
            filled: true,
            fillColor: const Color.fromARGB(255, 250, 250, 250),
            contentPadding: EdgeInsets.symmetric(
              horizontal: scaleWidth(16),
              vertical: scaleHeight(14),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scaleWidth(12)),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (value) =>
              value == null || value.isEmpty ? 'Wajib diisi' : null,
        ),
      ),
    );
  }

  Widget buildDropdownGender() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: scaleHeight(8)),
      child: Material(
        elevation: 4,
        shadowColor: const Color.fromARGB(100, 0, 0, 0),
        borderRadius: BorderRadius.circular(scaleWidth(12)),
        child: DropdownButtonFormField<String>(
          value: selectedGender,
          decoration: InputDecoration(
            labelText: "Jenis Kelamin",
            labelStyle: GoogleFonts.poppins(),
            filled: true,
            fillColor: const Color.fromARGB(255, 250, 250, 250),
            contentPadding: EdgeInsets.symmetric(
              horizontal: scaleWidth(16),
              vertical: scaleHeight(14),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(scaleWidth(12)),
              borderSide: BorderSide.none,
            ),
          ),
          items: ['L', 'P'].map((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value == 'L' ? 'Laki-laki' : 'Perempuan',
                  style: GoogleFonts.poppins()),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                selectedGender = value;
              });
            }
          },
        ),
      ),
    );
  }

  Future<void> selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(dobController.text) ?? DateTime(2010),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = picked.toIso8601String().split('T').first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Edit Data Siswa',
            style: GoogleFonts.poppins()),
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
                    buildDropdownGender(),
                    buildTextField("Nama Orang Tua", parentController),
                    buildTextField("Telepon", phoneController,
                        keyboardType: TextInputType.phone),
                    buildTextField("Alamat", addressController),
                    buildTextField("Tempat Lahir", pobController),
                    buildTextField("Tanggal Lahir", dobController,
                        readOnly: true, onTap: selectDate),
                    buildTextField("Cabang", branchNameController),
                    SizedBox(height: scaleHeight(24)),
                SizedBox(
  width: screenWidth * 0.65,
  height: 50,
  child: InkWell(
    onTap: () {
      if (_formKey.currentState!.validate()) {
        updateStudentData();
      }
    },
    borderRadius: BorderRadius.circular(30),
    child: Ink(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2196F3), // Maestro biru utama
            Color(0xFF0D47A1), // Biru tua Maestro
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              "Simpan Perubahan",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
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
