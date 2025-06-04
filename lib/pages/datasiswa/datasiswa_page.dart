import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:maestro_client_mobile/pages/datasiswa/detaildatasiswa_screen.dart';

class DataSiswaPage extends StatefulWidget {
  const DataSiswaPage({super.key});

  @override
  State<DataSiswaPage> createState() => _DataSiswaPageState();
}

class _DataSiswaPageState extends State<DataSiswaPage> {
  List<Map<String, dynamic>> allStudents = [];
  bool isLoading = true;

  late double screenWidth;
  late double screenHeight;

  double scaleWidth(double value) => screenWidth / 375 * value;
  double scaleHeight(double value) => screenHeight / 812 * value;

  @override
  void initState() {
    super.initState();
    fetchAllStudents();
  }

Future<void> fetchAllStudents() async {
  final url = Uri.parse("https://api.maestroswim.com/api/student/");
  try {
    debugPrint("Memulai fetch data siswa...");
    final response = await http.get(url);

    debugPrint("Status code: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['results'] != null && data['results'] is List) {
        final results = List<Map<String, dynamic>>.from(data['results']);
        setState(() {
          allStudents = results;
          isLoading = false;
        });
        debugPrint("Data siswa berhasil dimuat. Jumlah data: ${allStudents.length}");
      } else {
        debugPrint("Data 'results' tidak ditemukan atau bukan List.");
      }
    } else {
      debugPrint("Gagal memuat data siswa. Status: ${response.statusCode}");
      throw Exception("Gagal memuat data siswa");
    }
  } catch (e) {
    debugPrint("Terjadi kesalahan saat mengambil data siswa: $e");
    setState(() {
      isLoading = false;
    });
  }
}

  Widget buildStudentCard(Map<String, dynamic> student) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(scaleWidth(20)),
      ),
      margin: EdgeInsets.only(bottom: scaleHeight(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0069CC), Color(0xFF003566)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(scaleWidth(20)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0069CC).withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: scaleWidth(20),
          vertical: scaleHeight(24),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: -scaleHeight(10),
              right: -scaleWidth(1),
              child: Icon(
                Icons.pool,
                size: scaleWidth(60),
                color: Colors.white.withOpacity(0.08),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.person, color: Colors.white, size: scaleWidth(20)),
                    SizedBox(width: scaleWidth(8)),
                    Expanded(
                      child: Text(
                        student['fullname'] ?? '-',
                        style: GoogleFonts.poppins(
                          fontSize: scaleWidth(16),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white, size: scaleWidth(20)),
                  ],
                ),
                SizedBox(height: scaleHeight(10)),
                Row(
                  children: [
                    Icon(Icons.business, color: Colors.white, size: scaleWidth(18)),
                    SizedBox(width: scaleWidth(8)),
                    Expanded(
                      child: Text(
                        student['branch_name'] ?? '-',
                        style: GoogleFonts.poppins(
                          fontSize: scaleWidth(14),
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
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
        title: Text(
          'Data Siswa',
          style: GoogleFonts.poppins(
            fontSize: scaleWidth(20),
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        centerTitle: true,
      ),
body: isLoading
    ? const Center(child: CircularProgressIndicator())
    : allStudents.isEmpty
        ? Center(
            child: Text(
              "Tidak ada data siswa",
              style: GoogleFonts.poppins(fontSize: scaleWidth(14)),
            ),
          )
        : RefreshIndicator(
            onRefresh: fetchAllStudents,
            child: Padding(
              padding: EdgeInsets.all(scaleWidth(16)),
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: allStudents.length,
                itemBuilder: (context, index) => GestureDetector(
                  onTap: () async {
                    final updatedStudent = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailDataSiswaScreen(
                          studentData: allStudents[index],
                        ),
                      ),
                    );
                    if (updatedStudent != null) {
                      setState(() {
                        final i = allStudents.indexWhere((s) =>
                            s['student_id'] ==
                            updatedStudent['student_id']);
                        if (i != -1) allStudents[i] = updatedStudent;
                      });
                    }
                  },
                  child: buildStudentCard(allStudents[index]),
                ),
              ),
            ),
          ),
    );
  }
}
