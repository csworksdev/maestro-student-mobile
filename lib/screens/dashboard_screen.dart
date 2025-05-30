import 'package:flutter/material.dart';
import 'package:maestro_client_mobile/pages/datasiswa/datasiswa_page.dart';
import 'package:maestro_client_mobile/pages/jadwalsiswa/jadwal_siswa.dart';
import 'package:maestro_client_mobile/pages/katalogproduk.dart';
import 'package:maestro_client_mobile/pages/masterhydro.dart';
import 'package:maestro_client_mobile/pages/ordersiswa/orderhistory_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:maestro_client_mobile/pages/programrenang/babyswim.dart';
import 'package:maestro_client_mobile/pages/programrenang/private1.dart';
import 'package:maestro_client_mobile/pages/programrenang/private2.dart';
import 'package:maestro_client_mobile/pages/programrenang/group.dart';

// Tambahkan stateful widget agar bisa mengatur loading state pada refresh

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF222831) : Color(0xEF003566);
    final secondaryColor = isDark ? Colors.white : Color(0xFFFFFFFF);
    final cardBgColor = isDark ? Color(0xFF31363b) : Colors.white;
    final searchBarColor = isDark ? Color(0xFF23272F) : Color(0xFFFFFFFF);
    final searchHintColor = isDark ? Colors.blueGrey[200] : Colors.blueGrey[300];

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
                  colors: isDark
                      ? [Color(0xFF232526), Color(0xFF414345)]
                      : [primaryColor, const Color.fromARGB(255, 0, 213, 255)],
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
                        color: searchBarColor,
                        borderRadius: BorderRadius.circular(38),
                        boxShadow: [
                          if (!isDark)
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
                                      color: searchHintColor,
                                      fontSize: size.width * 0.042,
                                      fontStyle: FontStyle.italic,
                                      fontFamily: GoogleFonts.poppins().fontFamily,
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
                      
                      color: cardBgColor,
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
                                          MaterialPageRoute(
                                            builder: (_) => const DataSiswaPage(),
                                          ),
                                        );
                                      }
                                    ),
                                    SizedBox(width: size.width * 0.002),
                                    buildCategoryCard(
                                      icon: Icons.history,
                                      title: "Order History",
                                      color: const Color(0xEF003566),
                                      gradient: LinearGradient(colors: [Color(0xFF00509E), Color(0xFF00B4D8)]),
                                      iconGradient: LinearGradient(colors: [Color(0xFF00B4D8), Color(0xFF00509E)]),
                                      accent: Icon(Icons.circle, color: Colors.white.withOpacity(0.10), size: size.width * 0.09),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => (OrderHistoryPage())), // Navigate to DataSiswaPage
                                        );
                                      },
                                    ),
                                    SizedBox(width: size.width * 0.002),
                                    buildCategoryCard(
                                      icon: Icons.schedule,
                                      title: "Jadwal",
                                      color: const Color(0xEF003566),
                                      gradient: LinearGradient(colors: [Color(0xFF00B4D8), Color(0xFF90E0EF)]),
                                      iconGradient: LinearGradient(colors: [Color(0xFF90E0EF), Color(0xFF00B4D8)]),
                                      accent: Icon(Icons.favorite, color: Colors.white.withOpacity(0.10), size: size.width * 0.09),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => (JadwalSiswaPage())), // Navigate to DataSiswaPage
                                        );
                                      },
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
                                  gradient: isDark
                                      ? LinearGradient(
                                          colors: [Color(0xFF232526), Color(0xFF414345)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
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
                                        color: isDark ? Colors.white : const Color.fromARGB(238, 255, 255, 255)
                                      ),
                                    ),
                                    SizedBox(height: size.height * 0.015),
                                    _buildProgramCarousel(),
                                  ],
                                ),
                              ),
                            ),

                            // Card Promosi Maestro Swim
                            _buildPromoCard(size: size, isDark: isDark),

                            // Card Gambar Master Hydro
                            _buildMasterhydroImageCard(
                              size: size,
                              isDark: isDark,
                              imagePath: 'assets/images/masterhydro.png',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => MasterHydroPage()),
                                );
                              },
                              width: 300,
                              height: 100,
                            ),

                            // Katalog Produk Maestro Swim Button (pindah ke bawah master hydro)
                            SizedBox(height: size.height * 0.014),
                            _KatalogProdukButton(size: size, isDark: isDark, onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => KatalogProdukPage ()),
                              );
                            }),
                            SizedBox(height: size.height * 0.04),

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
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.18),
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
                                                                "Ada pertanyaan terkait Maestro Swim? Hubungi admin!",
                                                                style: GoogleFonts.nunito(
                                                                  fontStyle: FontStyle.italic,
                                                                  fontSize: size.width * 0.034,
                                                                  color: isDark ? Colors.white70 : Color(0xFF003566),
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

                            // Social Media Section
                            TweenAnimationBuilder<double>(
                              key: ValueKey('social_media_card_animation'),
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
                                color: isDark ? Colors.white.withOpacity(0.05) : Colors.white.withOpacity(0.18),
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
                                                  "Social Media",
                                                  style: GoogleFonts.nunito(
                                                    fontSize: size.width * 0.042,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(Icons.public, color: Color(0xFF00B4D8), size: size.width * 0.055),
                                            ],
                                          ),
                                          SizedBox(height: size.height * 0.012),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              _SocialMediaButton(
                                                size: size,
                                                handle: '',
                                                url: 'https://wa.me/628156125474',
                                                iconAsset: 'assets/images/whatsapp.logo.png',
                                                compact: true,
                                              ),
                                              _SocialMediaButton(
                                                size: size,
  
                                                handle: '',
                                                url: 'https://www.instagram.com/maestro_swim/',
                                                iconAsset: 'assets/images/instagram.logo.png',
                                                compact: true,
                                              ),
                                              _SocialMediaButton(
                                                size: size,
                                                handle: '',
                                                url: 'https://www.youtube.com/channel/UCYyhlR2xLc-3QIqE2RsyDbg',
                                                iconAsset: 'assets/images/youtube.logo.png',
                                                compact: true,
                                              ),
                                              _SocialMediaButton(
                                                size: size,
                                                handle: '',
                                                url: 'https://www.tiktok.com/@maestro_swim/',
                                                iconAsset: 'assets/images/tiktok.logo.png',
                                                compact: true,
                                              ),
                                              _SocialMediaButton(
                                                size: size,
                                                handle: '',
                                                url: 'https://www.facebook.com/maestroswim/',
                                                iconAsset: 'assets/images/facebook.logo.png',
                                                compact: true,
                                              ),
                                            ],
                                          ),
                                        ],
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
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
            border: Border.all(color: const Color.fromARGB(150, 255, 255, 255), width: 1),
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
    {'image': 'assets/images/babyswim.jpg', 'label': 'Baby Swim & Spa'},
    {'image': 'assets/images/private1.jpg', 'label': 'Private 1'},
    {'image': 'assets/images/private2.jpg', 'label': 'Private 2'},
    {'image': 'assets/images/grup.png', 'label': 'Group'},
  ];

  return CarouselSlider.builder(
    itemCount: programs.length,
    itemBuilder: (context, index, realIdx) {
      final program = programs[index];
      final isBabySwim = program['label'] == 'Baby Swim & Spa';
      final isPrivate1 = program['label'] == 'Private 1';
      final isPrivate2 = program['label'] == 'Private 2';
      final isGroup = program['label'] == 'Group';
      final card = _buildSwimProgramCard(
        imagePath: program['image']!,
        label: program['label']!,
      );
      if (isBabySwim) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BabySwimPage()),
            );
          },
          child: card,
        );
      } else if (isPrivate1) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Private1Page()),
            );
          },
          child: card,
        );
      } else if (isPrivate2) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Private2Page()),
            );
          },
          child: card,
        );
      } else if (isGroup) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GroupPage()),
            );
          },
          child: card,
        );
      } else {
        return card;
      }
    },
    options: CarouselOptions(
      height: 120,
      autoPlay: true,
      autoPlayInterval: Duration(seconds: 3),
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
                  fontFamily: GoogleFonts.poppins().fontFamily,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildPromoCard({required Size size, required bool isDark}) {
  return Padding(
    padding: EdgeInsets.only(top: size.height * 0.018, bottom: size.height * 0.01),
    child: Stack(
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.white.withOpacity(0.22),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.045,
                  vertical: size.height * 0.025,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: isDark
                      ? LinearGradient(
                          colors: [Color(0xFF232526).withOpacity(0.95), Color(0xFF414345).withOpacity(0.85)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : LinearGradient(
                          colors: [
                            Color.fromARGB(255, 174, 243, 255), // Biru langit
                            Color(0xFFCAF0F8), // Biru muda
                            Color(0xFFE0F7FA), // Putih kebiruan
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.verified, color: Color(0xFF00B4D8), size: size.width * 0.07),
                        SizedBox(width: 8),
                        Text(
                          'Kenapa Pilih Maestro Swim?',
                          style: GoogleFonts.rubik(
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Color(0xEF003566),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.012),
                    _buildPromoList(size, isDark),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFF00B4D8),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Watermark Icon di pojok kanan bawah
        Positioned(
          right: size.width * 0.04,
          bottom: size.height * 0.012,
          child: Opacity(
            opacity: 0.14,
            child: Image.asset(
              'assets/images/badge1.png',
              width: size.width * 0.32,
              height: size.width * 0.32,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildPromoList(Size size, bool isDark) {
  final List<String> items = [
    'Pelatih bersertifikat & berpengalaman dalam mengajar anak-anak dan dewasa',
    'Kolam renang aman & nyaman di Bandung dan Jakarta',
    'Metode belajar menyenangkan & tidak membuat anak takut air',
    'Program terstruktur sesuai usia & kemampuan',
  ];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: items.map((item) => Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.008),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, color: Color(0xFF00B4D8), size: size.width * 0.045),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              item,
              style: GoogleFonts.nunito(
                fontSize: size.width * 0.037,
                color: isDark ? Colors.white.withOpacity(0.92) : Color(0xEF003566),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    )).toList(),
  );
}

// Social Media Button
class _SocialMediaButton extends StatefulWidget {
  final Size size;
  final String handle;
  final String url;
  final String iconAsset;
  final bool compact;

  const _SocialMediaButton({
    required this.size,
    required this.handle,
    required this.url,
    required this.iconAsset,
    this.compact = false,
  });

  @override
  State<_SocialMediaButton> createState() => _SocialMediaButtonState();
}

class _SocialMediaButtonState extends State<_SocialMediaButton> with SingleTickerProviderStateMixin {
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
    final double iconSize = widget.compact ? widget.size.width * 0.09 : widget.size.width * 0.16;
    final double padding = widget.compact ? widget.size.width * 0.012 : widget.size.width * 0.025;
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        launchUrl(Uri.parse(widget.url), mode: LaunchMode.externalApplication);
      },
      onTapCancel: () => _controller.reverse(),
      child: Column(
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
              ),
              padding: EdgeInsets.all(padding),
              child: Image.asset(
                widget.iconAsset,
                width: iconSize,
                height: iconSize,
              ),
            ),
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }
}

// Tambahkan widget builder untuk card gambar klikable di bawah kode file
Widget _buildMasterhydroImageCard({
  required Size size,
  required bool isDark,
  required String imagePath,
  required VoidCallback onTap,
  double? width,
  double? height,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: size.height * 0.022, horizontal: size.width * 0.070),
    child: GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        color: Colors.white,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: SizedBox(
            width: width,
            height: height,
            child: Image.asset(
              imagePath,
              fit: BoxFit.contain,
              alignment: Alignment.center,
            ),
          ),
        ),
      ),
    ),
  );
}

