import 'package:flutter/material.dart';
import 'package:maestro_client_mobile/pages/masterhydro.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maestro_client_mobile/theme/app_theme.dart';
import 'dart:ui';
import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:maestro_client_mobile/pages/programrenang/babyswim.dart';
import 'package:maestro_client_mobile/pages/programrenang/private1.dart';
import 'package:maestro_client_mobile/pages/programrenang/private2.dart';
import 'package:maestro_client_mobile/pages/programrenang/group.dart';
import 'package:maestro_client_mobile/pages/keunggulan_kolam_page.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/student_provider.dart';
import 'package:intl/intl.dart';

// Tambahkan stateful widget agar bisa mengatur loading state pada refresh

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  @override
  void initState() {
    super.initState();
    // Mengambil data siswa saat widget pertama kali dibuat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchStudents();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onRefresh() async {
    // Menambahkan try-catch untuk menangani error saat refresh
    try {
      await Provider.of<StudentProvider>(context, listen: false).fetchStudents();
    } catch (e) {
      // Menampilkan snackbar jika terjadi error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _wrapWhite({required Size size, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: EdgeInsets.all(size.width * 0.04),
      child: child,
    );
  }

  // Tambahkan fungsi untuk membuka WhatsApp
  void _launchWhatsApp() async {
    final phone = '628156125474'; // Nomor WhatsApp tujuan (format internasional, tanpa +)
    final message = Uri.encodeComponent("Halo, saya ingin bertanya tentang Maestro Swim.");
    final uri = Uri.parse('https://wa.me/$phone?text=$message');
    
    try {
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        print('Could not launch $uri');
      }
    } catch (e) {
      print('Error launching WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary; // navy
    final onPrimaryText = Theme.of(context).colorScheme.onPrimary; // white

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background dengan WaveClipper
          ClipPath(
            clipper: WaveClipper(),
            child: Container(
              height: size.height * 0.30,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF232526), const Color(0xFF414345)]
                      : [AppColors.orange, AppColors.orange.withOpacity(0.92)],
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
                              color: onPrimaryText,
                            ),
                          ),
                          Text(
                            "Welcome to Maestro Swim!",
                            style: GoogleFonts.nunito(
                              fontSize: size.width * 0.040,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.normal,
                              color: onPrimaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),

                    // Pengumuman Singkat / Highlight (dipindah di atas search bar)
                    _buildAnnouncementCard(context: context, size: size, isDark: isDark),

                    SizedBox(height: size.height * 0.015),

                    // Dashboard Content
                    Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        
                        // Ringkasan Profil Siswa/Orangtua
                        _buildProfileSummaryCard(size: size, isDark: isDark),
                        
                        SizedBox(height: size.height * 0.02),
                        
                        // Paket Aktif & Sisa Sesi
                        _buildActivePackageCard(size: size, isDark: isDark),
                        
                        SizedBox(height: size.height * 0.02),
                        
                        // Jadwal Terdekat (Next Class)
                        _buildNextClassCard(size: size, isDark: isDark),
                        
                        SizedBox(height: size.height * 0.02),

                            // Program Renang
                            Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 0.5,
                                      spreadRadius: 1,
                                  offset: Offset(0, 0),
                                    ),
                                  ],
                                  gradient: isDark
                                      ? LinearGradient(
                                          colors: [Color(0xFF232526), Color(0xFF414345)],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : LinearGradient(
                                          colors: [
                                            Color.fromRGBO(255, 255, 255, 1), Color.fromARGB(255, 255, 255, 255),
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
                                        color: isDark ? Colors.white : AppColors.navy,
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

                            // Card Lokasi Maestro Swim
                            _buildLocationCard(size: size, isDark: isDark),

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

                        // Contact Us
                        _wrapWhite(
                          size: size,
                          child: TweenAnimationBuilder<double>(
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
                                                color: AppColors.navy,
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
                                                            colors: [AppColors.navy, AppColors.navy],
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
                                                      Icon(Icons.chat_bubble_rounded, color: AppColors.navy, size: size.width * 0.055),
                                                    ],
                                                  ),
                                                  SizedBox(height: size.height * 0.004),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      color: Color.fromARGB(255, 150, 150, 150).withOpacity(0.09),
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.info_outline, color: AppColors.navy, size: size.width * 0.035),
                                                        SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            "Ada pertanyaan terkait Maestro Swim? Hubungi admin!",
                                                            style: GoogleFonts.nunito(
                                                              fontStyle: FontStyle.italic,
                                                              fontSize: size.width * 0.034,
                                                              color: isDark ? Colors.white70 : AppColors.navy,
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
                        ),
                        
                        // Partner Kami Section
                        _wrapWhite(
                          size: size,
                          child: _buildPartnerSection(size),
                        ),
                        
                        // Lisensi Section
                        _wrapWhite(
                          size: size,
                          child: _buildLicenseSection(size),
                        ),
                        
                        // Social Media Section
                        _wrapWhite(
                          size: size,
                          child: _buildSocialMediaSection(size: size, isDark: isDark),
                        ),
                        SizedBox(height: size.height * 0.02), 

                          ],
                        ),
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

