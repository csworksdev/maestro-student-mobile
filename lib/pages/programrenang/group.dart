import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Color(0xFF222831) : Color(0xEF003566);
    final cardBgColor = isDark ? Color(0xFF31363b) : Colors.white;
    final textColor = isDark ? Colors.white : Color(0xEF003566);
    final subTextColor = isDark ? Colors.white70 : Colors.black87;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: isDark ? Color(0xFF232526) : Color.fromARGB(255, 255, 255, 255),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.05, vertical: size.height * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gambar utama
              Container(
                width: double.infinity,
                height: size.height * 0.28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withOpacity(0.13),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage('assets/images/grup.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              // Judul
              Column(
                children: [
                  Text(
                    'Kelas Grup (3-5 Anak)',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(
                      fontSize: size.width * 0.058,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Belajar Bersama, Lebih Percaya Diri!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.rubik(
                      fontSize: size.width * 0.05,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                      color: textColor.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
              SizedBox(height: size.height * 0.025),
              // Card Informasi
              Card(
                color: cardBgColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: size.height * 0.03,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(
                        context,
                        icon: Icons.help_outline_rounded,
                        title: 'Apa?',
                        desc: 'Kelas renang dalam kelompok kecil untuk suasana belajar yang interaktif.',
                        color: Color(0xFF00B4D8),
                      ),
                      SizedBox(height: size.height * 0.018),
                      _infoRow(
                        context,
                        icon: Icons.child_care_rounded,
                        title: 'Siapa?',
                        desc: 'Anak-anak yang ingin belajar berenang sambil bersosialisasi.',
                        color: Color(0xFF90E0EF),
                      ),
                      SizedBox(height: size.height * 0.018),
                      _infoRow(
                        context,
                        icon: Icons.favorite_rounded,
                        title: 'Mengapa?',
                        desc: 'Lebih ekonomis, tetap mendapat perhatian dari pelatih, dan membangun keberanian di air dengan teman-teman.',
                        color: Color(0xFF003566),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.04),
              // CTA atau info tambahan
              Text(
                'Belajar renang jadi lebih seru dan semangat bersama Maestro Swim!',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontStyle: FontStyle.italic,
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.w600,
                  color: subTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, {required IconData icon, required String title, required String desc, required Color color}) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.18 : 0.13),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(size.width * 0.032),
          child: Icon(icon, color: color, size: size.width * 0.07),
        ),
        SizedBox(width: size.width * 0.04),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.rubik(
                  fontSize: size.width * 0.045,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4),
              Text(
                desc,
                style: GoogleFonts.nunito(
                  fontSize: size.width * 0.038,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
