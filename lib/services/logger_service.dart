import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
/// A custom logger service that provides alternative logging methods for release mode
class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  factory LoggerService() {
    return _instance;
  }

  LoggerService._internal();

  /// Initialize the logger service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize local notifications for debug notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(initializationSettings);
    
    // Create debug notification channel
    await _createNotificationChannel();
    
    _initialized = true;
  }

  /// Create notification channel for debug notifications
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'debug_channel',
      'Debug Notifications',
      description: 'This channel is used for important debug notifications',
      importance: Importance.high,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Log a message with optional notification in release mode
  void log(String message, {
    bool showNotification = false,
    String title = 'Debug Info',
    bool saveToStorage = false,
    String? tag,
    bool isServerNotification = false,
  }) {
    // Always use debugPrint in debug mode
    if (kDebugMode) {
      debugPrint('${tag != null ? '[$tag] ' : ''}$message');
      
      // Show notification in debug mode if requested
      if (showNotification) {
        _showDebugNotification(title, message);
      }
      
      // Save to storage if requested
      if (saveToStorage) {
        _saveLogToStorage(message, tag: tag);
      }
      
      return;
    }
    
    // In release mode, use alternative logging methods
    _releaseLog(message, tag: tag);
    
    // In release mode, only show notifications from server, not technical notifications
    if (showNotification && isServerNotification) {
      _showDebugNotification(title, message);
    }
    
    // Save to storage if requested
    if (saveToStorage) {
      _saveLogToStorage(message, tag: tag);
    }
  }
  
  /// Log specifically for Firebase messaging events
  void logFCM(String message, {bool showNotification = true}) {
    log(message, tag: 'FCM', showNotification: showNotification, title: 'Firebase Message');
  }

  /// Alternative logging method for release mode
  void _releaseLog(String message, {String? tag}) {
    // Use print instead of debugPrint in release mode
    // This will be stripped in release mode by Flutter, but we include it anyway
    print('${tag != null ? '[$tag] ' : ''}$message');
    
    // You could implement additional logging here, such as:
    // - Writing to a file
    // - Sending to a remote logging service
  }

  /// Show a local notification with debug information
  Future<void> _showDebugNotification(String title, String body) async {
    if (!_initialized) await initialize();
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'debug_channel',
      'Debug Notifications',
      channelDescription: 'This channel is used for important debug notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformDetails,
    );
  }

  /// Save log to persistent storage
  Future<void> _saveLogToStorage(String message, {String? tag}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logs = prefs.getStringList('debug_logs') ?? [];
      
      // Add timestamp to log
      final timestamp = DateTime.now().toString();
      final formattedLog = '[$timestamp]${tag != null ? ' [$tag]' : ''} $message';
      
      // Add to beginning of list (most recent first)
      logs.insert(0, formattedLog);
      
      // Limit log size to prevent excessive storage use
      if (logs.length > 100) {
        logs.removeRange(100, logs.length);
      }
      
      await prefs.setStringList('debug_logs', logs);
    } catch (e) {
      // Fallback to print if storage fails
      print('Failed to save log: $e');
    }
  }

  /// Retrieve saved logs
  Future<List<String>> getSavedLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList('debug_logs') ?? [];
    } catch (e) {
      print('Failed to retrieve logs: $e');
      return [];
    }
  }

  /// Clear saved logs
  Future<void> clearSavedLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('debug_logs');
    } catch (e) {
      print('Failed to clear logs: $e');
    }
  }
}