// Widget untuk menampilkan Social Media (Compact)
Widget _buildSocialMediaSection({required Size size, required bool isDark}) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.public, color: AppColors.navy, size: size.width * 0.055),
              SizedBox(width: 8),
              Text(
                "Social Media",
                style: GoogleFonts.nunito(
                  fontSize: size.width * 0.042,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
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
  );
}

// Widget untuk menampilkan Partner Kami (Compact)
Widget _buildPartnerSection(Size size) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.handshake, color: AppColors.navy, size: size.width * 0.055),
              SizedBox(width: 8),
              Text(
                "Partner Kami",
                style: GoogleFonts.nunito(
                  fontSize: size.width * 0.042,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.012),
          Container(
            height: size.height * 0.08,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: [
                'assets/images/arkadia.jpg',
                'assets/images/n112.jpg',
                'assets/images/olympic.png',
                'assets/images/oasis.png',
                'assets/images/wonderclub.png',
                'assets/images/marcopolo.jpg',
                'assets/images/pillowpool.png',
              ].length,
              itemBuilder: (context, index) {
                final imagePath = [
                  'assets/images/arkadia.jpg',
                  'assets/images/n112.jpg',
                  'assets/images/olympic.png',
                  'assets/images/oasis.png',
                  'assets/images/wonderclub.png',
                  'assets/images/marcopolo.jpg',
                  'assets/images/pillowpool.png',
                ][index];
                return Container(
                  width: size.width * 0.18,
                  height: size.height * 0.08,
                  margin: EdgeInsets.only(right: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

// Widget untuk menampilkan Lisensi (Compact)
Widget _buildLicenseSection(Size size) {
  return Card(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified, color: AppColors.navy, size: size.width * 0.055),
              SizedBox(width: 8),
              Text(
                "Lisensi",
                style: GoogleFonts.nunito(
                  fontSize: size.width * 0.042,
                  fontWeight: FontWeight.bold,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.012),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              'assets/images/asca.png',
              'assets/images/akuatik.png',
              'assets/images/aasm.png',
            ].map((imagePath) => Container(
              width: size.width * 0.20,
              height: size.height * 0.08,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            )).toList(),
          ),
        ],
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
          elevation: 2,
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
                            Color.fromARGB(255, 255, 255, 255),
                            Color.fromARGB(255, 255, 255, 255),
                            
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
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
            opacity: 0.15,
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
  final List<Map<String, dynamic>> items = [
    {
      'text': 'Instruktur Profesional. Dilatih & bersertifikat, sabar menangani pemula.',
      'icon': Icons.verified_user, // profesional
    },
    {
      'text': 'Program Disesuaikan. Untuk balita, anak, dewasa, bahkan hydrotherapy.',
      'icon': Icons.auto_mode, // program disesuaikan
    },
    {
      'text': 'Lokasi Strategis. Kolam tersedia di berbagai kota besar di Pulau Jawa',
      'icon': Icons.location_on_rounded, // lokasi
    },
    {
      'text': 'Fasilitias Lengkap. Air hangat, ruang tunggu nyaman, dan area ganti bersih.',
      'icon': Icons.bathtub_rounded, // fasilitas lengkap
    },
  ];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: items.map((item) => Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.008),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(item['icon'], color: Color(0xEF003566), size: size.width * 0.045),
          SizedBox(width: 7),
          Expanded(
            child: Text(
              item['text'],
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
      onTapUp: (_) async {
        _controller.reverse();
        try {
          final uri = Uri.parse(widget.url);
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            print('Could not launch $uri');
          }
        } catch (e) {
          print('Error launching URL: $e');
        }
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

// Widget untuk card lokasi dengan slider
Widget _buildLocationCard({required Size size, required bool isDark}) {
  final List<Map<String, dynamic>> locations = [
    {'name': 'Bandung', 'icon': Icons.location_on},
    {'name': 'Jakarta', 'icon': Icons.location_on},
    {'name': 'Cikarang', 'icon': Icons.location_on},
    {'name': 'Bogor', 'icon': Icons.location_on},
    {'name': 'Tangerang', 'icon': Icons.location_on},
    {'name': 'Depok', 'icon': Icons.location_on},
    {'name': 'Bekasi', 'icon': Icons.location_on},
    {'name': 'Surabaya', 'icon': Icons.location_on},
    {'name': 'Semarang', 'icon': Icons.location_on},
    {'name': 'Solo', 'icon': Icons.location_on},
  ];

  return Column(
    children: [
      Padding(
        padding: EdgeInsets.only(top: size.height * 0.01, bottom: size.height * 0.01),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          color: isDark ? Colors.white.withOpacity(0.07) : Colors.white,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.04,
                vertical: size.height * 0.02,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                color: isDark ? Color(0xFF232526).withOpacity(0.95) : Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.place_outlined,
                        color: AppColors.navy,
                        size: size.width * 0.06,
                      ),
                      SizedBox(width: size.width * 0.02),
                      Text(
                        'Lokasi Kolam Renang',
                        style: GoogleFonts.rubik(
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.015),
                  Container(
                    height: size.width * 0.25, // aspect ratio 1:1
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: locations.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: size.width * 0.25,
                          height: size.width * 0.25,
                          margin: EdgeInsets.only(right: size.width * 0.03),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [AppColors.navy, AppColors.navy],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                locations[index]['icon'],
                                color: Colors.white,
                                size: size.width * 0.08,
                              ),
                              Text(
                                locations[index]['name'],
                                style: GoogleFonts.nunito(
                                  fontSize: size.width * 0.035,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // Button Keunggulan Kolam Renang di luar card
      Builder(
        builder: (context) => Padding(
          padding: EdgeInsets.only(bottom: size.height * 0.02, top: size.height * 0.01),
          child: Center(
            child: Container(
              width: size.width * 0.8,
              height: size.height * 0.06,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.navy, AppColors.navy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => KeunggulanKolamPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pool, color: Colors.white, size: size.width * 0.055),
                    SizedBox(width: size.width * 0.025),
                    Text(
                      'Keunggulan Kolam Renang',
                      style: GoogleFonts.rubik(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      
      // Card Testimoni Orang Tua
      SizedBox(height: size.height * 0.02),
      _buildTestimoniCard(size: size, isDark: isDark),
    ],
  );
}

// Widget untuk card testimoni
Widget _buildTestimoniCard({required Size size, required bool isDark}) {
  // Data testimoni
  final List<Map<String, String>> testimonials = [
    {
      'name': 'Diah Prastuti',
      'child': 'Bandung',
      'text': 'Pelatih di maestro baik2, profesional dan selalu mendorong anak untuk bersemangat latihan. Anak saya dari pertama kali takut air, sekarang ga pernah mau skip latihan. Tempat latihannya jg bersih, nyaman. Terimakasih coach Santi dan Maestro Swim'
    },
    {
      'name': 'Nay Atmaja as Yunniar Atmaja',
      'child': 'Bandung',
      'text': 'Udah pernah nyoba tempat les lain, tapi cuman disini yang anaknya betah + progress nyaa keliatan bgttt Umur 5 tahunUdah bisa 2 gayaa renang terharuuuuuu.. Niatnya buat stimulasi focus anak tpi jadi hobby Pokonya anaknya maunya sama coach acel gamau sama yg lain'
    },
    {
      'name': 'Sabeenoura Atmakamila',
      'child': 'Bandung',
      'text': 'Tempat les berenang yang nyaman dan menyenangkan...coach nya baik dan juga kooperatif sekali dengan kami para orang tua...anak-anak sudah hampir 2 tahun les disini, dan perkembangan kemampuan berenangnya baik dan progresif sekali...terima kasih Maestro swim'
    },
    {
      'name': 'Nurul Iman',
      'child': 'Bandung',
      'text': 'Latihan di maestro recomend banget ya guys coba dulu deh pasti bakal terus memperpanjang qlo yg mau cari tempat latihan renang untuk anak udah paling bener di sini menurut aq ya progres nya cepet tergantung anak nya pelatih nya sabar pisan coach lia nama nya lulusan univ ternama di bandung pula jd sdh pasti anak2 akan cepet faham dengan metode pembelajaran nya sukses terus ya maestro'
    },
  ];

  return Stack(
    children: [
      Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 0.5,
                spreadRadius: 1,
                offset: Offset(0, 0),
              ),
            ],
            gradient: isDark
                ? LinearGradient(
                    colors: [Color(0xFF232526), Color(0xFF414345)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: [
                      Color.fromRGBO(255, 255, 255, 1), 
                      Color.fromARGB(255, 255, 255, 255),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          padding: EdgeInsets.all(size.width * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [Color.fromARGB(255, 255, 255, 255), Color.fromARGB(255, 255, 255, 255)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.record_voice_over,
                        color: AppColors.navy,
                        size: size.width * 0.06,
                      ),
                      SizedBox(width: size.width * 0.018),
                      Text(
                        "Apa kata peserta?",
                        textAlign: TextAlign.start,
                        style: GoogleFonts.rubik(
                          fontSize: size.width * 0.05,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              CarouselSlider.builder(
                itemCount: testimonials.length,
                itemBuilder: (context, index, realIdx) {
                  final testimonial = testimonials[index];
                  // Menghitung perkiraan tinggi teks berdasarkan panjang teks
                  final textLength = testimonial['text']!.length;
                  // Menyesuaikan padding berdasarkan panjang teks
                  final dynamicPadding = textLength > 200 ? 16.0 : 12.0;
                  
                  return Container(
                    width: size.width * 0.85,
                    padding: EdgeInsets.all(dynamicPadding),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: [AppColors.navy, AppColors.navy],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                '"${testimonial['text']}"',
                                style: GoogleFonts.nunito(
                                  fontSize: size.width * 0.035,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                        Divider(color: Colors.white.withOpacity(0.5), thickness: 0.5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  testimonial['name']!,
                                  style: GoogleFonts.rubik(
                                    fontSize: size.width * 0.035,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  testimonial['child']!,
                                  style: GoogleFonts.nunito(
                                    fontSize: size.width * 0.03,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                options: CarouselOptions(
                  height: size.height * 0.20, // Tinggi lebih kecil agar teks bisa di-scroll
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3), // Waktu lebih lama untuk membaca teks panjang
                  enlargeCenterPage: true,
                  viewportFraction: 0.85,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  pauseAutoPlayOnTouch: true,
                  scrollPhysics: BouncingScrollPhysics(),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// Fungsi untuk menampilkan gambar dalam ukuran asli
void _showFullSizeImage(BuildContext context, String imagePath) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Image.asset(
                imagePath,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Widget Pengumuman Singkat / Highlight
Widget _buildAnnouncementCard({required BuildContext context, required Size size, required bool isDark}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.campaign,
                  color: Colors.white,
                  size: size.width * 0.06,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pengumuman",
                      style: GoogleFonts.nunito(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.015),
          GestureDetector(
            onTap: () {
              _showFullSizeImage(context, 'assets/images/promo_oktober.jpg');
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: size.width * 0.02, horizontal: size.width * 0.03),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: size.width * 0.045,
                  ),
                  SizedBox(width: size.width * 0.02),
                  Expanded(
                    child: Text(
                      "Ada promo terbaru di bulan Oktober 2025!",
                      style: GoogleFonts.nunito(
                        fontSize: size.width * 0.037,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.touch_app,
                    color: Colors.white70,
                    size: size.width * 0.045,
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

// Widget Ringkasan Profil Siswa/Orangtua
Widget _buildProfileSummaryCard({required Size size, required bool isDark}) {
  return Consumer<StudentProvider>(
    builder: (context, studentProvider, child) {
      if (studentProvider.isLoading) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(size.width * 0.04),
            height: size.height * 0.15,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Memuat data siswa...",
                    style: GoogleFonts.nunito(
                      fontSize: size.width * 0.035,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      if (studentProvider.error.isNotEmpty) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(size.width * 0.04),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 30,
                ),
                SizedBox(height: 8),
                Text(
                  "Gagal memuat data siswa",
                  style: GoogleFonts.nunito(
                    fontSize: size.width * 0.04,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<StudentProvider>(context, listen: false).fetchStudents();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Coba Lagi"),
                ),
              ],
            ),
          ),
        );
      }

      // Cek apakah ada data siswa
      if (studentProvider.students.isEmpty) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.white,
            ),
            padding: EdgeInsets.all(size.width * 0.04),
            child: Center(
              child: Text(
                "Tidak ada data siswa",
                style: GoogleFonts.nunito(
                  fontSize: size.width * 0.04,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        );
      }

      // Tampilkan semua siswa dalam bentuk card
      return Column(
        children: studentProvider.students.map((student) {
          // Format tanggal bergabung
          String joinDate = "-";
          try {
            if (student.createdAt.isNotEmpty) {
              final dateTime = DateTime.parse(student.createdAt);
              joinDate = DateFormat('MMM yyyy', 'id_ID').format(dateTime);
            }
          } catch (e) {
            joinDate = "-";
          }

          // Ambil inisial nama untuk avatar
          String initial = student.nickname.isNotEmpty 
              ? student.nickname[0].toUpperCase() 
              : (student.fullname.isNotEmpty ? student.fullname[0].toUpperCase() : "-");

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            margin: EdgeInsets.only(bottom: 16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.all(size.width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: size.width * 0.12,
                        height: size.width * 0.12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [AppColors.navy, AppColors.navy],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.navy.withOpacity(0.2),
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: GoogleFonts.nunito(
                              fontSize: size.width * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.nickname.isNotEmpty ? student.nickname : student.fullname,
                              style: GoogleFonts.nunito(
                                fontSize: size.width * 0.045,
                                fontWeight: FontWeight.bold,
                                color: AppColors.navy,
                              ),
                            ),
                            Text(
                              "Siswa Maestro Swim",
                              style: GoogleFonts.nunito(
                                fontSize: size.width * 0.035,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Color(0xFF00B97A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Color(0xFF00B97A),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          student.isFollowup ? "Aktif" : "Tidak Aktif",
                          style: GoogleFonts.nunito(
                            fontSize: size.width * 0.03,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00B97A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.015),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProfileInfoItem(
                          icon: Icons.calendar_today,
                          label: "Bergabung",
                          value: "-",
                          size: size,
                        ),
                      ),
                      Expanded(
                        child: _buildProfileInfoItem(
                          icon: Icons.pool,
                          label: "Lokasi Kolam",
                          value: student.branchName ?? "-",
                          size: size,
                        ),
                      ),
                      Expanded(
                        child: _buildProfileInfoItem(
                          icon: Icons.star_border_purple500,
                          label: "Level",
                          value: student.level ?? "-",
                          size: size,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    },
  );
}

Widget _buildProfileInfoItem({
  required IconData icon,
  required String label,
  required String value,
  required Size size,
}) {
  return Column(
    children: [
      Icon(
        icon,
        color: AppColors.navy,
        size: size.width * 0.05,
      ),
      SizedBox(height: size.height * 0.005),
      Text(
        label,
        style: GoogleFonts.nunito(
          fontSize: size.width * 0.03,
          color: Colors.grey[600],
        ),
      ),
      Text(
        value,
        style: GoogleFonts.nunito(
          fontSize: size.width * 0.035,
          fontWeight: FontWeight.bold,
          color: AppColors.navy,
        ),
      ),
    ],
  );
}

// Widget Paket Aktif & Sisa Sesi
Widget _buildActivePackageCard({required Size size, required bool isDark}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.navy.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.card_membership,
                  color: AppColors.navy,
                  size: size.width * 0.06,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Paket Aktif",
                      style: GoogleFonts.nunito(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    Text(
                      "Private 1 - 12 Pertemuan",
                      style: GoogleFonts.nunito(
                        fontSize: size.width * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Sisa Pertemuan",
                      style: GoogleFonts.nunito(
                        fontSize: size.width * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      "8 Pertemuan",
                      style: GoogleFonts.nunito(
                        fontSize: size.width * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00B97A),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Progress",
                      style: GoogleFonts.nunito(
                        fontSize: size.width * 0.035,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    LinearProgressIndicator(
                      value: 0.33, // 4/12 = 0.33
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.navy),
                      minHeight: 8,
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      "33% Selesai",
                      style: GoogleFonts.nunito(
                        fontSize: size.width * 0.03,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.015),
          Container(
            padding: EdgeInsets.all(size.width * 0.03),
            decoration: BoxDecoration(
              color: AppColors.navy.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.navy.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.schedule,
                  color: AppColors.navy,
                  size: size.width * 0.04,
                ),
                SizedBox(width: size.width * 0.02),
                Text(
                  "Berlaku hingga: 15 Maret 2024",
                  style: GoogleFonts.nunito(
                    fontSize: size.width * 0.035,
                    color: AppColors.navy,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

// Widget Jadwal Terdekat (Next Class)
Widget _buildNextClassCard({required Size size, required bool isDark}) {
  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(size.width * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.schedule,
                  color: Colors.white,
                  size: size.width * 0.06,
                ),
              ),
              SizedBox(width: size.width * 0.03),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Kelas Berikutnya",
                      style: GoogleFonts.nunito(
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Private 1 dengan Coach Santi",
                      style: GoogleFonts.nunito(
                        fontSize: size.width * 0.035,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.02),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tanggal",
                      style: GoogleFonts.nunito(
                        fontSize: size.width * 0.035,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      "Senin, 5 Feb 2024",
                      style: GoogleFonts.nunito(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Waktu",
                      style: GoogleFonts.nunito(
                        fontSize: size.width * 0.035,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: size.height * 0.005),
                    Text(
                      "16:00 - 17:00",
                      style: GoogleFonts.nunito(
                        fontSize: size.width * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: size.height * 0.015),
          Container(
            padding: EdgeInsets.all(size.width * 0.03),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  color: Colors.white,
                  size: size.width * 0.04,
                ),
                SizedBox(width: size.width * 0.02),
                Text(
                  "Sisa waktu: 2 hari 14 jam",
                  style: GoogleFonts.nunito(
                    fontSize: size.width * 0.035,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}