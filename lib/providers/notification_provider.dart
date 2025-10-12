import 'package:flutter/material.dart';
import 'package:maestro_client_mobile/models/notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  NotificationProvider() {
    _loadNotifications();
  }

  // Menambahkan notifikasi baru
  void addNotification(NotificationModel notification) {
    // Cek apakah notifikasi dengan ID yang sama sudah ada
    final existingIndex = _notifications.indexWhere((n) => n.id == notification.id);
    
    if (existingIndex >= 0) {
      // Update notifikasi yang sudah ada
      _notifications[existingIndex] = notification;
    } else {
      // Tambahkan notifikasi baru di awal list
      _notifications.insert(0, notification);
      if (!notification.isRead) {
        _unreadCount++;
      }
    }
    
    _saveNotifications();
    notifyListeners();
  }

  // Menandai notifikasi sebagai sudah dibaca
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      final notification = _notifications[index];
      if (!notification.isRead) {
        _notifications[index] = notification.copyWith(isRead: true);
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
        _saveNotifications();
        notifyListeners();
      }
    }
  }

  // Menandai semua notifikasi sebagai sudah dibaca
  void markAllAsRead() {
    bool hasChanges = false;
    
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      _unreadCount = 0;
      _saveNotifications();
      notifyListeners();
    }
  }

  // Menghapus notifikasi
  void removeNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index >= 0) {
      final notification = _notifications[index];
      _notifications.removeAt(index);
      
      if (!notification.isRead) {
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      }
      
      _saveNotifications();
      notifyListeners();
    }
  }

  // Menghapus semua notifikasi
  void clearAllNotifications() {
    if (_notifications.isNotEmpty) {
      _notifications.clear();
      _unreadCount = 0;
      _saveNotifications();
      notifyListeners();
    }
  }

  // Menyimpan notifikasi ke SharedPreferences
  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> notificationsMap = _notifications.map((notification) => {
        'id': notification.id,
        'title': notification.title,
        'body': notification.body,
        'timestamp': notification.timestamp.toIso8601String(),
        'isRead': notification.isRead,
        'data': notification.data,
      }).toList();
      
      await prefs.setString('notifications', jsonEncode(notificationsMap));
    } catch (e) {
      debugPrint('Error menyimpan notifikasi: $e');
    }
  }

  // Memuat notifikasi dari SharedPreferences
  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? notificationsJson = prefs.getString('notifications');
      
      if (notificationsJson != null && notificationsJson.isNotEmpty) {
        final List<dynamic> notificationsMap = jsonDecode(notificationsJson);
        
        _notifications.clear();
        _unreadCount = 0;
        
        for (var notificationMap in notificationsMap) {
          final notification = NotificationModel(
            id: notificationMap['id'],
            title: notificationMap['title'],
            body: notificationMap['body'],
            timestamp: DateTime.parse(notificationMap['timestamp']),
            isRead: notificationMap['isRead'] ?? false,
            data: notificationMap['data'],
          );
          
          _notifications.add(notification);
          
          if (!notification.isRead) {
            _unreadCount++;
          }
        }
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error memuat notifikasi: $e');
    }
  }

  // Memperbarui badge notifikasi
  void updateNotificationBadge() {
    notifyListeners();
  }
  
  // Memeriksa dan memuat notifikasi yang disimpan dari notifikasi background
  Future<void> checkAndLoadSavedNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('current_notification_data');
      
      if (data != null && data.isNotEmpty) {
        // Hapus data setelah diambil untuk mencegah duplikasi
        await prefs.remove('current_notification_data');
        
        final Map<String, dynamic> notificationData = jsonDecode(data);
        print('Data notifikasi yang dimuat: $notificationData');
        
        // Buat ID unik untuk notifikasi
        String notificationId = notificationData['messageId'] ?? 
                               DateTime.now().millisecondsSinceEpoch.toString();
        
        // Periksa apakah notifikasi dengan ID yang sama sudah ada
        final existingIndex = _notifications.indexWhere((n) => n.id == notificationId);
        if (existingIndex >= 0) {
          print('Notifikasi dengan ID $notificationId sudah ada, tidak menambahkan duplikat');
          return;
        }
        
        // Pastikan title dan body tidak kosong
        String title = notificationData['title'] ?? '';
        String body = notificationData['body'] ?? '';
        
        // Jika title masih kosong, coba cari di data
        if (title.isEmpty && notificationData['data'] != null) {
          if (notificationData['data'] is Map) {
            title = notificationData['data']['title'] ?? '';
            body = body.isEmpty ? (notificationData['data']['body'] ?? '') : body;
          }
        }
        
        // Jika masih kosong, gunakan default
        if (title.isEmpty) title = 'Notifikasi Baru';
        if (body.isEmpty) body = 'Anda menerima notifikasi baru';
        
        // Buat objek NotificationModel dari data yang disimpan
        final notification = NotificationModel(
          id: notificationId,
          title: title,
          body: body,
          timestamp: DateTime.fromMillisecondsSinceEpoch(
            notificationData['timestamp'] ?? DateTime.now().millisecondsSinceEpoch
          ),
          data: notificationData['data'],
        );
        
        print('Menambahkan notifikasi baru: ${notification.title} - ${notification.body}');
        
        // Tambahkan notifikasi ke daftar
        _notifications.insert(0, notification);
        if (!notification.isRead) {
          _unreadCount++;
        }
        
        _saveNotifications();
        notifyListeners();
      }
    } catch (e) {
      print('Error saat memuat notifikasi yang disimpan: $e');
    }
  }
}