import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:maestro_client_mobile/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Simulasi data siswa dan jadwalnya
  final List<Map<String, dynamic>> _students = [
    {
      'id': 's1',
      'name': 'Arya',
      'schedules': [
        {
          'time': '09:00 - 10:00',
          'date': 'Hari Ini',
          'class': 'Private 1',
          'instructor': 'Coach Santi',
          'location': 'Kolam Renang Bandung',
          'status': 'confirmed',
          'attendance': 'hadir',
        },
        {
          'time': 'Selasa, 10:00 - 11:00',
          'date': 'Minggu Ini',
          'class': 'Baby Swim & Spa',
          'instructor': 'Coach Acel',
          'location': 'Kolam Renang Cikarang',
          'status': 'confirmed',
          'attendance': 'absen',
        },
      ],
    },
    {
      'id': 's2',
      'name': 'Dewi',
      'schedules': [
        {
          'time': '15:00 - 16:00',
          'date': 'Hari Ini',
          'class': 'Group Class',
          'instructor': 'Coach Lia',
          'location': 'Kolam Renang Jakarta',
          'status': 'pending',
          'attendance': 'hadir',
        },
        {
          'time': 'Kamis, 14:00 - 15:00',
          'date': 'Minggu Ini',
          'class': 'Private 2',
          'instructor': 'Coach Santi',
          'location': 'Kolam Renang Bogor',
          'status': 'confirmed',
          'attendance': 'hadir',
        },
        {
          'time': 'Sabtu, 16:00 - 17:00',
          'date': 'Minggu Ini',
          'class': 'Group Class',
          'instructor': 'Coach Lia',
          'location': 'Kolam Renang Tangerang',
          'status': 'pending',
          'attendance': 'absen',
        },
      ],
    },
  ];

  String? _focusedStudentId; // null = fokus ke semua

  List<Map<String, String>> _collectSchedulesByDate(String date) {
    // Kumpulkan jadwal dari siswa yang dipilih atau semua siswa jika tidak ada yang dipilih
    final List<Map<String, String>> result = [];
    for (final student in _students) {
      // Filter berdasarkan siswa yang dipilih, jika ada
      if (_focusedStudentId == null || student['id'] == _focusedStudentId) {
        for (final item in (student['schedules'] as List)) {
          if (item['date'] == date) {
            result.add({
              'studentId': student['id'],
              'studentName': student['name'],
              'time': item['time'],
              'class': item['class'],
              'instructor': item['instructor'],
              'location': item['location'],
              'status': item['status'],
              'attendance': item['attendance'],
            });
          }
        }
      }
    }
    return result;
  }
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : AppColors.white,
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
                color: isDarkMode ? const Color(0xFF1A1A1A) : AppColors.navy,
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
                        Icons.schedule,
                        color: AppColors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Jadwal Latihan',
                        style: GoogleFonts.nunito(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Lihat jadwal latihan renang Anda',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),

            // Filter per siswa (semua tetap tampil, tap untuk fokus)
            Text(
              'Filter Siswa',
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDarkMode ? AppColors.white : AppColors.navy,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ChoiceChip(
                  label: Text('Semua'),
                  selected: _focusedStudentId == null,
                  onSelected: (_) => setState(() => _focusedStudentId = null),
                  selectedColor: AppColors.orange,
                  labelStyle: GoogleFonts.nunito(
                    color: _focusedStudentId == null ? AppColors.white : (isDarkMode ? AppColors.white : AppColors.navy),
                    fontWeight: FontWeight.w600,
                  ),
                  backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : AppColors.white,
                  side: BorderSide(color: AppColors.orange),
                  shape: StadiumBorder(),
                ),
                ..._students.map((s) {
                  final bool isSelected = _focusedStudentId == s['id'];
                  return ChoiceChip(
                    label: Text(s['name'] as String),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _focusedStudentId = s['id'] as String),
                    selectedColor: AppColors.orange,
                    labelStyle: GoogleFonts.nunito(
                      color: isSelected ? AppColors.white : (isDarkMode ? AppColors.white : AppColors.navy),
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : AppColors.white,
                    side: BorderSide(color: AppColors.orange),
                    shape: StadiumBorder(),
                  );
                }).toList(),
              ],
            ),
            SizedBox(height: 16),
            
            // Today's Schedule
            _buildScheduleCard(
              title: 'Hari Ini',
              schedules: _collectSchedulesByDate('Hari Ini'),
              isDarkMode: isDarkMode,
            ),
            
            SizedBox(height: 16),
            
            // This Week's Schedule
            _buildScheduleCard(
              title: 'Minggu Ini',
              schedules: _collectSchedulesByDate('Minggu Ini'),
              isDarkMode: isDarkMode,
            ),
            
            SizedBox(height: 16),

          ],
        ),
      ),
    );
  }

  Widget _buildScheduleCard({
    required String title,
    required List<Map<String, String>> schedules,
    required bool isDarkMode,
  }) {
    return Card(
      elevation: 2,
      color: isDarkMode ? const Color(0xFF1A1A1A) : AppColors.white,
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
                  Icons.calendar_today,
                  color: AppColors.navy,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.white : AppColors.navy,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ...schedules.map((schedule) => _buildScheduleItem(
                  schedule: schedule,
                  isDarkMode: isDarkMode,
                )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem({
    required Map<String, String> schedule,
    required bool isDarkMode,
  }) {
    final Color statusColor = schedule['status'] == 'confirmed' ? Colors.green : AppColors.orange;
    final Color panelColor = isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: panelColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.orange,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.navy.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  schedule['studentName'] ?? '-',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDarkMode ? AppColors.white : AppColors.navy,
                  ),
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (schedule['attendance'] == 'hadir' ? Colors.green : Colors.red).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  schedule['attendance'] == 'hadir' ? 'Hadir' : 'Absen',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: schedule['attendance'] == 'hadir' ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                schedule['time']!,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.white : AppColors.navy,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  schedule['status'] == 'confirmed' ? 'Dikonfirmasi' : 'Menunggu',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            schedule['class']!,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white70 : AppColors.navy,
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: AppColors.navy,
              ),
              SizedBox(width: 4),
              Text(
                schedule['instructor']!,
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  color: isDarkMode ? Colors.white60 : Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: AppColors.navy,
              ),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  schedule['location']!,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: isDarkMode ? Colors.white60 : Colors.grey[600],
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
