import 'package:flutter/material.dart';
import 'package:maestro_client_mobile/pages/datasiswa_page.dart';
import 'package:url_launcher/url_launcher.dart';

// Tambahkan stateful widget agar bisa mengatur loading state pada refresh

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

// Tambahkan fungsi _buildPreventionItem di bawah ini
Widget _buildPreventionItem(
  String label,
  IconData icon,
  Color iconColor,
  Color bgColor,
  Size size,
) {
  return Column(
    children: [
      Container(
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(size.width * 0.035),
        child: Icon(icon, color: iconColor, size: size.width * 0.08),
      ),
      SizedBox(height: size.height * 0.008),
      SizedBox(
        width: size.width * 0.22,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size.width * 0.032,
            color: iconColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ],
  );
}

// Tambahkan di bawah _buildPreventionItem
Widget _buildAnimatedPreventionItem(
  String label,
  IconData icon,
  Color iconColor,
  Color bgColor,
  Size size,
) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(50),
      splashColor: iconColor.withOpacity(0.15),
      onTap: () {
        // Bisa tambahkan aksi jika diperlukan
      },
      child: _buildPreventionItem(label, icon, iconColor, bgColor, size),
    ),
  );
}

class _DashboardScreenState extends State<DashboardScreen> {

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  // Tambahkan fungsi untuk membuka WhatsApp
  void _launchWhatsApp() async {
    final phone = '6282118040677'; // Ganti dengan nomor WhatsApp tujuan (format internasional, tanpa +)
    final message = Uri.encodeComponent("Halo, saya ingin bertanya tentang Maestro Swim.");
    final url = 'https://wa.me/$phone?text=$message';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      // Bisa tambahkan snackbar jika gagal
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primaryColor = const Color(0xEF003566);
    final secondaryColor = const Color(0xFFFFFFFF);

    return Scaffold(
      body: Stack(
        children: [
          // Background dengan WaveClipper
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: size.height * 0.38,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Konten utama dengan RefreshIndicator
          RefreshIndicator(
            onRefresh: _onRefresh,
            color: primaryColor,
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.04,
                  vertical: size.height * 0.01,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Section
                    Text(
                      "Selamat Pagi, Arya!",
                      style: TextStyle(
                        fontSize: size.width * 0.07,
                        fontWeight: FontWeight.bold,
                        color: secondaryColor,
                      ),
                    ),
                    // SizedBox(height: size.height * 0.01),
                    Text(
                      "Selamat Datang di Maestro Swim!",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: size.width * 0.04,
                        color: secondaryColor.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: size.height * 0.025),

                    // Search Bar
                    Container(
                      margin: EdgeInsets.only(bottom: size.height * 0.02),
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey[600]),
                          SizedBox(width: size.width * 0.02),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search...",
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: size.width * 0.04,
                                ),
                              ),
                              style: TextStyle(fontSize: size.width * 0.04),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Card(
                      color: const Color.fromARGB(200, 255, 255, 255),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.05),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LayoutBuilder(
                              builder: (context, constraints) {
                                // Hitung childAspectRatio dinamis berdasarkan lebar/tinggi card
                                double gridWidth = constraints.maxWidth;
                                double gridHeight = size.height * 0.25;
                                double childAspectRatio = gridWidth / 2 / (gridHeight / 2);

                                return GridView.count(
                                  crossAxisCount: 2,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: size.width * 0.04,
                                  mainAxisSpacing: size.height * 0.02,
                                  childAspectRatio: childAspectRatio > 1.2 ? 1.2 : childAspectRatio,
                                  children: [
                                    _buildProjectCard(
                                      context,
                                      title: "Data Siswa",
                                      icon: Icons.person,
                                      color: const Color.fromRGBO(255, 255, 255, 1),
                                      textColor: primaryColor,
                                      iconColor: primaryColor,
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => AccountScreen()),
                                        );
                                      },
                                      border: Border.all(
                                        color: primaryColor.withOpacity(0.4),
                                        width: 2,
                                      ),
                                      fontSize: size.width * 0.040, // Atur ukuran font di sini
                                    ),
                                    _buildProjectCard(
                                      context,
                                      title: "Kehadiran",
                                      icon: Icons.edit_calendar_outlined,
                                      color: Colors.white,
                                      textColor: primaryColor,
                                      iconColor: primaryColor,
                                      onTap: () {},
                                        border: Border.all(
                                        color: primaryColor.withOpacity(0.4),
                                        width: 2,
                                      ),
                                      fontSize: size.width * 0.040,
                                    ),
                                    _buildProjectCard(
                                      context,
                                      title: "Jadwal Latihan",
                                      icon: Icons.schedule,
                                      color: Colors.white,
                                      textColor: primaryColor,
                                      iconColor: primaryColor,
                                      onTap: () {},
                                        border: Border.all(
                                        color: primaryColor.withOpacity(0.4),
                                        width: 2,
                                      ),
                                      fontSize: size.width * 0.038,
                                    ),
                                    _buildProjectCard(
                                      context,
                                      title: "Progres Latihan",
                                      icon: Icons.show_chart,
                                      color: Colors.white,
                                      textColor: primaryColor,
                                      iconColor: primaryColor,
                                      onTap: () {},
                                        border: Border.all(
                                        color: primaryColor.withOpacity(0.4),
                                        width: 2,
                                      ),
                                      fontSize: size.width * 0.038,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    // Program Renang
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFe0eafc),
                              const Color.fromARGB(100, 0, 53, 102),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueGrey.withOpacity(0.08),
                              blurRadius: 16,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Watermark icon
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Opacity(
                                opacity: 0.099,
                                child: Icon(
                                  Icons.pool,
                                  size: size.width * 0.48,
                                  color: Color(0xFF003566),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(size.width * 0.035),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Program Renang",
                                    style: TextStyle(
                                      fontSize: size.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF003566),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.018),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        _buildAnimatedPreventionItem("Baby Swim", Icons.child_care, Color(0xFF003566), Colors.white, size),
                                        SizedBox(width: size.width * 0.015),
                                        _buildAnimatedPreventionItem("Private 1", Icons.person_add, Color(0xFF003566), Colors.white, size),
                                        SizedBox(width: size.width * 0.015),
                                        _buildAnimatedPreventionItem("Private 2", Icons.people_alt, Color(0xFF003566), Colors.white, size),
                                        SizedBox(width: size.width * 0.015),
                                        _buildAnimatedPreventionItem("Grup", Icons.groups, Color(0xFF003566), Colors.white, size),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    
                    // Contact Us
                    Card(
                      color: const Color.fromARGB(200, 65, 90, 116),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.030),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Contact Us",
                                    style: TextStyle(
                                      fontSize: size.width * 0.042,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: size.height * 0.004),
                                  Text(
                                    "Ada pertanyaan? Hubungi admin!",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: size.width * 0.034,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: size.width * 0.03),
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              elevation: 2,
                              child: InkWell(
                                onTap: _launchWhatsApp,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                  padding: EdgeInsets.all(size.width * 0.025),
                                  child: Image.asset(
                                    'assets/images/whatsapp.logo.png',
                                    width: size.width * 0.16,
                                    height: size.width * 0.12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 80);
    var secondEndPoint = Offset(size.width, size.height - 40);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

Widget _buildProjectCard(
  BuildContext context, {
  required String title,
  required IconData icon,
  required dynamic color, // Shader or Color
  required Color textColor,
  required Color iconColor,
  required VoidCallback onTap,
  BoxBorder? border,
  double? fontSize, // Tambahkan parameter fontSize opsional
}) {
  final size = MediaQuery.of(context).size;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      decoration: BoxDecoration(
        color: color is Color ? color : null,
        borderRadius: BorderRadius.circular(18),
        border: border,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark icon
          Positioned(
            right: -size.width * 0.1,
            bottom: -size.width * -0.085,
            child: Opacity(
              opacity: 0.099,
              child: Icon(
                icon,
                size: size.width * 0.30,
                color: iconColor,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(size.width * 0.035),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: iconColor, size: size.width * 0.14), // Perbesar sesuai kebutuhan
                  SizedBox(height: size.height * 0.012),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize ?? size.width * 0.042, // Gunakan fontSize jika ada
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}