import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:maestro_client_mobile/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:maestro_client_mobile/providers/student_provider.dart';
import 'package:maestro_client_mobile/services/api_service.dart';
import 'dart:convert';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final ApiClient _apiClient = ApiClient();

  String? _focusedStudentId; // null = fokus ke semua

  List<Map<String, dynamic>> _todaySchedules = [];
  List<Map<String, dynamic>> _weekSchedules = [];

  bool _isLoadingToday = false;
  bool _isLoadingWeek = false;

  String? _errorToday;
  String? _errorWeek;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final studentProvider = Provider.of<StudentProvider>(context, listen: false);
        if (studentProvider.students.isEmpty) {
          await studentProvider.fetchStudents();
        }
      } catch (_) {}
      await _fetchTodaySchedules();
      await _fetchWeekSchedules();
    });
  }

  Future<void> _fetchTodaySchedules() async {
    setState(() {
      _isLoadingToday = true;
      _errorToday = null;
    });
    try {
      final response = await _apiClient.get('siswa/schedules/today/');
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = decoded['data'] ?? [];
        setState(() {
          _todaySchedules = List<Map<String, dynamic>>.from(data);
        });
      } else {
        setState(() {
          _errorToday = 'Gagal memuat jadwal hari ini (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _errorToday = 'Terjadi kesalahan: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingToday = false;
        });
      }
    }
  }

  Future<void> _fetchWeekSchedules() async {
    setState(() {
      _isLoadingWeek = true;
      _errorWeek = null;
    });
    try {
      final response = await _apiClient.get('siswa/schedules/week/');
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final List<dynamic> data = decoded['data'] ?? [];
        setState(() {
          _weekSchedules = List<Map<String, dynamic>>.from(data);
        });
      } else {
        setState(() {
          _errorWeek = 'Gagal memuat jadwal minggu ini (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        _errorWeek = 'Terjadi kesalahan: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingWeek = false;
        });
      }
    }
  }

  Future<void> _onRefresh() async {
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      await Future.wait([
        studentProvider.fetchStudents(),
        _fetchTodaySchedules(),
        _fetchWeekSchedules(),
      ]);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;
    final studentProvider = Provider.of<StudentProvider>(context);
    final students = studentProvider.students;
    final sortedStudents = List.of(students);
    sortedStudents.sort((a, b) {
      final nameA = (a.nickname.isNotEmpty ? a.nickname : a.fullname).toLowerCase();
      final nameB = (b.nickname.isNotEmpty ? b.nickname : b.fullname).toLowerCase();
      return nameA.compareTo(nameB);
    });

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : AppColors.white,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.orange,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
                ...sortedStudents.map((s) {
                  final bool isSelected = _focusedStudentId == s.studentId;
                  final displayName = s.nickname.isNotEmpty ? s.nickname : s.fullname;
                  return ChoiceChip(
                    label: Text(displayName),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _focusedStudentId = s.studentId),
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
              schedules: _focusedStudentId == null
                  ? _todaySchedules
                  : _todaySchedules.where((e) => e['student_id'] == _focusedStudentId).toList(),
              isDarkMode: isDarkMode,
              isLoading: _isLoadingToday,
              error: _errorToday,
            ),
            
            SizedBox(height: 16),
            
            // This Week's Schedule
            _buildScheduleCard(
              title: 'Minggu Ini',
              schedules: _focusedStudentId == null
                  ? _weekSchedules
                  : _weekSchedules.where((e) => e['student_id'] == _focusedStudentId).toList(),
              isDarkMode: isDarkMode,
              isLoading: _isLoadingWeek,
              error: _errorWeek,
            ),
            
            SizedBox(height: 16),

          ],
        ),
      ),
    ),
  );
  }

  Widget _buildScheduleCard({
    required String title,
    required List<Map<String, dynamic>> schedules,
    required bool isDarkMode,
    bool isLoading = false,
    String? error,
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
            if (isLoading)
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.orange),
                  ),
                ),
              )
            else if (error != null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  error,
                  style: GoogleFonts.nunito(color: Colors.red),
                ),
              )
            else if (schedules.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Tidak ada jadwal',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              )
            else
              ...schedules
                  .map((schedule) => _buildScheduleItem(
                        schedule: schedule,
                        isDarkMode: isDarkMode,
                      ))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem({
    required Map<String, dynamic> schedule,
    required bool isDarkMode,
  }) {
    final Color panelColor = isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5);

    final String studentName = (schedule['student_fullname'] ?? '-')!.toString();
    final String date = (schedule['schedule_date'] ?? '-')!.toString();
    final String day = (schedule['day'] ?? '')!.toString();
    final String timeRaw = (schedule['time'] ?? '-')!.toString();
    final String displayTime = timeRaw.replaceAll('.', ':');
    final String packageName = (schedule['package_name'] ?? '-')!.toString();
    final String instructor = (schedule['trainer_nickname'] ?? '-')?.toString() ?? '-';
    final String location = (schedule['pool_name'] ?? '-')?.toString() ?? '-';

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
                  studentName,
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
                  color: AppColors.orange.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  date,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.orange,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  day.isNotEmpty ? '$displayTime • $day' : displayTime,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? AppColors.white : AppColors.navy,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.navy.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  packageName,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: AppColors.navy,
              ),
              SizedBox(width: 4),
              Text(
                instructor,
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
                  location,
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
