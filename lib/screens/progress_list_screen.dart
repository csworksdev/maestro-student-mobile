import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:maestro_client_mobile/models/student_progress.dart' as models;
import 'package:maestro_client_mobile/screens/progress_detail_screen.dart';
import 'package:maestro_client_mobile/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressListScreen extends StatefulWidget {
  const ProgressListScreen({super.key});

  @override
  _ProgressListScreenState createState() => _ProgressListScreenState();
}

class _ProgressListScreenState extends State<ProgressListScreen> {
  final List<models.Student> students = _getMockStudents();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(isDarkMode),
            
            const SizedBox(height: 24),
            
            // Students List
            ...students.map((student) => _buildStudentCard(student, isDarkMode)).toList(),
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
                Icons.school,
                color: AppColors.white,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Progress Siswa',
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
            'Pantau perkembangan setiap siswa',
            style: GoogleFonts.nunito(
              fontSize: 16,
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(models.Student student, bool isDarkMode) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProgressDetailScreen(student: student),
              ),
            );
          },
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
                          student.name.substring(0, 1).toUpperCase(),
                          style: GoogleFonts.nunito(
                            fontSize: 24,
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
                            student.name,
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : const Color(0xFF044366),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          _buildLevelInfo(student, isDarkMode),
                        ],
                      ),
                    ),
                    
                    // Expand Icon
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEE7D21).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios,
                        color: Color(0xFFEE7D21),
                        size: 14,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Progress Summary
                _buildProgressSummary(student, isDarkMode),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelInfo(models.Student student, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFEE7D21).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEE7D21).withOpacity(0.3),
        ),
      ),
      child: Text(
        'Total Paket!',
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFFEE7D21),
        ),
      ),
    );
  }

  Widget _buildProgressSummary(models.Student student, bool isDarkMode) {
    final totalSessions = student.sessions.length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.pool,
            label: 'Total Pertemuan',
            value: totalSessions.toString(),
            isDarkMode: isDarkMode,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSummaryItem(
            icon: Icons.inventory_2,
            label: 'Total Paket',
            value: '12', // Placeholder value
            isDarkMode: isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
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
          color: const Color(0xFF044366).withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF044366),
            size: 16,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : const Color(0xFF044366),
            ),
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
}

// Mock data
List<models.Student> _getMockStudents() {
  return [
    models.Student(
      id: '1',
      name: 'Ahmad Rizki',
      avatar: '',
      currentLevel: 'Beginner 1',
      badges: [
        models.Badge(
          id: '1',
          name: 'Speed Master',
          description: 'Mencapai kecepatan tinggi',
          icon: 'speed',
          earnedDate: DateTime.now().subtract(const Duration(days: 5)),
          color: '#FFD700',
        ),
        models.Badge(
          id: '2',
          name: 'Consistency',
          description: 'Latihan rutin 7 hari',
          icon: 'consistency',
          earnedDate: DateTime.now().subtract(const Duration(days: 10)),
          color: '#FF6B35',
        ),
      ],
      sessions: _getMockSessions(),
    ),
    models.Student(
      id: '2',
      name: 'Siti Nurhaliza',
      avatar: '',
      currentLevel: 'Beginner 1',
      badges: [
        models.Badge(
          id: '3',
          name: 'First Steps',
          description: 'Pertama kali berenang',
          icon: 'technique',
          earnedDate: DateTime.now().subtract(const Duration(days: 3)),
          color: '#4CAF50',
        ),
      ],
      sessions: _getMockSessions(),
    ),
    models.Student(
      id: '3',
      name: 'Budi Santoso',
      avatar: '',
      currentLevel: 'Beginner 1',
      badges: [
        models.Badge(
          id: '4',
          name: 'Endurance King',
          description: 'Berenang 1km tanpa berhenti',
          icon: 'endurance',
          earnedDate: DateTime.now().subtract(const Duration(days: 2)),
          color: '#2196F3',
        ),
        models.Badge(
          id: '5',
          name: 'Technique Pro',
          description: 'Menguasai 4 gaya renang',
          icon: 'technique',
          earnedDate: DateTime.now().subtract(const Duration(days: 7)),
          color: '#9C27B0',
        ),
      ],
      sessions: _getMockSessions(),
    ),
  ];
}

List<models.ProgressSession> _getMockSessions() {
  return [
    models.ProgressSession(
      id: '1',
      date: DateTime.now().subtract(const Duration(days: 1)),
      coachName: 'Coach John',
      notes: 'Siswa menunjukkan peningkatan yang baik dalam teknik freestyle. Fokus pada pernapasan yang lebih efisien.',
      scores: {'freestyle': 8.5, 'backstroke': 7.0, 'breaststroke': 6.5},
      improvements: ['Teknik tangan lebih baik', 'Posisi tubuh lebih streamline'],
      areasToWorkOn: ['Pernapasan', 'Kick yang lebih kuat'],
    ),
    models.ProgressSession(
      id: '2',
      date: DateTime.now().subtract(const Duration(days: 3)),
      coachName: 'Coach Sarah',
      notes: 'Latihan fokus pada endurance. Siswa mampu berenang 200m tanpa berhenti.',
      scores: {'freestyle': 8.0, 'endurance': 7.5},
      improvements: ['Stamina meningkat', 'Posisi tubuh konsisten'],
      areasToWorkOn: ['Kecepatan', 'Teknik turn'],
    ),
  ];
}