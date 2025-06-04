import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'editdatasiswa_screen.dart';

class DetailDataSiswaScreen extends StatefulWidget {
  final Map<String, dynamic> studentData;

  const DetailDataSiswaScreen({super.key, required this.studentData});

  @override
  State<DetailDataSiswaScreen> createState() => _DetailDataSiswaScreenState();
}

class _DetailDataSiswaScreenState extends State<DetailDataSiswaScreen> {
  late Map<String, dynamic> currentStudentData;

  @override
  void initState() {
    super.initState();
    currentStudentData = widget.studentData;
    loadSavedData();
  }

  Future<void> loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedData = prefs.getString('studentData');
    if (savedData != null) {
      setState(() {
        currentStudentData = jsonDecode(savedData);
      });
    }
  }

  Future<void> refreshData() async {
    await loadSavedData();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Widget buildDetailItem(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? '-',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FF),
      appBar: AppBar(
        title: Text('Detail Siswa', style: GoogleFonts.poppins()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color.fromARGB(255, 27, 145, 255), Color.fromARGB(255, 0, 80, 154)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -30,
                        right: -15,
                        child: Icon(
                          Icons.school,
                          size: 220,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          buildDetailItem(Icons.person, "Nama Lengkap", currentStudentData['fullname']),
                          buildDetailItem(Icons.badge, "Nama Panggilan", currentStudentData['nickname']),
                          buildDetailItem(Icons.transgender, "Jenis Kelamin", currentStudentData['gender']),
                          buildDetailItem(Icons.family_restroom, "Nama Orang Tua", currentStudentData['parent']),
                          buildDetailItem(Icons.phone, "Telepon", currentStudentData['phone']),
                          buildDetailItem(Icons.home, "Alamat", currentStudentData['address']),
                          buildDetailItem(Icons.location_city, "Tempat Lahir", currentStudentData['pob']),
                          buildDetailItem(Icons.cake, "Tanggal Lahir", currentStudentData['dob']),
                          buildDetailItem(Icons.business, "Cabang", currentStudentData['branch_name']),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
Center(
  child: Container(
    width: screenWidth * 0.65,
    height: 50,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color.fromARGB(255, 0, 95, 183), Color.fromARGB(255, 0, 51, 99)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(50),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF0069CC).withOpacity(0.25),
          offset: const Offset(0, 4),
          blurRadius: 8,
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () async {
          final updatedStudent = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditDataSiswaScreen(studentData: currentStudentData),
            ),
          );
          if (updatedStudent != null && context.mounted) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('studentData', jsonEncode(updatedStudent));
            setState(() {
              currentStudentData = updatedStudent;
            });
          }
        },
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                "Edit Data",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ],
          ),
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