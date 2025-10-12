import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:maestro_client_mobile/models/student_progress.dart' as models;
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ProgressDetailScreen extends StatefulWidget {
  final models.Student student;

  const ProgressDetailScreen({super.key, required this.student});

  @override
  _ProgressDetailScreenState createState() => _ProgressDetailScreenState();
}

class _ProgressDetailScreenState extends State<ProgressDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA),
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
            // Student Info Card
            _buildStudentInfoCard(isDarkMode),
            
            const SizedBox(height: 20),
            
            // Progress Timeline
            _buildProgressTimeline(isDarkMode),
          ],
        ),
      ),
    );
  }


  Widget _buildStudentInfoCard(bool isDarkMode) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    widget.student.name.substring(0, 1).toUpperCase(),
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
                      widget.student.name,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : const Color(0xFF044366),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    _buildLevelProgress(isDarkMode),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.pool,
                  label: 'Total Pertemuan',
                  value: widget.student.sessions.length.toString(),
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.emoji_events,
                  label: 'Badge',
                  value: widget.student.badges.length.toString(),
                  isDarkMode: isDarkMode,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.trending_up,
                  label: 'Progress',
                  value: '85%',
                  isDarkMode: isDarkMode,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF044366).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF044366).withOpacity(0.3),
        ),
      ),
      child: Text(
        widget.student.currentLevel,
        style: GoogleFonts.nunito(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF044366),
        ),
      ),
    );
  }

  Widget _buildStatItem({
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

  Widget _buildProgressTimeline(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline Progress',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF044366),
          ),
        ),
        const SizedBox(height: 16),
        
        // Timeline
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.student.sessions.length,
          itemBuilder: (context, index) {
            final session = widget.student.sessions[index];
            final isLast = index == widget.student.sessions.length - 1;
            
            return _buildTimelineItem(session, isLast, isDarkMode);
          },
        ),
      ],
    );
  }

  Widget _buildTimelineItem(models.ProgressSession session, bool isLast, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Line
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF044366),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF044366).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 100,
                color: const Color(0xFF044366).withOpacity(0.3),
                margin: const EdgeInsets.only(top: 8),
              ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        // Content
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF044366).withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('dd MMMM yyyy', 'id').format(session.date),
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : const Color(0xFF044366),
                            ),
                          ),
                          Text(
                            'Coach: ${session.coachName}',
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: isDarkMode ? Colors.white60 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF044366).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Pertemuan ${widget.student.sessions.indexOf(session) + 1}',
                        style: GoogleFonts.nunito(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF044366),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Notes
                Text(
                  session.notes,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Scores
                if (session.scores.isNotEmpty) ...[
                  Text(
                    'Nilai Pertemuan',
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : const Color(0xFF044366),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildScoresRow(session.scores, isDarkMode),
                  const SizedBox(height: 16),
                ],
                
                // Improvements
                if (session.improvements.isNotEmpty) ...[
                  _buildSection(
                    title: 'Peningkatan',
                    items: session.improvements,
                    icon: Icons.trending_up,
                    color: const Color(0xFF4CAF50),
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Areas to Work On
                if (session.areasToWorkOn.isNotEmpty) ...[
                  _buildSection(
                    title: 'Area Perbaikan',
                    items: session.areasToWorkOn,
                    icon: Icons.build,
                    color: const Color(0xFFEE7D21),
                    isDarkMode: isDarkMode,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoresRow(Map<String, double> scores, bool isDarkMode) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: scores.entries.map((entry) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getScoreColor(entry.value).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: _getScoreColor(entry.value).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  entry.key,
                  style: GoogleFonts.nunito(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: _getScoreColor(entry.value),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                entry.value.toString(),
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: _getScoreColor(entry.value),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color color,
    required bool isDarkMode,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: color,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF044366),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(top: 6, right: 8),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  item,
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white70 : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 8.0) return const Color(0xFF4CAF50);
    if (score >= 6.0) return const Color(0xFFEE7D21);
    return const Color(0xFFF44336);
  }
}
