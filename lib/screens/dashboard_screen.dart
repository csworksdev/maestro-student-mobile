import 'package:flutter/material.dart';
import 'package:maestro_client_mobile/pages/datasiswa_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';

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

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
              height: size.height * 0.60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor,
                    const Color.fromARGB(255, 0, 213, 255),
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
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting Section
                    Padding(
                      padding: EdgeInsets.only(left: size.width * 0.02),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Hi, Arya!",
                            style: GoogleFonts.nunito(
                              fontSize: size.width * 0.065,
                              fontWeight: FontWeight.bold,
                              color: secondaryColor,
                            ),
                          ),
                          Text(
                            "Welcome to Maestro Swim!",
                            style: GoogleFonts.nunito(
                              fontSize: size.width * 0.040,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.normal,
                              color: secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),

                    // Search Bar
                    AnimatedContainer(
                      duration: Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      margin: EdgeInsets.only(bottom: size.height * 0.02),
                      padding: EdgeInsets.symmetric(horizontal: size.width * 0.04),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        borderRadius: BorderRadius.circular(38),
                        border: Border.all(
                          width: 2,
                          color: _isSearching ? Color(0xFF00B4D8) : Color(0xEF003566),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) => RotationTransition(turns: anim, child: child),
                            child: _isSearching && _searchController.text.isNotEmpty
                                ? GestureDetector(
                                    key: ValueKey('close'),
                                    onTap: () {
                                      _searchController.clear();
                                      setState(() {
                                        _isSearching = false;
                                      });
                                    },
                                    child: Icon(Icons.close, color: primaryColor, size: size.width * 0.06),
                                  )
                                : Icon(Icons.search, key: ValueKey('search'), color: Color(0xEF003566)),
                          ),
                          SizedBox(width: size.width * 0.02),
                          Expanded(
                            child: FocusScope(
                              child: Focus(
                                onFocusChange: (hasFocus) {
                                  setState(() {
                                    _isSearching = hasFocus || _searchController.text.isNotEmpty;
                                  });
                                },
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) {
                                    setState(() {
                                      _isSearching = val.isNotEmpty;
                                    });
                                  },
                                  decoration: InputDecoration(
                                    hintText: "Search...",
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(
                                      color: Colors.blueGrey[300],
                                      fontSize: size.width * 0.042,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  style: GoogleFonts.nunito(
                                    fontSize: size.width * 0.042,
                                  ),
                                  cursorColor: Color(0xEF003566),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // New Elegant Card Wrapper
                    Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(size.width * 0.02),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Cards in a 2x2 grid
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: size.width * 0.001),
                              child: SizedBox(
                                height: size.height * 0.18, // Sesuaikan tinggi card
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.01),
                                  children: [
                                    buildCategoryCard(
                                      icon: Icons.person,
                                      title: "Data Siswa",
                                      color: const Color(0xEF003566),
                                      gradient: LinearGradient(colors: [Color(0xFF003566), Color(0xFF00509E)]),
                                      iconGradient: LinearGradient(colors: [Color(0xFF00509E), Color(0xFF003566)]),
                                      accent: Icon(Icons.star, color: Colors.white.withOpacity(0.13), size: size.width * 0.10),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => AccountScreen()), // Navigate to DataSiswaPage
                                        );
                                      },
                                    ),
                                    SizedBox(width: size.width * 0.002),
                                    buildCategoryCard(
                                      icon: Icons.edit_calendar_outlined,
                                      title: "Kehadiran",
                                      color: const Color(0xEF003566),
                                      gradient: LinearGradient(colors: [Color(0xFF00509E), Color(0xFF00B4D8)]),
                                      iconGradient: LinearGradient(colors: [Color(0xFF00B4D8), Color(0xFF00509E)]),
                                      accent: Icon(Icons.circle, color: Colors.white.withOpacity(0.10), size: size.width * 0.09),
                                    ),
                                    SizedBox(width: size.width * 0.002),
                                    buildCategoryCard(
                                      icon: Icons.schedule,
                                      title: "Jadwal",
                                      color: const Color(0xEF003566),
                                      gradient: LinearGradient(colors: [Color(0xFF00B4D8), Color(0xFF90E0EF)]),
                                      iconGradient: LinearGradient(colors: [Color(0xFF90E0EF), Color(0xFF00B4D8)]),
                                      accent: Icon(Icons.favorite, color: Colors.white.withOpacity(0.10), size: size.width * 0.09),
                                    ),
                                    SizedBox(width: size.width * 0.002),
                                    buildCategoryCard(
                                      icon: Icons.show_chart,
                                      title: "Progres",
                                      color: const Color(0xEF003566),
                                      gradient: LinearGradient(colors: [Color(0xFF90E0EF), Color(0xFF003566)]),
                                      iconGradient: LinearGradient(colors: [Color(0xFF003566), Color(0xFF90E0EF)]),
                                      accent: Icon(Icons.bubble_chart, color: Colors.white.withOpacity(0.10), size: size.width * 0.09),
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
                                      Color.fromARGB(200, 0, 53, 102), Color.fromARGB(200, 0, 118, 182),
                                      Color.fromARGB(200, 33, 147, 176) , Color.fromARGB(200, 109, 213, 237),
                                      Color(0xFF2980B9) , Color(0xFF6DD5FA)
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                padding: EdgeInsets.all(size.width * 0.04),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Program Renang",
                                      style: GoogleFonts.rubik(
                                        fontSize: size.width * 0.045,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(238, 255, 255, 255)
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.015),
                                    _buildProgramCarousel(),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: size.height * 0.02),
                            // Contact Us
                            TweenAnimationBuilder<double>(
                              key: ValueKey('contact_card_animation'),
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: Duration(milliseconds: 900),
                              curve: Curves.easeOutBack,
                              builder: (context, value, child) => Opacity(
                                opacity: value.clamp(0.0, 1.0),
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * 30),
                                  child: child,
                                ),
                              ),
                              child: Card(
                                color: Colors.white.withOpacity(0.18),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                    child: Padding(
                                      padding: EdgeInsets.all(size.width * 0.030),
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          return FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                // Avatar admin/ilustrasi
                                                Container(
                                                  width: size.width * 0.10,
                                                  height: size.width * 0.15,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Color(0xFF90E0EF),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Color(0xFF00B4D8).withOpacity(0.13),
                                                        blurRadius: 8,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "👩🏻‍💼",
                                                      style: TextStyle(fontSize: size.width * 0.08),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: size.width * 0.03),
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxWidth: size.width * 0.48,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          ShaderMask(
                                                            shaderCallback: (Rect bounds) {
                                                              return LinearGradient(
                                                                colors: [Color(0xFF00B4D8), Color(0xFF003566)],
                                                                begin: Alignment.topLeft,
                                                                end: Alignment.bottomRight,
                                                              ).createShader(bounds);
                                                            },
                                                            child: Text(
                                                              "Contact Us ",
                                                              style: GoogleFonts.nunito(
                                                                fontSize: size.width * 0.042,
                                                                fontWeight: FontWeight.bold,
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                          Icon(Icons.chat_bubble_rounded, color: Color(0xFF00B4D8), size: size.width * 0.055),
                                                        ],
                                                      ),
                                                      SizedBox(height: size.height * 0.004),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: Color(0xFF00B4D8).withOpacity(0.09),
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Icon(Icons.info_outline, color: Color(0xFF00B4D8), size: size.width * 0.035),
                                                            SizedBox(width: 4),
                                                            Expanded(
                                                              child: Text(
                                                                "Ada pertanyaan? Hubungi admin!",
                                                                style: GoogleFonts.nunito(
                                                                  fontStyle: FontStyle.italic,
                                                                  fontSize: size.width * 0.034,
                                                                  color: Color(0xFF003566),
                                                                ),
                                                                maxLines: 6,
                                                                softWrap: true,
                                                              ),
                                                            ),
                                                            SizedBox(width: 4),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: size.width * 0.02),
                                                _AnimatedWhatsAppButton(size: size, onTap: _launchWhatsApp),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
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
    final path = Path();
    // Mulai dari kiri atas
    path.lineTo(0, size.height * 0.40);

    // Buat setengah lingkaran di bawah
    path.quadraticBezierTo(
      size.width / 2, size.height * 0.70,
      size.width, size.height * 0.40,
    );

    // Lanjut ke kanan atas
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Widget buildCategoryCard({
  required IconData icon,
  required String title,
  required Color color,
  Gradient? gradient,
  Gradient? iconGradient,
  VoidCallback? onTap,
  Widget? accent,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AspectRatio(
      aspectRatio: 0.9,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: gradient,
          color: gradient == null ? color : null,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: Colors.white, width: 3),
        ),
        child: Stack(
          children: [
            if (accent != null)
              Positioned(
                top: 0,
                right: 0,
                child: accent,
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: iconGradient ?? LinearGradient(colors: [color.withOpacity(0.7), color]),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(icon, color: Colors.white, size: 40),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildSwimProgramCard({required String imagePath, required String label}) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      image: DecorationImage(
        image: AssetImage(imagePath),
        fit: BoxFit.cover,
      ),
    ),
    child: Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white, width: 1),
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.5),
                Colors.transparent,
              ],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
          ),
        ),
        Positioned(
          right: 6,
          bottom: 6,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              label,
              style: GoogleFonts.rubik(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xEF003566),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildProgramCarousel() {
  final List<Map<String, String>> programs = [
    {'image': 'assets/images/babyswim.jpg', 'label': 'Baby Swim'},
    {'image': 'assets/images/private1.jpg', 'label': 'Private 1'},
    {'image': 'assets/images/private2.jpg', 'label': 'Private 2'},
    {'image': 'assets/images/grup.png', 'label': 'Grup'},
  ];

  return CarouselSlider.builder(
    itemCount: programs.length,
    itemBuilder: (context, index, realIdx) {
      return _buildSwimProgramCard(
        imagePath: programs[index]['image']!,
        label: programs[index]['label']!,
      );
    },
    options: CarouselOptions(
      height: 120,
      autoPlay: true,
      autoPlayInterval: Duration(seconds: 4),
      enlargeCenterPage: true, // <<< Efek besar di tengah
      enlargeFactor: 0.35,     // <<< Seberapa besar pembesaran
      viewportFraction: 0.65,  // <<< Seberapa lebar tiap item
      initialPage: 0,
      enableInfiniteScroll: true,
      pauseAutoPlayOnTouch: true,
      scrollPhysics: BouncingScrollPhysics(),
    ),
  );
}

// Animated WhatsApp Button
class _AnimatedWhatsAppButton extends StatefulWidget {
  final Size size;
  final VoidCallback onTap;
  const _AnimatedWhatsAppButton({required this.size, required this.onTap});
  @override
  State<_AnimatedWhatsAppButton> createState() => _AnimatedWhatsAppButtonState();
}

class _AnimatedWhatsAppButtonState extends State<_AnimatedWhatsAppButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 180), lowerBound: 0.0, upperBound: 0.10);
    _scaleAnim = Tween<double>(begin: 1, end: 1.10).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.scale(
              scale: _scaleAnim.value,
              child: child,
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color.fromARGB(255, 255, 255, 255),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00B4D8).withOpacity(0.13),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: EdgeInsets.all(widget.size.width * 0.025),
              child: Image.asset(
                'assets/images/whatsapp.logo.png',
                width: widget.size.width * 0.16,
                height: widget.size.width * 0.12,
              ),
            ),
          ),
          // Badge Online
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: Color(0xFF00B97A),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00B97A).withOpacity(0.18),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                "Online",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.size.width * 0.025,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}