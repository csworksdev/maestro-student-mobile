import 'package:flutter/material.dart';
import 'dart:ui';

class KeunggulanKolamPage extends StatelessWidget {
  const KeunggulanKolamPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    // Definisi warna sesuai tema
    const Color navyColor = Color(0xFF044366);
    const Color orangeColor = Color(0xFFEE7D22);
    const Color whiteColor = Color(0xFFFFFFFF);
    
    return Scaffold(
      backgroundColor: navyColor,
      appBar: AppBar(
        backgroundColor: navyColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: whiteColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Maestro Swim',
                        style: TextStyle(
                          color: orangeColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Fasilitas Kolam Renang Terbaik',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Keunggulan 1
                _buildKeunggulanCard(
                  icon: Icons.location_on,
                  title: 'Mudah Diakses',
                  description: 'Kami memilih lokasi yang mudah dijangkau dengan transportasi umum maupun kendaraan pribadi.',
                ),
                
                const SizedBox(height: 16),
                
                // Keunggulan 2
                _buildKeunggulanCard(
                  icon: Icons.pool,
                  title: 'Kolam Renang Modern',
                  description: 'Setiap cabang Maestro Swim dilengkapi dengan kolam renang modern dan terawat, menjamin keamanan dan kenyamanan Anda saat berlatih.',
                ),
                
                const SizedBox(height: 16),
                
                // Keunggulan 3
                _buildKeunggulanCard(
                  icon: Icons.house,
                  title: 'Ruang Ganti yang Nyaman',
                  description: 'Kami menyediakan ruang ganti yang bersih dan nyaman untuk membuat pengalaman belajar berenang Anda semakin menyenangkan.',
                ),
                
                const SizedBox(height: 30),
                
                // Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [orangeColor.withOpacity(0.8), orangeColor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Bergabunglah dengan Maestro Swim',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Nikmati fasilitas terbaik untuk pengalaman berenang yang menyenangkan',
                        style: TextStyle(
                          color: whiteColor,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildKeunggulanCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEE7D22),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}