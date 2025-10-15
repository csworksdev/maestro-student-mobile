import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:maestro_client_mobile/services/logger_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
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
  
  // Logger instance for release mode logging
  final LoggerService _logger = LoggerService();
  bool _initialized = false;
  
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('NotificationService sudah diinisialisasi, skip...');
      return;
    }

    // Initialize logger
    await _logger.initialize();
    _logger.log('Initializing NotificationService', tag: 'Notification');
    
    // Mencegah notifikasi otomatis FCM saat aplikasi di foreground
    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: false, // false, karena kita akan menanganinya secara manual
      badge: true,
      sound: false, // false, karena kita akan memutar suara dari notifikasi lokal
    );

    // Konfigurasi untuk Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    _logger.log('Android initialization settings configured', tag: 'Notification');

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
        
        // Simpan data notifikasi ke shared preferences jika payload tidak null
        if (response.payload != null) {
          try {
            Map<String, dynamic> payloadData = jsonDecode(response.payload!);
            saveNotificationDataForNavigation(payloadData);
          } catch (e) {
            print('Error parsing notification payload: $e');
          }
        }
        
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

    // Listener untuk notifikasi yang masuk saat aplikasi di foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground message received: ${message.notification?.title}");

      final notification = message.notification;

      // Jika payload FCM sudah memiliki blok notification, biarkan sistem OS yang menanganinya
      if (notification != null) {
        debugPrint(
          'Skip notifikasi lokal karena payload FCM sudah menyertakan notification.',
        );
        return;
      }

      // Tampilkan notifikasi lokal hanya untuk pesan data (tanpa blok notification)
      if (message.data.isNotEmpty) {
        final title = message.data['title'] ?? 'Notifikasi Baru';
        final body = message.data['body'] ?? 'Anda memiliki pesan baru.';

        showNotification(
          title,
          body,
          payload: jsonEncode(message.data),
        );
      }
    });

    // Buat channel notifikasi untuk Android
    await _createNotificationChannel();

    // Minta izin notifikasi
    await _requestPermissions();
    
    // Set flag initialized
    _initialized = true;
    debugPrint('✅ NotificationService berhasil diinisialisasi');
  }

  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'maestro_notification_v2', // id - ganti channel ID agar sound baru diterapkan
      'Notifikasi Penting', // title
      description: 'Channel untuk notifikasi penting dari Maestro Swim', // description
      importance: Importance.high,
      playSound: true,
      // Gunakan custom sound macox.mp3 dari folder raw
      sound: RawResourceAndroidNotificationSound('macox'),
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

    // Untuk Android 13+ (API level 33+), request POST_NOTIFICATIONS permission
    if (Platform.isAndroid) {
      try {
        // Check Android version
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;
        
        // Android 13 is API level 33
        if (sdkInt >= 33) {
          final status = await Permission.notification.status;
          if (status.isDenied) {
            await Permission.notification.request();
          }
        }
      } catch (e) {
        debugPrint('Error requesting notification permission: $e');
      }
    }
  }
  
  Future<void> showNotification(
    String title,
    String body, {
    String? payload,
    int notificationId = 0,
    bool highPriority = true,
    bool isServerNotification = true, // Default true karena biasanya notifikasi dari server
  }) async {
    // Pastikan payload berisi informasi yang diperlukan
    Map<String, dynamic> notificationData = {
      'title': title,
      'body': body,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    // Jika payload sudah ada, tambahkan ke data
    if (payload != null && payload.isNotEmpty) {
      try {
        Map<String, dynamic> payloadData = jsonDecode(payload);
        notificationData['data'] = payloadData;
      } catch (e) {
        print('Error parsing payload: $e');
        notificationData['rawPayload'] = payload;
      }
    }
    
    // Konversi data ke string JSON untuk payload
    String finalPayload = jsonEncode(notificationData);
    
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'maestro_notification_v2',
      'Notifikasi Penting',
      channelDescription: 'Channel untuk notifikasi penting dari Maestro Swim',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      // Gunakan custom sound macox.mp3 dari folder raw
      sound: RawResourceAndroidNotificationSound('macox'),
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
      payload: finalPayload,
    );
  }

  Future<String?> getToken({bool forceRefresh = false}) async {
    try {
      // Coba ambil token dari SharedPreferences terlebih dahulu jika tidak force refresh
      if (!forceRefresh) {
        final prefs = await SharedPreferences.getInstance();
        final savedToken = prefs.getString('fcm_token');
        
        // Jika token sudah ada di SharedPreferences, gunakan itu
        if (savedToken != null && savedToken.isNotEmpty) {
          _logger.log(
            'Menggunakan FCM Token dari SharedPreferences: ${savedToken.substring(0, 10)}...', 
            tag: 'Notification'
          );
          return savedToken;
        }
      }
      
      // Jika tidak ada token tersimpan atau force refresh, minta token baru
      String? token = await FirebaseMessaging.instance.getToken();
      print('FCM Token baru: $token');
      
      // Log token untuk debugging di release mode
      if (token != null && token.isNotEmpty) {
        _logger.log(
          'FCM Token baru diperoleh: ${token.substring(0, 10)}...', 
          tag: 'Notification',
          showNotification: false, // Tidak menampilkan notifikasi di versi release
          title: 'FCM Token',
        );
        
        // Simpan token ke shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
        await prefs.setString('fcm_token_timestamp', DateTime.now().toIso8601String());
        _logger.log('FCM Token baru disimpan ke SharedPreferences', tag: 'Notification');
        
        // Tambahkan listener untuk token refresh
        _setupTokenRefreshListener();
      } else {
        _logger.log(
          'FCM Token kosong atau null', 
          tag: 'Notification',
          showNotification: false, // Tidak menampilkan notifikasi di versi release
          title: 'Warning FCM Token',
        );
      }
      
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      _logger.log(
        'Error getting FCM token: $e', 
        tag: 'Notification',
        showNotification: false, // Tidak menampilkan notifikasi di versi release
        title: 'Error FCM Token',
      );
      return null; // Return null if there's an error
    }
  }
  
  // Setup listener untuk refresh token otomatis
  void _setupTokenRefreshListener() {
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) async {
      // Token diperbarui, simpan token baru
      print('FCM Token diperbarui: $token');
      _logger.log(
        'FCM Token diperbarui otomatis: ${token.substring(0, 10)}...', 
        tag: 'Notification'
      );
      
      // Simpan token baru ke SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      await prefs.setString('fcm_token_timestamp', DateTime.now().toIso8601String());
    }, onError: (e) {
      print('Error on token refresh: $e');
      _logger.log('Error on token refresh: $e', tag: 'Notification');
    });
  }
  
  // Mendapatkan token FCM dari SharedPreferences
  Future<String?> getSavedToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('fcm_token');
    } catch (e) {
      _logger.log('Error getting saved FCM token: $e', tag: 'Notification');
      return null;
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
  
  // Mengirim FCM token ke API
  Future<bool> sendTokenToApi(String fcmToken, String authToken) async {
    try {
      print('Sending FCM token to API: $fcmToken');
      print('Auth token: $authToken');
      
      // Menggunakan parameter sesuai permintaan tim backend
      final response = await http.post(
        Uri.parse('https://api.maestroswim.com/api/notifikasi/save-token/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'token': fcmToken,
          'device_type': 'mobile', // Menggunakan 'mobile' untuk aplikasi mobile
          'origin': 'maestro_client_mobile', // Hostname aplikasi mobile
        }),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Token berhasil dikirim ke API');
        // Simpan token ke shared preferences untuk penggunaan di masa mendatang
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', fcmToken);
        return true;
      } else {
        print('Gagal mengirim token ke API: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error mengirim token ke API: $e');
      return false;
    }
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

  // Menyimpan data notifikasi untuk navigasi
  Future<void> saveNotificationDataForNavigation(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Debug: Tampilkan data asli yang diterima
      print('Data asli yang diterima: $data');
      
      // Ekstrak title dan body dengan benar dari struktur notifikasi Firebase
      String title = '';
      String body = '';
      
      // Coba ambil dari berbagai kemungkinan struktur data
      if (data['notification'] != null) {
        title = data['notification']['title'] ?? '';
        body = data['notification']['body'] ?? '';
      } else if (data['title'] != null) {
        title = data['title'];
        body = data['body'] ?? '';
      } else if (data['data'] != null) {
        // Cek jika title ada di data
        if (data['data']['title'] != null) {
          title = data['data']['title'];
          body = data['data']['body'] ?? '';
        } 
        // Cek jika ada struktur notification di dalam data
        else if (data['data']['notification'] != null) {
          var notif = data['data']['notification'];
          // Coba parse jika notif adalah string JSON
          if (notif is String) {
            try {
              var notifMap = jsonDecode(notif);
              title = notifMap['title'] ?? '';
              body = notifMap['body'] ?? '';
            } catch (e) {
              print('Error parsing notification JSON: $e');
            }
          } else if (notif is Map) {
            title = notif['title'] ?? '';
            body = notif['body'] ?? '';
          }
        }
      }
      
      // Jika masih kosong, coba cari di tempat lain
      if (title.isEmpty && data.containsKey('aps')) {
        if (data['aps'] is Map && data['aps']['alert'] is Map) {
          title = data['aps']['alert']['title'] ?? '';
          body = data['aps']['alert']['body'] ?? '';
        }
      }
      
      // Jika payload berisi data JSON, coba ekstrak title dan body dari sana
      if (title.isEmpty && data['payload'] != null) {
        try {
          var payload = data['payload'];
          if (payload is String) {
            var payloadMap = jsonDecode(payload);
            title = payloadMap['title'] ?? '';
            body = payloadMap['body'] ?? '';
          } else if (payload is Map) {
            title = payload['title'] ?? '';
            body = payload['body'] ?? '';
          }
        } catch (e) {
          print('Error parsing payload: $e');
        }
      }
      
      // Pastikan data memiliki format yang benar untuk NotificationModel
      Map<String, dynamic> notificationData = {
        'messageId': data['messageId'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'title': title.isNotEmpty ? title : 'Notifikasi Baru',
        'body': body.isNotEmpty ? body : 'Anda menerima notifikasi baru',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'data': data['data']
      };
      
      print('Data notifikasi yang akan disimpan: $notificationData');
      
      await prefs.setString('current_notification_data', jsonEncode(notificationData));
      print('Data notifikasi disimpan untuk navigasi: $notificationData');
    } catch (e) {
      print('Error menyimpan data notifikasi untuk navigasi: $e');
    }
  }
  
  // Mengambil data notifikasi untuk navigasi
  Future<Map<String, dynamic>?> getNotificationDataForNavigation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString('current_notification_data');
      if (data != null && data.isNotEmpty) {
        // Hapus data setelah diambil
        await prefs.remove('current_notification_data');
        return jsonDecode(data);
      }
      return null;
    } catch (e) {
      print('Error mengambil data notifikasi untuk navigasi: $e');
      return null;
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