import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:maestro_client_mobile/pages/datasiswa/editdatasiswa_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/rendering.dart';

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
double scaleWidth(BuildContext context, double value) => value * screenWidth(context) / 375; // 375 = width iPhone 11
double scaleHeight(BuildContext context, double value) => value * screenHeight(context) / 812; // 812 = height iPhone 11

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  List<Map<String, dynamic>> siswaList = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String formatPhoneNumber(String phone) {
    return phone.startsWith('0') ? phone.replaceFirst('0', '+62') : phone;
  }

  Future<void> showAddSiswaDialog(BuildContext context) async {
    final _formKey = GlobalKey<FormState>();
    final fullnameController = TextEditingController();
    final nicknameController = TextEditingController();
    final genderController = TextEditingController();
    final parentController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final dobController = TextEditingController();
    final pobController = TextEditingController();
    final branchController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Tambah Siswa Baru'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: fullnameController,
                    decoration: InputDecoration(labelText: 'Nama Lengkap'),
                    validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
                  ),
                  TextFormField(
                    controller: nicknameController,
                    decoration: InputDecoration(labelText: 'Panggilan'),
                  ),
                  TextFormField(
                    controller: genderController,
                    decoration: InputDecoration(labelText: 'Gender (l/p)'),
                  ),
                  TextFormField(
                    controller: parentController,
                    decoration: InputDecoration(labelText: 'Orang Tua'),
                  ),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'No HP'),
                  ),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(labelText: 'Alamat'),
                  ),
                  TextFormField(
                    controller: dobController,
                    decoration: InputDecoration(labelText: 'Tanggal Lahir (YYYY-MM-DD)'),
                  ),
                  TextFormField(
                    controller: pobController,
                    decoration: InputDecoration(labelText: 'Tempat Lahir'),
                  ),
                  TextFormField(
                    controller: branchController,
                    decoration: InputDecoration(labelText: 'Branch (ID)'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        title: Text('Data Siswa', style: GoogleFonts.poppins(color: textColor, fontWeight: FontWeight.normal)),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
        },
        color: isDark ? Colors.orange : Color(0xFF003566),
        backgroundColor: Colors.white,
        child: Column(
          children: [
          ],
        ),
      ),
    );
  }

  // Card siswa: tampilkan seluruh biodata dengan desain modern, elegan, dan responsif
  Widget buildSiswaCard(BuildContext context, Map<String, dynamic> siswa, bool isDark, int idx) {
    final nama = siswa['fullname'] ?? '-';
    final panggilan = siswa['nickname'] ?? '-';
    final gender = siswa['gender'] ?? '-';
    final parent = siswa['parent'] ?? '-';
    final phone = formatPhoneNumber(siswa['phone'] ?? siswa['phoneNumber'] ?? '');
    final address = siswa['address'] ?? '-';
    final dob = siswa['dob'] ?? '-';
    final pob = siswa['pob'] ?? '-';
    final parentId = siswa['parent_id']?.toString() ?? '-';
    final branch = siswa['branch'] ?? '-';

    return Container(
      margin: EdgeInsets.symmetric(vertical: scaleHeight(context, 12), horizontal: 12),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF003566),
            Color.fromARGB(255, 0, 100, 200),
            Color(0xFF00B4D8).withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF003566).withOpacity(0.13),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark/logo transparan di background kanan bawah
          Positioned(
            bottom: scaleHeight(context,55),
            right: scaleWidth(context, 16),
            child: Opacity(
              opacity: 0.06,
              child: Icon(
                Icons.pool, // Ganti dengan logo sendiri jika ada asset
                size: scaleWidth(context, 250),
                color: Colors.white,
              ),
            ),
          ),
          // Aksen garis lengkung di sudut kiri atas
          Positioned(
            top: 0,
            left: 0,
            child: CustomPaint(
              size: Size(scaleWidth(context, 100), scaleHeight(context, 40)),
              painter: TopLeftCurvePainter(),
            ),
          ),
          // Aksen pattern dots di sudut kanan atas
          Positioned(
            top: scaleHeight(context, 24),
            right: scaleWidth(context, 24),
            child: Row(
              children: List.generate(5, (i) => Container(
                width: 8,
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.50),
                  shape: BoxShape.circle,
                ),
              )),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: scaleWidth(context, 24), vertical: scaleHeight(context, 24)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: scaleWidth(context, 62),
                      height: scaleWidth(context, 62),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [Color.fromARGB(255, 0, 116, 225).withOpacity(0.7), Color.fromARGB(255, 0, 65, 125)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF003566).withOpacity(0.2),
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(Icons.person, color: Colors.white, size: scaleWidth(context, 40)),
                      ),
                    ),
                    SizedBox(width: scaleWidth(context, 20)),
                    Expanded(
                      child: Text(
                        nama,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: scaleWidth(context, 16),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: scaleHeight(context, 18)),
                buildBiodataRow(context, Icons.person_outline, 'Panggilan', panggilan, fontSize: 14, iconSize: 22),
                buildBiodataRow(context, Icons.wc, 'Gender', gender, fontSize: 14, iconSize: 22),
                buildBiodataRow(context, Icons.people, 'Orang Tua', parent, fontSize: 14, iconSize: 22),
                buildBiodataRow(context, Icons.phone, 'No WhatsApp', phone, fontSize: 14, iconSize: 22),
                buildBiodataRow(context, Icons.home, 'Alamat', address, fontSize: 14, iconSize: 22),
                buildBiodataRow(context, Icons.cake, 'Tanggal Lahir', dob, fontSize: 14, iconSize: 22),
                buildBiodataRow(context, Icons.location_city, 'Tempat Lahir', pob, fontSize: 14, iconSize: 22),
                buildBiodataRow(context, Icons.badge, 'Parent ID', parentId, fontSize: 14, iconSize: 22),
                buildBiodataRow(context, Icons.account_tree, 'Branch', branch, fontSize: 14, iconSize: 22),
                SizedBox(height: scaleHeight(context, 18)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        // Cek id siswa
                        final siswaId = siswa['id'] ?? 1; // Hardcode id: 1 jika null (untuk testing)
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditDataSiswa(
                              id: siswaId, // gunakan id dari API atau hardcode 1
                              nama: nama,
                              kelas: '-',
                              kolam: '-',
                              phoneNumber: phone,
                              index: idx,
                            ),
                          ),
                        ).then((updatedData) {
                          if (updatedData != null) {
                          }
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        margin: EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.30),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.white, size: 22),
                            SizedBox(width: 6),
                            Text('Edit', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if ((nama ?? '').isEmpty)
            Positioned(
              top: scaleHeight(context, 8),
              left: scaleWidth(context, 8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: scaleWidth(context, 10), vertical: scaleHeight(context, 4)),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(scaleWidth(context, 12)),
                ),
                child: Text(
                  'Baru',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: scaleWidth(context, 12)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Widget baris biodata dengan ukuran dinamis
  Widget buildBiodataRow(BuildContext context, IconData icon, String label, String value, {double fontSize = 15, double iconSize = 20}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: scaleHeight(context, 4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: scaleWidth(context, iconSize)),
          SizedBox(width: scaleWidth(context, 10)),
          Text('$label:', style: GoogleFonts.poppins(color: Colors.white70, fontSize: scaleWidth(context, fontSize), fontWeight: FontWeight.w500)),
          SizedBox(width: scaleWidth(context, 8)),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(color: Colors.white, fontSize: scaleWidth(context, fontSize)),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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

Widget buildDashedLine(BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: scaleHeight(context, 10)),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final dashWidth = scaleWidth(context, 5.0);
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
        Icon(icon, color: isDarkMode ? Colors.orange : Color(0xFF003566), size: scaleWidth(context, 20)),
        SizedBox(width: scaleWidth(context, 10)),
        Text('$label :', style: GoogleFonts.poppins(fontWeight: FontWeight.normal, color: isDarkMode ? Colors.white70 : Color.fromARGB(255, 0, 0, 0), fontSize: scaleWidth(context, 1))),
        SizedBox(width: scaleWidth(context, 10)),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(color: isDarkMode ? const Color.fromARGB(255, 255, 255, 255) : Color.fromARGB(255, 0, 0, 0), fontSize: scaleWidth(context, 16)),
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

// Tambahkan CustomPainter untuk aksen garis lengkung
class TopLeftCurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.5, 0, size.width, size.height * 0.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