class _KatalogProdukButton extends StatefulWidget {
  final Size size;
  final bool isDark;
  final VoidCallback onTap;
  const _KatalogProdukButton({required this.size, required this.isDark, required this.onTap});
  @override
  State<_KatalogProdukButton> createState() => _KatalogProdukButtonState();
}

class _KatalogProdukButtonState extends State<_KatalogProdukButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 140), lowerBound: 0.0, upperBound: 0.10);
    _scaleAnim = Tween<double>(begin: 1, end: 1.07).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.isDark
        ? LinearGradient(colors: [Color(0xFF232526), Color(0xFF00B4D8)], begin: Alignment.topLeft, end: Alignment.bottomRight)
        : LinearGradient(colors: [Color(0xFF00B4D8), Color(0xFF003566)], begin: Alignment.topLeft, end: Alignment.bottomRight);
    double buttonWidth = widget.size.width * 0.80;
    buttonWidth = buttonWidth.clamp(220.0, 420.0);
    final buttonHeight = widget.size.height * 0.07 < 48 ? 48.0 : widget.size.height * 0.07;
    return Center(
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
          child: Container(
            width: buttonWidth,
            height: buttonHeight,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              children: [
                // Glassmorphism effect
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(buttonHeight * 0.18),
                      child: Icon(Icons.shopping_bag_rounded, color: const Color.fromARGB(255, 0, 67, 138), size: buttonHeight * 0.55),
                    ),
                    Flexible(
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return LinearGradient(
                            colors: [const Color.fromARGB(255, 255, 255, 255), Colors.white.withOpacity(0.85)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds);
                        },
                        child: Text(
                          "Katalog Produk Maestro Swim",
                          style: GoogleFonts.rubik(
                            fontSize: buttonHeight * 0.28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}