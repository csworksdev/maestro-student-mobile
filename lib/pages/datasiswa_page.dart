import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/auth_provider.dart';
import 'package:maestro_client_mobile/screens/editprofile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> with SingleTickerProviderStateMixin {
  String fullname = '';
  String nickname = '';
  String dob = '';
  String bankAccount = '';
  String email = '';
  String phoneNumber = '';

  late AnimationController _controller;

  List<Map<String, String>> siswaList = [];

  @override
  void initState() {
    super.initState();
    loadProfileData();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    )..repeat();

    loadSiswaList(); // <-- Tambahkan ini

    // Tambahkan data awal (misal data profile utama)
    siswaList.add({
      'fullname': fullname,
      'nickname': nickname,
      'dob': dob,
      'bankAccount': bankAccount,
      'email': email,
      'phoneNumber': phoneNumber,
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatPhoneNumber(String phone) {
    return phone.startsWith('0') ? phone.replaceFirst('0', '+62') : phone;
  }

  Future<void> loadProfileData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final userId = authProvider.userId;

    if (userId == null) return;

    final String apiUrl = 'https://api.maestroswim.com/api/trainer/$userId/';
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final trainerData = data is Map<String, dynamic> && data.containsKey('fullname')
            ? data
            : (data['results'] != null && data['results'] is List && data['results'].isNotEmpty)
                ? data['results'][0]
                : null;

        if (trainerData != null) {
          setState(() {
            fullname = trainerData['fullname'] ?? '';
            nickname = trainerData['nickname'] ?? '';
            dob = trainerData['dob'] ?? '';
            bankAccount = trainerData['bank_account'] ?? '';
            email = trainerData['email'] ?? '';
            phoneNumber = trainerData['phone'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Error fetching profile data: $e');
    }
  }

  Future<void> saveSiswaList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> siswaJsonList = siswaList.map((siswa) => json.encode(siswa)).toList();
    await prefs.setStringList('siswaList', siswaJsonList);
  }

  Future<void> loadSiswaList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? siswaJsonList = prefs.getStringList('siswaList');
    if (siswaJsonList != null) {
      setState(() {
        siswaList = siswaJsonList.map((siswaJson) => Map<String, String>.from(json.decode(siswaJson))).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // Ubah jadi transparan
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: Text('Data Siswa', style: TextStyle(color: textColor, fontWeight: FontWeight.normal)),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Color(0xFF232526), Color(0xFF414345)]
                : [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(99, 255, 255, 255)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Tampilkan semua card siswa
              ...siswaList.map((siswa) => buildInfoCard(isDark, siswa)).toList(),
              SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    // Tambahkan data dummy siswa baru
                    siswaList.add({
                      'fullname': 'Nama Siswa Baru',
                      'nickname': 'Nickname',
                      'dob': '2000-01-01',
                      'bankAccount': 'Kelas Baru',
                      'email': 'Kolam Baru',
                      'phoneNumber': '08123456789',
                    });
                  });
                  saveSiswaList(); // <-- Tambahkan ini
                },
                icon: Icon(Icons.add_to_photos, color: Colors.white),
                label: Text('Tambah Siswa'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.orange : Color(0xFF003566),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  

  Widget buildInfoCard(bool isDark, Map<String, String> siswa) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(25),
        border: Border.all( // Tambahkan border di sini
        color: isDark ? Colors.orange : Color.fromARGB(103, 0, 53, 102),
        width: 1,
      ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Card content
          ClipPath(
            clipper: ReceiptClipper(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
              child: Column(
                children: [
                  InfoRow(icon: Icons.person, label: 'Nama', value: siswa['fullname'] ?? '', isDarkMode: isDark),
                  buildDashedLine(),
                  InfoRow(icon: Icons.class_, label: 'Kelas', value: siswa['bankAccount'] ?? '', isDarkMode: isDark),
                  buildDashedLine(),
                  InfoRow(icon: Icons.pool, label: 'Kolam', value: siswa['email'] ?? '', isDarkMode: isDark),
                  buildDashedLine(),
                  InfoRow(icon: Icons.phone, label: 'No WhatsApp', value: formatPhoneNumber(siswa['phoneNumber'] ?? ''), isDarkMode: isDark),
                ],
              ),
            ),
          ),
          // Edit button di pojok kanan atas
          Positioned(
            top: 1,
            right: 1,
            child: Material(
              color: Colors.transparent,
              child: PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: isDark ? Colors.orange : Color(0xFF003566),
                  size: 24,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                onSelected: (value) async {
                  if (value == 'edit') {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          fullname: siswa['fullname'] ?? '',
                          nickname: siswa['nickname'] ?? '',
                          dob: siswa['dob'] ?? '',
                          bankAccount: siswa['bankAccount'] ?? '',
                          email: siswa['email'] ?? '',
                          phoneNumber: siswa['phoneNumber'] ?? '',
                        ),
                      ),
                    );
                    loadProfileData();
                  } else if (value == 'delete') {
                    // Tampilkan dialog konfirmasi sebelum menghapus
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Konfirmasi Hapus'),
                        content: Text('Apakah Anda yakin ingin menghapus data siswa ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(), // Tidak jadi hapus
                            child: Text('Tidak'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                siswaList.remove(siswa);
                              });
                              saveSiswaList(); // <-- Tambahkan ini
                              Navigator.of(context).pop(); // Tutup dialog setelah hapus
                            },
                            child: Text('Ya', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, color: Colors.black54),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                color: Colors.white,
                elevation: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReceiptClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    const radius = 8.0;
    final path = Path();

    path.moveTo(0, 0);

    // Sobekan atas
    for (double i = 0; i < size.width; i += radius * 2) {
      path.arcToPoint(
        Offset(i + radius, 0),
        radius: Radius.circular(radius),
        clockwise: i % 4 == 0,
      );
    }

    path.lineTo(size.width, size.height);

    // Sobekan bawah
    for (double i = size.width; i > 0; i -= radius * 2) {
      path.arcToPoint(
        Offset(i - radius, size.height),
        radius: Radius.circular(radius),
        clockwise: i % 4 == 0,
      );
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Widget buildDashedLine() {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = 5.0;
        final dashCount = (constraints.maxWidth / (2 * dashWidth)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return Container(
              width: dashWidth,
              height: 1,
              color: Colors.grey,
            );
          }),
        );
      },
    ),
  );
}


class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDarkMode;

  const InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: isDarkMode ? Colors.orange : Color(0xFF003566)),
        SizedBox(width: 10),
        Text('$label :', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white70 : Colors.black87)),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

String capitalize(String input) {
  return input
      .split(' ')
      .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1).toLowerCase() : '')
      .join(' ');
}

class CircularSnakePainter extends CustomPainter {
  final double animationValue;
  final bool isDarkMode;
  CircularSnakePainter({required this.animationValue, required this.isDarkMode});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = isDarkMode ? Colors.orange : Color(0xFF003566)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final double startAngle = animationValue * 2 * math.pi;
    final double sweepAngle = 2 * math.pi / 2; 

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius + 6),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularSnakePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}
