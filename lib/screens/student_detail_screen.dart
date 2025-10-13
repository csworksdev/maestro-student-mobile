import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maestro_client_mobile/models/student_profile.dart';
import 'package:maestro_client_mobile/services/student_service.dart';

class StudentDetailScreen extends StatefulWidget {
  final StudentProfile student;

  const StudentDetailScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late StudentProfile student;
  final StudentService _studentService = StudentService();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    student = widget.student;
    _fetchStudentData();
  }

  // Fungsi untuk mengambil data siswa dari API
  Future<void> _fetchStudentData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final updatedStudent = await _studentService.getStudentDetail(student.studentId);
      setState(() {
        student = updatedStudent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format tanggal lahir dari YYYY-MM-DD ke format yang lebih mudah dibaca
    String formattedDob = "";
    try {
      if (student.dob.isNotEmpty) {
        final DateTime dob = DateTime.parse(student.dob);
        formattedDob = DateFormat('dd MMMM yyyy').format(dob);
      }
    } catch (e) {
      formattedDob = student.dob;
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF044366),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
      ),
      body: _isLoading 
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF044366),
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        'Terjadi kesalahan:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchStudentData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF044366),
                        ),
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchStudentData,
                  color: const Color(0xFF044366),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                      // Header dengan foto profil
                      Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF044366),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar
                    CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white,
                      child: Text(
                        student.fullname.isNotEmpty ? student.fullname[0].toUpperCase() : "?",
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF044366),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Nama dan nickname
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Nama lengkap
                          Text(
                            student.fullname,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Badge nickname
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEE7D21),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              student.nickname,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
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
            
            const SizedBox(height: 20),
            
            // Informasi detail siswa
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informasi Pribadi",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF044366),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Card informasi pribadi
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.person, "Nama Lengkap", student.fullname),
                          _buildDivider(),
                          _buildInfoRow(Icons.face, "Nama Panggilan", student.nickname),
                          _buildDivider(),
                          _buildInfoRow(
                            Icons.wc, 
                            "Jenis Kelamin", 
                            student.gender == "L" ? "Laki-laki" : (student.gender == "P" ? "Perempuan" : student.gender)
                          ),
                          _buildDivider(),
                          _buildInfoRow(Icons.cake, "Tanggal Lahir", formattedDob),
                          _buildDivider(),
                          _buildInfoRow(Icons.location_city, "Tempat Lahir", student.pob),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  const Text(
                    "Informasi Kontak",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF044366),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Card informasi kontak
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.person_outline, "Nama Orang Tua", student.parent),
                          _buildDivider(),
                          _buildInfoRow(Icons.phone, "Nomor Telepon", student.phone),
                          _buildDivider(),
                          _buildInfoRow(Icons.home, "Alamat", student.address),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  const Text(
                    "Informasi Pendidikan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF044366),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Card informasi pendidikan
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.school, "Jenjang Pendidikan", student.pendidikan ?? "-"),
                          _buildDivider(),
                          _buildInfoRow(Icons.business, "Institusi", student.institusi ?? "-"),
                        ],
                      ),
                    ),
                  ),                     
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: const Color(0xFFEE7D21),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
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

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFEEEEEE),
    );
  }
}