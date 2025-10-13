import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:maestro_client_mobile/models/student_package.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:maestro_client_mobile/services/package_service.dart';
import 'package:maestro_client_mobile/theme/app_theme.dart';

class ActivePackagesScreen extends StatefulWidget {
  const ActivePackagesScreen({super.key});

  @override
  State<ActivePackagesScreen> createState() => _ActivePackagesScreenState();
}

class _ActivePackagesScreenState extends State<ActivePackagesScreen> {
  final PackageService _packageService = PackageService();

  // 0 = ongoing, 1 = todo (ordered but not yet active)
  int _filterIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;
  List<StudentPackage> _packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<StudentPackage> result;
      if (_filterIndex == 0) {
        result = await _packageService.getOngoingPackages();
      } else {
        result = await _packageService.getTodoPackages();
      }
      setState(() {
        _packages = result;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

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
      body: RefreshIndicator(
        onRefresh: _loadPackages,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(isDarkMode),
              const SizedBox(height: 16),
              _buildFilters(isDarkMode),
              const SizedBox(height: 16),
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.navy),
                    ),
                  ),
                )
              else if (_errorMessage != null)
                _buildErrorState(_errorMessage!, isDarkMode)
              else if (_packages.isEmpty)
                _buildEmptyState(isDarkMode)
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _packages.length,
                  itemBuilder: (context, index) => _buildPackageCard(_packages[index], isDarkMode),
                ),
            ],
          ),
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

  Widget _buildFilters(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildFilterChip(
            label: 'Sedang Berjalan',
            selected: _filterIndex == 0,
            isDarkMode: isDarkMode,
            onTap: () {
              if (_filterIndex != 0) {
                setState(() => _filterIndex = 0);
                _loadPackages();
              }
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterChip(
            label: 'Belum Aktif',
            selected: _filterIndex == 1,
            isDarkMode: isDarkMode,
            onTap: () {
              if (_filterIndex != 1) {
                setState(() => _filterIndex = 1);
                _loadPackages();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    final Color bg = selected
        ? AppColors.navy
        : (isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA));
    final Color fg = selected ? Colors.white : (isDarkMode ? Colors.white70 : AppColors.navy);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.navy.withValues(alpha: 0.2)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gagal memuat data',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.red,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: isDarkMode ? Colors.white70 : Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadPackages,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.navy),
            child: const Text('Coba lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    final String title = _filterIndex == 0 ? 'Tidak ada paket berjalan' : 'Tidak ada paket yang belum aktif';
    final String subtitle = _filterIndex == 0
        ? 'Siswa belum memiliki paket yang sedang berlangsung.'
        : 'Tidak ditemukan paket yang telah dipesan namun belum aktif.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.navy.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : AppColors.navy,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: isDarkMode ? Colors.white70 : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard(StudentPackage package, bool isDarkMode) {
    final bool isTodo = _filterIndex == 1;

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
            Row(
              children: [
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
                      (package.studentFullname.isNotEmpty ? package.studentFullname[0] : '?').toUpperCase(),
                      style: GoogleFonts.nunito(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        package.studentFullname,
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.white : AppColors.navy,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      _buildStatusBadge(
                        isTodo ? 'Belum Aktif' : 'Sedang Berjalan',
                        isTodo ? const Color(0xFF9E9E9E) : const Color(0xFF4CAF50),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPackageInfo(package, isDarkMode),
            const SizedBox(height: 12),
            _buildProgressBar(package, isDarkMode, isTodo: isTodo),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String statusText, Color badgeColor) {
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

  Widget _buildPackageInfo(StudentPackage package, bool isDarkMode) {
    final String validUntilText = package.expireDate != null
        ? DateFormat('dd MMM yyyy', 'id').format(package.expireDate!.toLocal())
        : '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          package.packageName,
          style: GoogleFonts.nunito(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.navy,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildInfoItem(
                icon: Icons.schedule,
                label: 'Pertemuan Tersisa',
                value: '${package.meetingsRemainder}',
                isDarkMode: isDarkMode,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildInfoItem(
                icon: Icons.calendar_today,
                label: 'Berlaku Sampai',
                value: validUntilText,
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

  Widget _buildProgressBar(StudentPackage package, bool isDarkMode, {bool isTodo = false}) {
    final double progress = isTodo
        ? 0.0
        : (package.meetingsAmount > 0 ? (package.meetingsAmount - package.meetingsRemainder) / package.meetingsAmount : 0.0);

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
          isTodo
              ? 'Belum dimulai'
              : '${(package.meetingsAmount - package.meetingsRemainder).clamp(0, package.meetingsAmount)} dari ${package.meetingsAmount} pertemuan digunakan',
          style: GoogleFonts.nunito(
            fontSize: 10,
            color: isDarkMode ? Colors.white60 : Colors.grey[500],
          ),
        ),
      ],
    );
  }
}
