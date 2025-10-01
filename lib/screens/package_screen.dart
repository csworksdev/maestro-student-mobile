import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class PackageScreen extends StatefulWidget {
  const PackageScreen({super.key});

  @override
  State<PackageScreen> createState() => _PackageScreenState();
}

class _PackageScreenState extends State<PackageScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Color(0xFF232526), Color(0xFF414345)]
                      : [Color(0xFF003566), Color(0xFF00509E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Paket Latihan',
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pilih paket latihan renang yang sesuai dengan kebutuhan Anda',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Package Cards
            _buildPackageCard(
              title: 'Paket Basic',
              price: 'Rp 500.000',
              duration: '4 Pertemuan',
              features: [
                '1x per minggu',
                'Durasi 60 menit',
                'Instruktur berpengalaman',
                'Kolam renang berkualitas',
              ],
              isPopular: false,
              isDarkMode: isDarkMode,
            ),
            
            SizedBox(height: 16),
            
            _buildPackageCard(
              title: 'Paket Premium',
              price: 'Rp 800.000',
              duration: '8 Pertemuan',
              features: [
                '2x per minggu',
                'Durasi 60 menit',
                'Instruktur berpengalaman',
                'Kolam renang berkualitas',
                'Progress tracking',
                'Sertifikat penyelesaian',
              ],
              isPopular: true,
              isDarkMode: isDarkMode,
            ),
            
            SizedBox(height: 16),
            
            _buildPackageCard(
              title: 'Paket VIP',
              price: 'Rp 1.200.000',
              duration: '12 Pertemuan',
              features: [
                '3x per minggu',
                'Durasi 60 menit',
                'Instruktur berpengalaman',
                'Kolam renang berkualitas',
                'Progress tracking',
                'Sertifikat penyelesaian',
                'Konsultasi personal',
                'Video analisis teknik',
              ],
              isPopular: false,
              isDarkMode: isDarkMode,
            ),
            
            SizedBox(height: 16),
            
            // Special Programs
            _buildSpecialPrograms(isDarkMode: isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageCard({
    required String title,
    required String price,
    required String duration,
    required List<String> features,
    required bool isPopular,
    required bool isDarkMode,
  }) {
    return Card(
      elevation: isPopular ? 8 : 2,
      color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPopular 
            ? BorderSide(color: Color(0xFF003566), width: 2)
            : BorderSide.none,
      ),
      child: Stack(
        children: [
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF003566), Color(0xFF00509E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Text(
                  'POPULER',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : Color(0xFF003566),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price,
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF003566),
                          ),
                        ),
                        Text(
                          duration,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Fitur yang didapat:',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white70 : Color(0xFF003566),
                  ),
                ),
                SizedBox(height: 8),
                ...features.map((feature) => Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: Colors.green,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: isDarkMode ? Colors.white70 : Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement package selection
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF003566),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Pilih Paket',
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialPrograms({required bool isDarkMode}) {
    return Card(
      elevation: 2,
      color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.star,
                  color: Color(0xFF003566),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Program Khusus',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Color(0xFF003566),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildSpecialProgramItem(
              title: 'Baby Swim & Spa',
              description: 'Program khusus untuk bayi usia 6-24 bulan',
              price: 'Rp 300.000',
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 12),
            _buildSpecialProgramItem(
              title: 'Hydrotherapy',
              description: 'Terapi air untuk pemulihan dan kesehatan',
              price: 'Rp 400.000',
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 12),
            _buildSpecialProgramItem(
              title: 'Competitive Swimming',
              description: 'Pelatihan untuk kompetisi renang',
              price: 'Rp 600.000',
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialProgramItem({
    required String title,
    required String description,
    required String price,
    required bool isDarkMode,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF2A2A2A) : Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF003566).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Color(0xFF003566),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white60 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003566),
                ),
              ),
              SizedBox(height: 4),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement special program selection
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF003566),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Detail',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
