import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/models/notification.dart';
import 'package:maestro_client_mobile/providers/notification_provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:maestro_client_mobile/services/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);
  
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> 
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    _fadeController.forward();
    
    // Update badge when notification page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateBadge();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  void _updateBadge() {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final notificationService = NotificationService();
    notificationService.updateNotificationBadge(notificationProvider.unreadCount);
  }
  
  // Function to refresh notifications
  Future<void> _refreshNotifications() async {
    setState(() {
      _isLoading = true;
    });
    
    // Sort notifications: unread first, then read
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    notificationProvider.sortNotificationsByReadStatus();
    
    await Future.delayed(const Duration(milliseconds: 1000));
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final notifications = notificationProvider.notifications;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? const Color(0xFF0F0F0F) : const Color(0xFFFAFAFA),
        title: Text(
          'Notifikasi',
          style: GoogleFonts.nunito(
            color: isDarkMode ? Colors.white : Colors.black,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        actions: [
          if (notifications.isNotEmpty) ...[
            _buildActionButton(
              icon: Icons.mark_email_read_outlined,
              tooltip: 'Tandai semua sudah dibaca',
              onPressed: () => _markAllAsRead(context, notificationProvider, isDarkMode),
            ),
            _buildActionButton(
              icon: Icons.delete_sweep_outlined,
              tooltip: 'Hapus semua notifikasi',
              onPressed: () => _showDeleteAllDialog(context, notificationProvider, isDarkMode),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshNotifications,
        color: const Color(0xFF0066A6),
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          
          // Notification Stats Card
          if (notifications.isNotEmpty)
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildStatsCard(context, notificationProvider, isDarkMode),
                ),
              ),
            ),
          
          // Notifications List or Empty State
          _isLoading
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      ],
                    ),
                  ),
                )
              : notifications.isEmpty
                  ? SliverFillRemaining(
                      child: _buildEmptyState(isDarkMode),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final notification = notifications[index];
                            return _buildNotificationCard(
                              context, 
                              notification, 
                              index, 
                              isDarkMode,
                              notificationProvider,
                            );
                          },
                          childCount: notifications.length,
                        ),
                      ),
                    ),
        ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 22,
          color: Colors.grey[600],
        ),
        onPressed: onPressed,
        tooltip: tooltip,
        splashRadius: 20,
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, NotificationProvider provider, bool isDarkMode) {
    final unreadCount = provider.unreadCount;
    final totalCount = provider.notifications.length;
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDarkMode 
              ? [const Color(0xFF1A1A1A), const Color(0xFF2A2A2A)]
              : [Colors.white, const Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [const Color.fromARGB(240, 0, 53, 102), const Color.fromARGB(240, 0, 53, 102)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$totalCount Notifikasi',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unreadCount > 0 
                      ? '$unreadCount belum dibaca'
                      : 'Semua sudah dibaca',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: unreadCount > 0 
                        ? const Color.fromARGB(240, 0, 53, 102)
                        : Colors.green[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: isDarkMode 
                      ? const Color(0xFF1A1A1A)
                      : const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: isDarkMode 
                          ? Colors.black.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.notifications_off_outlined,
                  size: 50,
                  color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Tidak ada notifikasi',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda akan menerima notifikasi di sini',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    NotificationModel notification,
    int index,
    bool isDarkMode,
    NotificationProvider provider,
  ) {
    final itemAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.1 * index.clamp(0, 9),
        0.8 + 0.1 * index.clamp(0, 4),
        curve: Curves.easeOutCubic,
      ),
    ));

    return SlideTransition(
      position: itemAnimation,
      child: FadeTransition(
        opacity: _animationController,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Dismissible(
            key: Key(notification.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[400]!, Colors.red[600]!],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            onDismissed: (direction) {
              provider.removeNotification(notification.id);
              final notificationService = NotificationService();
              notificationService.updateNotificationBadge(provider.unreadCount);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Notifikasi dihapus',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: Colors.red[400],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _showNotificationDetail(context, notification, provider, isDarkMode),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: notification.isRead
                        ? isDarkMode
                            ? const Color(0xFF1A1A1A)
                            : Colors.white
                        : isDarkMode
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(16),
                    border: notification.isRead
                        ? null
                        : Border.all(
                            color: const Color.fromARGB(240, 0, 53, 102).withValues(alpha: 0.3),
                            width: 1,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.black.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.08),
                        spreadRadius: 0,
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Notification Icon
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: notification.isRead
                                ? [Colors.grey[400]!, Colors.grey[600]!]
                                : [const Color.fromARGB(240, 0, 53, 102), const Color.fromARGB(240, 0, 53, 102)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Notification Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    style: GoogleFonts.inter(
                                      fontWeight: notification.isRead
                                          ? FontWeight.w600
                                          : FontWeight.w700,
                                      fontSize: 15,
                                      color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                if (!notification.isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: const Color.fromARGB(240, 0, 53, 102),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              notification.body,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatTimestamp(notification.timestamp),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 0) {
      return DateFormat('dd MMM yyyy').format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  void _markAllAsRead(BuildContext context, NotificationProvider provider, bool isDarkMode) {
    provider.markAllAsRead();
    final notificationService = NotificationService();
    notificationService.updateNotificationBadge(0);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Semua notifikasi telah dibaca',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeleteAllDialog(BuildContext context, NotificationProvider provider, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Hapus Semua Notifikasi',
          style: GoogleFonts.inter(
            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus semua notifikasi?',
          style: GoogleFonts.inter(
            color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
            fontSize: 14,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: GoogleFonts.inter(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.clearNotifications();
              final notificationService = NotificationService();
              notificationService.updateNotificationBadge(0);
              
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Semua notifikasi telah dihapus',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: Colors.green[600],
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.inter(
                color: Colors.red[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetail(
    BuildContext context,
    NotificationModel notification,
    NotificationProvider provider,
    bool isDarkMode,
  ) {
    if (!notification.isRead) {
      provider.markAsRead(notification.id);
      final notificationService = NotificationService();
      notificationService.updateNotificationBadge(provider.unreadCount);
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          notification.title,
          style: GoogleFonts.inter(
            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.body,
              style: GoogleFonts.inter(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _formatTimestamp(notification.timestamp),
              style: GoogleFonts.inter(
                color: isDarkMode ? Colors.grey[500] : Colors.grey[500],
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tutup',
              style: GoogleFonts.inter(
                color: const Color(0xFF0066A6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}