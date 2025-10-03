import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:maestro_client_mobile/models/package_models.dart' as models;
import 'package:maestro_client_mobile/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ActivePackagesScreen extends StatefulWidget {
  const ActivePackagesScreen({super.key});

  @override
  _ActivePackagesScreenState createState() => _ActivePackagesScreenState();
}

class _ActivePackagesScreenState extends State<ActivePackagesScreen> {
  final List<models.Package> packages = _getMockPackages();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF044366),
            size: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(isDarkMode),
            
            const SizedBox(height: 24),
            
            // Packages List
            ...packages.map((package) => _buildPackageCard(package, isDarkMode)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : AppColors.navy,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.card_membership,
                color: AppColors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Paket Aktif',
                style: GoogleFonts.nunito(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Lihat paket aktif setiap siswa',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(models.Package package, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Info Header
            Row(
              children: [
                // Avatar
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF044366), Color(0xFF065A8A)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF044366).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      package.studentName.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Student Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.studentName,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : AppColors.navy,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(package.status, isDarkMode),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Package Info
            _buildPackageInfo(package, isDarkMode),
            
            const SizedBox(height: 12),
            
            // Progress Bar
            _buildProgressBar(package, isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, bool isDarkMode) {
    Color badgeColor;
    String statusText;
    
    switch (status.toLowerCase()) {
      case 'active':
        badgeColor = const Color(0xFF4CAF50);
        statusText = 'Aktif';
        break;
      case 'expired':
        badgeColor = const Color(0xFFF44336);
        statusText = 'Kadaluarsa';
        break;
      case 'suspended':
        badgeColor = const Color(0xFFFF9800);
        statusText = 'Ditangguhkan';
        break;
      default:
        badgeColor = const Color(0xFF9E9E9E);
        statusText = status;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        statusText,
        style: GoogleFonts.nunito(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: badgeColor,
        ),
      ),
    );
  }

  Widget _buildPackageInfo(models.Package package, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          package.name,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.navy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          package.description,
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: isDarkMode ? Colors.white70 : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.schedule,
                label: 'Pertemuan Tersisa',
                value: '${package.remainingSessions}',
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.calendar_today,
                label: 'Berlaku Sampai',
                value: DateFormat('dd MMM yyyy', 'id').format(package.validUntil),
                isDarkMode: isDarkMode,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool isDarkMode,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.navy.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.navy,
            size: 16,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.navy,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 8,
              color: isDarkMode ? Colors.white60 : Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(models.Package package, bool isDarkMode) {
    final progress = (package.totalSessions - package.remainingSessions) / package.totalSessions;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress Paket',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white70 : Colors.grey[600],
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.nunito(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.navy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.navy),
          minHeight: 6,
        ),
        const SizedBox(height: 4),
        Text(
          '${package.totalSessions - package.remainingSessions} dari ${package.totalSessions} pertemuan digunakan',
          style: GoogleFonts.nunito(
            fontSize: 10,
            color: isDarkMode ? Colors.white60 : Colors.grey[500],
          ),
        ),
      ],
    );
  }
}

// Mock data
List<models.Package> _getMockPackages() {
  return [
    models.Package(
      id: '1',
      name: 'Paket Premium 12 Pertemuan',
      description: 'Paket latihan renang premium dengan 12 pertemuan',
      totalSessions: 12,
      remainingSessions: 8,
      validUntil: DateTime.now().add(const Duration(days: 45)),
      status: 'active',
      price: 1200000,
      studentId: '1',
      studentName: 'Ahmad Rizki',
    ),
    models.Package(
      id: '2',
      name: 'Paket Basic 8 Pertemuan',
      description: 'Paket latihan renang basic dengan 8 pertemuan',
      totalSessions: 8,
      remainingSessions: 2,
      validUntil: DateTime.now().add(const Duration(days: 15)),
      status: 'active',
      price: 800000,
      studentId: '2',
      studentName: 'Siti Nurhaliza',
    ),
    models.Package(
      id: '3',
      name: 'Paket Intensive 20 Pertemuan',
      description: 'Paket latihan renang intensive dengan 20 pertemuan',
      totalSessions: 20,
      remainingSessions: 0,
      validUntil: DateTime.now().subtract(const Duration(days: 5)),
      status: 'expired',
      price: 2000000,
      studentId: '3',
      studentName: 'Budi Santoso',
    ),
  ];
}
