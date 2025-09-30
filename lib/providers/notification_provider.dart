import 'package:flutter/material.dart';
import 'package:maestro_client_mobile/models/notification.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  int _unreadCount = 0;

  List<NotificationModel> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification); // Add to the beginning of the list
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }

  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      
      // Sort notifications after marking as read
      sortNotificationsByReadStatus();
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    _unreadCount = 0;
    
    // Sort notifications after marking all as read
    sortNotificationsByReadStatus();
  }

  void removeNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      if (!_notifications[index].isRead) {
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      }
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  void clearNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  void sortNotificationsByReadStatus() {
    // Sort notifications: unread first (isRead: false), then read (isRead: true)
    // Within each group, sort by timestamp (newest first)
    _notifications.sort((a, b) {
      // First sort by read status (unread first)
      if (a.isRead != b.isRead) {
        return a.isRead ? 1 : -1; // false (unread) comes before true (read)
      }
      // If read status is the same, sort by timestamp (newest first)
      return b.timestamp.compareTo(a.timestamp);
    });
    notifyListeners();
  }
}