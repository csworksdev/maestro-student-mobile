import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:maestro_client_mobile/providers/notification_provider.dart';
import 'package:maestro_client_mobile/models/notification.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:maestro_client_mobile/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Definisi warna tema
  final Color navyColor = const Color(0xFF044366);
  final Color orangeColor = const Color(0xFFEE7D21);
  
  @override
  void initState() {
    super.initState();
    // Tidak menandai semua notifikasi sebagai sudah dibaca saat halaman dibuka
    // Hanya memperbarui badge notifikasi
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      
      // Periksa apakah ada data notifikasi yang disimpan dari notifikasi background
      await notificationProvider.checkAndLoadSavedNotification();
      
      notificationProvider.updateNotificationBadge();
    });
  }

  Future<void> _handleRefresh() async {
    final notificationService = NotificationService();
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    int added = 0;

    try {
      // Ambil notifikasi yang disimpan saat background (dinormalisasi oleh NotificationService)
      final backgroundNotifications = await notificationService.getNotificationsFromPrefs();
      if (backgroundNotifications.isNotEmpty) {
        for (var n in backgroundNotifications) {
          final exists = notificationProvider.notifications.any((x) => x.id == n.id);
          if (!exists) {
            notificationProvider.addNotification(n);
            added++;
          }
        }
      }

      // Muat data navigasi yang tersimpan jika ada (sekali pakai)
      await notificationProvider.checkAndLoadSavedNotification();

      // Perbarui badge
      await notificationService.updateNotificationBadge(notificationProvider.unreadCount);

      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(added > 0 ? '$added notifikasi baru' : 'Tidak ada notifikasi terbaru'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat notifikasi'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
  
  @override
  void dispose() {
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final notifications = notificationProvider.notifications;
    
    // Warna tema
    final Color navyColor = const Color(0xFF044366);
    final Color orangeColor = const Color(0xFFEE7D21);
    final Color whiteColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final Color backgroundColor = isDarkMode ? const Color(0xFF121212) : Colors.white;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        centerTitle: true,
        actions: [
          if (notifications.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.delete_sweep_rounded,
                  color: Color.fromRGBO(211, 47, 47, 1),
                ),
                onPressed: () {
                  _showClearConfirmationDialog(context, navyColor, orangeColor);
                },
                tooltip: 'Hapus Semua Notifikasi',
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: orangeColor,
        backgroundColor: Colors.white,
        child: notifications.isEmpty
            ? LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: _buildEmptyState(isDarkMode, navyColor, orangeColor),
                        ),
                      ),
                    ),
                  );
                },
              )
            : _buildNotificationList(
                notifications,
                isDarkMode,
                navyColor,
                orangeColor,
                whiteColor,
              ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode, Color navyColor, Color orangeColor) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 245, 245, 245),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: const Color.fromARGB(255, 200, 200, 200),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Belum ada notifikasi',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color.fromARGB(158, 0, 0, 0),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Anda akan menerima notifikasi di sini',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNotificationList(List<NotificationModel> notifications, bool isDarkMode, Color navyColor, Color orangeColor, Color whiteColor) {
    // Mengurutkan notifikasi: belum dibaca di atas, lalu berdasarkan waktu terkini
    final sortedNotifications = [...notifications];
    sortedNotifications.sort((a, b) {
      // Pertama urutkan berdasarkan status baca
      if (a.isRead != b.isRead) {
        return a.isRead ? 1 : -1; // Yang belum dibaca di atas
      }
      // Kemudian urutkan berdasarkan waktu (terkini di atas)
      return b.timestamp.compareTo(a.timestamp);
    });
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: sortedNotifications.length,
      itemBuilder: (context, index) {
        final notification = sortedNotifications[index];
        
        return Dismissible(
                  key: Key(notification.id),
                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red.shade700,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete_rounded,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    Provider.of<NotificationProvider>(context, listen: false)
                        .removeNotification(notification.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Notifikasi dihapus',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: 'OK',
                          textColor: Colors.white,
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: _buildNotificationItem(notification, isDarkMode, navyColor, orangeColor, whiteColor),
                );
          },
        );
  }

  Widget _buildNotificationItem(NotificationModel notification, bool isDarkMode, Color navyColor, Color orangeColor, Color whiteColor) {
    final formattedDate = _formatDate(notification.timestamp);
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black12 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: notification.isRead 
            ? null 
            : Border.all(color: navyColor, width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // Menampilkan detail notifikasi dan menandai sebagai sudah dibaca
            Provider.of<NotificationProvider>(context, listen: false)
                .markAsRead(notification.id);
            _showNotificationDetails(context, notification, navyColor, orangeColor);
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon notifikasi
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: notification.isRead 
                        ? (isDarkMode ? navyColor.withOpacity(0.1) : orangeColor.withOpacity(0.1))
                        : orangeColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.notifications_rounded,
                        color: notification.isRead ? navyColor : navyColor,
                        size: 26,
                      ),
                      if (!notification.isRead)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: orangeColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: whiteColor, width: 1.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Konten notifikasi
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w600,
                          color: navyColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.access_time_rounded, size: 12, color: navyColor),
                                const SizedBox(width: 4),
                                Text(
                                  formattedDate,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: navyColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: navyColor.withOpacity(0.5),
                          ),
                        ],
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

  void _showNotificationDetails(BuildContext context, NotificationModel notification, Color navyColor, Color orangeColor) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final whiteColor = isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFFFFFFF);
    
    // Menandai notifikasi sebagai sudah dibaca
    notificationProvider.markAsRead(notification.id);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: navyColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.notifications_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  notification.title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: orangeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: orangeColor.withOpacity(0.3)),
                ),
                child: Text(
                  notification.body,
                  style: GoogleFonts.poppins(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: navyColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: navyColor),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(notification.timestamp),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: navyColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: orangeColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmationDialog(BuildContext context, Color navyColor, Color orangeColor) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    final whiteColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: EdgeInsets.zero,
        title: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: navyColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.delete_sweep_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Hapus Semua Notifikasi',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        content: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: orangeColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: orangeColor.withOpacity(0.3)),
          ),
          child: Text(
            'Apakah Anda yakin ingin menghapus semua notifikasi?',
            style: GoogleFonts.poppins(
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Batal',
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 8),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Text(
                      'Hapus',
                      style: GoogleFonts.poppins(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
                  notificationProvider.clearAllNotifications();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            'Semua notifikasi telah dihapus',
                            style: GoogleFonts.poppins(),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hari ini, ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return 'Kemarin, ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    }
  }
}