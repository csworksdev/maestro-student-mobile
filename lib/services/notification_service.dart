import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:maestro_client_mobile/models/notification.dart';
import 'package:maestro_client_mobile/providers/navigation_provider.dart';

// Global navigator key untuk navigasi dari luar context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = 
      FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();
  
  Future<void> initialize() async {
    // Konfigurasi untuk Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // Konfigurasi untuk iOS
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notifikasi yang diklik
        print('Notification clicked: ${response.payload}');
        
        // Navigasi ke halaman dashboard
        if (navigatorKey.currentContext != null) {
          // Navigasi ke MainScreen (halaman utama dengan dashboard)
          Navigator.pushNamedAndRemoveUntil(
            navigatorKey.currentContext!,
            '/MainScreen',
            (route) => false,
          );
          
          // Pastikan tab yang aktif adalah dashboard (index 0)
          Future.delayed(Duration(milliseconds: 300), () {
            if (navigatorKey.currentContext != null) {
              final navProvider = Provider.of<NavigationProvider>(
                navigatorKey.currentContext!, 
                listen: false
              );
              navProvider.currentIndex = 0; // Tab dashboard (sesuai dengan posisi di bottom navbar)
            }
          });
        }
      },
    );

    // Buat channel notifikasi untuk Android
    await _createNotificationChannel();

    // Minta izin notifikasi
    await _requestPermissions();
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'Notifikasi Penting', // title
      description: 'Channel untuk notifikasi penting dari Maestro Swim', // description
      importance: Importance.high,
      playSound: true,
      // Gunakan default sound system jika file notification_sound bermasalah
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableLights: true,
      ledColor: Color.fromARGB(255, 255, 255, 255),
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  Future<void> _requestPermissions() async {
    // Untuk iOS
    await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Untuk Android - tidak perlu requestPermission karena tidak tersedia di versi ini
    // Izin notifikasi Android diatur melalui AndroidManifest.xml
  }
  
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int notificationId = 0,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'Notifikasi Penting',
      channelDescription: 'Channel untuk notifikasi penting dari Maestro Swim',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      // Gunakan default sound system jika file notification_sound bermasalah
      // sound: RawResourceAndroidNotificationSound('notification_sound'),
      color: Color(0xFFFFFFFF), // Warna putih
      colorized: true, // Mengaktifkan pewarnaan notifikasi
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      notificationId, // ID notifikasi
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null; // Return null if there's an error
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
  
  // Menyimpan notifikasi ke shared preferences
  Future<void> saveNotificationToPrefs(Map<String, dynamic> notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String notificationsJson = prefs.getString('background_notifications') ?? '[]';
      List<dynamic> notifications = jsonDecode(notificationsJson);
      
      // Tambahkan notifikasi baru ke daftar
      notifications.add(notification);
      
      // Simpan kembali ke shared preferences
      await prefs.setString('background_notifications', jsonEncode(notifications));
      print('Notifikasi disimpan ke shared preferences');
    } catch (e) {
      print('Error menyimpan notifikasi: $e');
    }
  }
  
  // Mengambil notifikasi dari shared preferences
  Future<List<NotificationModel>> getNotificationsFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String notificationsJson = prefs.getString('background_notifications') ?? '[]';
      List<dynamic> notifications = jsonDecode(notificationsJson);
      
      // Konversi ke NotificationModel
      List<NotificationModel> result = notifications.map((notif) => 
        NotificationModel.fromFirebaseMessage({
          'messageId': notif['messageId'],
          'notification': {
            'title': notif['title'],
            'body': notif['body'],
          },
          'data': notif['data'],
        })
      ).toList();
      
      // Hapus notifikasi dari shared preferences setelah diambil
      await prefs.setString('background_notifications', '[]');
      
      return result;
    } catch (e) {
      print('Error mengambil notifikasi: $e');
      return [];
    }
  }

  // Fungsi untuk mengirim notifikasi test (hanya untuk pengujian)
  // Metode untuk memperbarui badge notifikasi
  Future<void> updateNotificationBadge(int count) async {
    try {
      // Untuk iOS, badge akan diperbarui secara otomatis
      // Untuk Android, badge dikelola oleh sistem notifikasi
      print('Notification badge updated: $count');
    } catch (e) {
      print('Error updating notification badge: $e');
    }
  }
  
  Future<bool> sendTestNotification(String token) async {
    try {
      // Catatan: Ini hanya untuk pengujian, dalam produksi seharusnya menggunakan server backend
      // Kunci server Firebase seharusnya tidak disimpan di aplikasi klien
      const String serverKey = 'YOUR_SERVER_KEY'; // Ganti dengan kunci server Firebase Anda
      const String fcmUrl = 'https://fcm.googleapis.com/fcm/send';

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      };

      final data = {
        'notification': {
          'title': 'Notifikasi Test',
          'body': 'Ini adalah notifikasi test dari aplikasi Maestro Swim',
        },
        'priority': 'high',
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'type': 'test',
          'message': 'Test message data',
        },
        'to': token,
      };

      final response = await http.post(
        Uri.parse(fcmUrl),
        headers: headers,
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == 1) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }
}