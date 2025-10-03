import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/auth_provider.dart';

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
  double _rotationY = 0.0;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    loadProfileData();

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

  Future<void> loadProfileData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final parentId = authProvider.userId;

    if (parentId == null) return;

    final String apiUrl = 'https://api.maestroswim.com/api/trainer/$parentId/';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900]: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Akun Saya', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  _rotationY += details.delta.dx * 0.01;
                });
              },
              onHorizontalDragEnd: (_) {
                setState(() => _rotationY = 0);
              },
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(_rotationY),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[900] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (_, __) {
                          return CustomPaint(
                            painter: CircularSnakePainter(animationValue: _controller.value, isDarkMode: isDark),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: AssetImage('assets/images/atlet_renang.jpg'),
                              backgroundColor: Colors.grey[200],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 15),
                      Text(
                        capitalize(fullname),
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        capitalize(nickname),
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            buildInfoCard(isDark),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () async {
                // await Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (_) => EditProfileScreen(
                //       fullname: fullname,
                //       nickname: nickname,
                //       dob: dob,
                //       bankAccount: bankAccount,
                //       email: email,
                //       phoneNumber: phoneNumber,
                //     ),
                //   ),
                // );
                loadProfileData();
              },
              icon: Icon(Icons.edit, color: Colors.white),
              label: Text('Edit Profil'),
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
    );
  }
  

Widget buildInfoCard(bool isDark) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 20),
    decoration: BoxDecoration(
      color: isDark ? Colors.grey[850] : const Color.fromARGB(255, 255, 255, 255),
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 6,
          offset: Offset(0, 4),
        ),
      ],
    ),
    child: ClipPath(
      clipper: ReceiptClipper(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
        child: Column(
          children: [
            InfoRow(icon: Icons.calendar_month, label: 'Tanggal Lahir', value: dob, isDarkMode: isDark),
            buildDashedLine(),
            InfoRow(icon: Icons.account_balance, label: 'Rekening Bank', value: bankAccount, isDarkMode: isDark),
            buildDashedLine(),
            InfoRow(icon: Icons.email, label: 'Email', value: email, isDarkMode: isDark),
            buildDashedLine(),
            InfoRow(icon: Icons.phone, label: 'No WhatsApp', value: formatPhoneNumber(phoneNumber), isDarkMode: isDark),
          ],
        ),
      ),
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
