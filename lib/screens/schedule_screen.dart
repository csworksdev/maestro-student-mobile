import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
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
                        Icons.schedule,
                        color: Colors.white,
                        size: 28,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Jadwal Latihan',
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
                    'Lihat jadwal latihan renang Anda',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Today's Schedule
            _buildScheduleCard(
              title: 'Hari Ini',
              schedules: [
                {
                  'time': '09:00 - 10:00',
                  'class': 'Private 1',
                  'instructor': 'Coach Santi',
                  'location': 'Kolam Renang Bandung',
                  'status': 'confirmed',
                },
                {
                  'time': '15:00 - 16:00',
                  'class': 'Group Class',
                  'instructor': 'Coach Lia',
                  'location': 'Kolam Renang Jakarta',
                  'status': 'pending',
                },
              ],
              isDarkMode: isDarkMode,
            ),
            
            SizedBox(height: 16),
            
            // This Week's Schedule
            _buildScheduleCard(
              title: 'Minggu Ini',
              schedules: [
                {
                  'time': 'Selasa, 10:00 - 11:00',
                  'class': 'Baby Swim & Spa',
                  'instructor': 'Coach Acel',
                  'location': 'Kolam Renang Cikarang',
                  'status': 'confirmed',
                },
                {
                  'time': 'Kamis, 14:00 - 15:00',
                  'class': 'Private 2',
                  'instructor': 'Coach Santi',
                  'location': 'Kolam Renang Bogor',
                  'status': 'confirmed',
                },
                {
                  'time': 'Sabtu, 16:00 - 17:00',
                  'class': 'Group Class',
                  'instructor': 'Coach Lia',
                  'location': 'Kolam Renang Tangerang',
                  'status': 'pending',
                },
              ],
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
                  Icons.calendar_today,
                  color: Color(0xFF003566),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  title,
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Color(0xFF003566),
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
    final statusColor = schedule['status'] == 'confirmed' 
        ? Colors.green 
        : Colors.orange;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF2A2A2A) : Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                schedule['time']!,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Color(0xFF003566),
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
              color: isDarkMode ? Colors.white70 : Color(0xFF003566),
            ),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: Color(0xFF003566),
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
                color: Color(0xFF003566),
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
