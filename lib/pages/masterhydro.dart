import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_fonts/google_fonts.dart';

class MasterHydroPage extends StatelessWidget {
  MasterHydroPage({Key? key}) : super(key: key);

  final List<String> imageList = [
    'assets/images/hydro1.png',
    'assets/images/hydro2.png',
    'assets/images/hydro3.png',
    'assets/images/hydro4.png',
    'assets/images/hydro5.png',
    'assets/images/hydro6.png',
    'assets/images/hydro7.png',
  ];

  void _launchWhatsApp() async {
    final url = Uri.parse('https://wa.me/+628156125494');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final double carouselHeight = isMobile ? screenHeight * 0.28 : screenHeight * 0.38;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Hydrotherapy',
          style: GoogleFonts.nunito(
            fontSize: isMobile ? 22 : 26,
            color: Color(0xFF003566),
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Carousel Slider
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: carouselHeight,
                    viewportFraction: 0.92,
                    enlargeCenterPage: true,
                    enableInfiniteScroll: true,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 2),
                  ),
                  items: imageList.map((imgPath) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueGrey.withOpacity(0.18),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              imgPath,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: carouselHeight,
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 28),
              // Judul
              Text(
                'Program Hydrotherapy',
                style: GoogleFonts.nunito(
                  fontSize: isMobile ? 28 : 36,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF003566),
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Tagline
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 18 : 80),
                child: Text(
                  'Nyeri Sendi? Stres? Butuh Terapi yang Efektif? Hidroterapi adalah Solusinya!',
                  style: GoogleFonts.nunito(
                    fontStyle: FontStyle.italic,
                    fontSize: isMobile ? 16 : 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.blueGrey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 28),
              // Card Informasi
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoSection(
                      title: 'Apa itu hidroterapi?',
                      content:
                          'Hidroterapi adalah metode terapi berbasis air yang terbukti efektif mengurangi nyeri sendi, mempercepat pemulihan cedera, dan meningkatkan fleksibilitas tubuh. Dengan tekanan air yang lembut, tubuh terasa lebih ringan, sehingga latihan jadi lebih nyaman dan tanpa risiko cedera.',
                      minHeight: carouselHeight * 0.7,
                    ),
                    const SizedBox(height: 18),
                    _infoSection(
                      title: 'Siapa yang cocok mengikuti hidroterapi?',
                      content:
                          'Apakah Anda sering mengalami nyeri lutut, punggung, atau otot kaku? Hidroterapi sangat cocok untuk lansia, ibu hamil, atlet dalam masa pemulihan, serta siapa pun yang ingin meningkatkan mobilitas tubuh tanpa beban berat.',
                      minHeight: carouselHeight * 0.7,
                    ),
                    const SizedBox(height: 18),
                    _infoSection(
                      title: 'Kapan waktu terbaik untuk memulai?',
                      content:
                          'Jawabannya: Sekarang! Jangan tunggu hingga rasa sakit semakin parah. Mulailah terapi lebih awal untuk mendapatkan manfaat maksimal.',
                      minHeight: carouselHeight * 0.5,
                    ),
                    const SizedBox(height: 18),
                    _infoSection(
                      title: 'Di mana Anda bisa menjalani hidroterapi ini?',
                      content:
                          'Kami hadir di beberapa lokasi strategis di Bandung dan Jakarta. Kolam renang kami nyaman, bersih, dan dirancang khusus untuk terapi.',
                      minHeight: carouselHeight * 0.5,
                    ),
                    const SizedBox(height: 18),
                    _infoSection(
                      title: 'Mengapa harus memilih Maestro Swim?',
                      content:
                          '• Instruktur bersertifikat yang berpengalaman dalam hidroterapi\n• Sesi eksklusif dengan metode yang disesuaikan untuk setiap peserta\n• Lingkungan nyaman dengan air hangat yang mendukung relaksasi maksimal',
                      minHeight: carouselHeight * 0.7,
                    ),
                    const SizedBox(height: 18),
                    _infoSection(
                      title: 'Bagaimana cara mendaftar?',
                      content:
                          'Jangan tunda lagi! Dapatkan sesi uji coba sekarang!',
                      minHeight: carouselHeight * 0.4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Button WhatsApp
              Padding(
                padding: EdgeInsets.symmetric(horizontal: isMobile ? 32 : 0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _launchWhatsApp,
                    icon: Image.asset(
                      'assets/images/whatsapp.logo.png',
                      width: 28,
                      height: 28,
                    ),
                    label: const Text(
                      'Hubungi via WhatsApp',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _infoSection({required String title, required String content, required double minHeight}) {
    // Custom icon and color for each section
    IconData icon;
    Color iconColor;
    Color bgColor;
    switch (title) {
      case 'Apa itu hidroterapi?':
        icon = Icons.water_drop_rounded;
        iconColor = Color(0xFF00B4D8);
        bgColor = Color(0xFFE0F7FA);
        break;
      case 'Siapa yang cocok mengikuti hidroterapi?':
        icon = Icons.groups_rounded;
        iconColor = Color(0xFF0077B6);
        bgColor = Color(0xFFE3F2FD);
        break;
      case 'Kapan waktu terbaik untuk memulai?':
        icon = Icons.access_time_rounded;
        iconColor = Color(0xFF00B97A);
        bgColor = Color(0xFFF1F8E9);
        break;
      case 'Di mana Anda bisa menjalani hidroterapi ini?':
        icon = Icons.location_on_rounded;
        iconColor = Color(0xFF003566);
        bgColor = Color(0xFFFFF3E0);
        break;
      case 'Mengapa harus memilih Maestro Swim?':
        icon = Icons.verified_rounded;
        iconColor = Color(0xFF00B4D8);
        bgColor = Color(0xFFE8F5E9);
        break;
      case 'Bagaimana cara mendaftar?':
        icon = Icons.how_to_reg_rounded;
        iconColor = Color(0xFFFB8500);
        bgColor = Color(0xFFFFF8E1);
        break;
      default:
        icon = Icons.info_outline_rounded;
        iconColor = Color(0xFF003566);
        bgColor = Colors.white;
    }
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      color: bgColor,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Icon(icon, color: iconColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildRichContent(title, content),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildRichContent(String title, String content) {
    // Custom highlight for each section
    if (title == 'Mengapa harus memilih Maestro Swim?') {
      // Bullet list with highlight
      final points = content.split('\n');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: points.map((point) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF00B4D8), size: 20),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                point.replaceAll('• ', ''),
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: Color(0xFF003566),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        )).toList(),
      );
    } else if (title == 'Bagaimana cara mendaftar?') {
      return RichText(
        text: TextSpan(
          style: GoogleFonts.nunito(fontSize: 16, color: Colors.black87, height: 1.5),
          children: [
            TextSpan(text: 'Jangan tunda lagi! '),
            TextSpan(
              text: 'Dapatkan sesi uji coba sekarang!',
              style: GoogleFonts.nunito(
                color: Color(0xFFFB8500),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (title == 'Kapan waktu terbaik untuk memulai?') {
      return RichText(
        text: TextSpan(
          style: GoogleFonts.nunito(fontSize: 16, color: Colors.black87, height: 1.5),
          children: [
            TextSpan(text: 'Jawabannya: '),
            TextSpan(
              text: 'Sekarang!',
              style: GoogleFonts.nunito(
                color: Color(0xFF00B97A),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(text: ' Jangan tunggu hingga rasa sakit semakin parah. Mulailah terapi lebih awal untuk mendapatkan manfaat maksimal.'),
          ],
        ),
      );
    } else {
      return Text(
        content,
        style: GoogleFonts.nunito(
          fontSize: 16,
          color: Colors.black87,
          height: 1.5,
        ),
      );
    }
  }
}
