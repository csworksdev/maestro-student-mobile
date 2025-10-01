import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
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
                        Icons.trending_up,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Progress Latihan',
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
                    'Pantau perkembangan kemampuan renang Anda',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Progress Overview
            _buildProgressOverview(isDarkMode: isDarkMode),
            
            SizedBox(height: 16),
            
            // Skills Progress
            _buildSkillsProgress(isDarkMode: isDarkMode),
            
            SizedBox(height: 16),
            
            // Recent Achievements
            _buildRecentAchievements(isDarkMode: isDarkMode),
            
            SizedBox(height: 16),
            
            // Goals
            _buildGoals(isDarkMode: isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressOverview({required bool isDarkMode}) {
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
            Text(
              'Ringkasan Progress',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Color(0xFF003566),
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Latihan',
                    value: '24',
                    subtitle: 'pertemuan',
                    icon: Icons.pool,
                    isDarkMode: isDarkMode,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Durasi',
                    value: '24',
                    subtitle: 'jam',
                    icon: Icons.timer,
                    isDarkMode: isDarkMode,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Level',
                    value: 'Intermediate',
                    subtitle: 'current',
                    icon: Icons.star,
                    isDarkMode: isDarkMode,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Streak',
                    value: '7',
                    subtitle: 'hari',
                    icon: Icons.local_fire_department,
                    isDarkMode: isDarkMode,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
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
      child: Column(
        children: [
          Icon(
            icon,
            color: Color(0xFF003566),
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Color(0xFF003566),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: isDarkMode ? Colors.white60 : Colors.grey[600],
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.nunito(
              fontSize: 10,
              color: isDarkMode ? Colors.white : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsProgress({required bool isDarkMode}) {
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
            Text(
              'Kemampuan Renang',
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Color(0xFF003566),
              ),
            ),
            SizedBox(height: 16),
            _buildSkillItem(
              skill: 'Freestyle',
              progress: 0.8,
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 12),
            _buildSkillItem(
              skill: 'Backstroke',
              progress: 0.6,
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 12),
            _buildSkillItem(
              skill: 'Breaststroke',
              progress: 0.4,
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 12),
            _buildSkillItem(
              skill: 'Butterfly',
              progress: 0.2,
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillItem({
    required String skill,
    required double progress,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              skill,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : Color(0xFF003566),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF003566),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: isDarkMode ? Color(0xFF2A2A2A) : Color(0xFFE0E0E0),
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003566)),
          minHeight: 8,
        ),
      ],
    );
  }

  Widget _buildRecentAchievements({required bool isDarkMode}) {
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
                  Icons.emoji_events,
                  color: Color(0xFF003566),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Pencapaian Terbaru',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Color(0xFF003566),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildAchievementItem(
              title: 'Freestyle Master',
              description: 'Menyelesaikan 10 putaran tanpa berhenti',
              date: '2 hari yang lalu',
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 12),
            _buildAchievementItem(
              title: 'Consistency Champion',
              description: 'Latihan selama 7 hari berturut-turut',
              date: '1 minggu yang lalu',
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 12),
            _buildAchievementItem(
              title: 'Speed Demon',
              description: 'Mencapai waktu terbaik untuk 50m',
              date: '2 minggu yang lalu',
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementItem({
    required String title,
    required String description,
    required String date,
    required bool isDarkMode,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF2A2A2A) : Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
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
                SizedBox(height: 4),
                Text(
                  date,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoals({required bool isDarkMode}) {
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
                  Icons.flag,
                  color: Color(0xFF003566),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Target & Tujuan',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Color(0xFF003566),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildGoalItem(
              title: 'Menguasai 4 Gaya Renang',
              progress: 0.5,
              deadline: '3 bulan lagi',
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 12),
            _buildGoalItem(
              title: 'Mencapai Level Advanced',
              progress: 0.3,
              deadline: '6 bulan lagi',
              isDarkMode: isDarkMode,
            ),
            SizedBox(height: 12),
            _buildGoalItem(
              title: 'Mengikuti Kompetisi',
              progress: 0.1,
              deadline: '1 tahun lagi',
              isDarkMode: isDarkMode,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalItem({
    required String title,
    required double progress,
    required String deadline,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Color(0xFF003566),
                  ),
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003566),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: isDarkMode ? Color(0xFF2A2A2A) : Color(0xFFE0E0E0),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF003566)),
            minHeight: 6,
          ),
          SizedBox(height: 8),
          Text(
            'Target: $deadline',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: isDarkMode ? Colors.white : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}