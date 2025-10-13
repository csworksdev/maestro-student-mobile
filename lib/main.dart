import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:maestro_client_mobile/providers/auth_provider.dart';
import 'package:maestro_client_mobile/providers/navigation_provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:maestro_client_mobile/providers/notification_provider.dart';
import 'package:maestro_client_mobile/providers/student_provider.dart';

import 'package:maestro_client_mobile/screens/dashboard_screen.dart';
import 'package:maestro_client_mobile/screens/schedule_screen.dart';
import 'package:maestro_client_mobile/screens/progress_screen.dart';
import 'package:maestro_client_mobile/screens/package_screen.dart';
import 'package:maestro_client_mobile/screens/notification_screen.dart';
import 'package:maestro_client_mobile/pages/login_page.dart';
import 'package:maestro_client_mobile/screens/settings_screen.dart';

import 'package:maestro_client_mobile/widgets/app_bar.dart';
import 'package:maestro_client_mobile/widgets/bottom_nav_bar.dart' as CustomWidgets;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:maestro_client_mobile/models/notification.dart';
import 'package:maestro_client_mobile/services/notification_service.dart';
import 'package:maestro_client_mobile/services/logger_service.dart';
import 'package:maestro_client_mobile/services/sound_service.dart';
import 'package:maestro_client_mobile/theme/app_theme.dart';

// Global navigator key for accessing navigator from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  
  // Pastikan title dan body tidak kosong
  String title = message.notification?.title ?? '';
  String body = message.notification?.body ?? '';
  
  // Jika title masih kosong, coba cari di data
  if (title.isEmpty && message.data.isNotEmpty) {
    title = message.data['title'] ?? '';
    body = body.isEmpty ? (message.data['body'] ?? '') : body;
    
    // Cek jika ada struktur notification di dalam data
    if (title.isEmpty && message.data['notification'] != null) {
      var notif = message.data['notification'];
      // Coba parse jika notif adalah string JSON
      if (notif is String) {
        try {
          var notifMap = jsonDecode(notif);
          title = notifMap['title'] ?? '';
          body = body.isEmpty ? (notifMap['body'] ?? '') : body;
        } catch (e) {
          // Error handling tanpa log
        }
      } else if (notif is Map) {
        title = notif['title'] ?? '';
        body = body.isEmpty ? (notif['body'] ?? '') : body;
      }
    }
  }
  
  // Jika masih kosong, gunakan default
  if (title.isEmpty) title = 'Notifikasi Baru';
  if (body.isEmpty) body = 'Anda menerima notifikasi baru';

  // Hanya simpan informasi yang diperlukan untuk notifikasi
  final notification = {
    'messageId': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
    'title': title,
    'body': body,
    'data': message.data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'isRead': false,
  };

  // Simpan ke shared preferences untuk notifikasi background
  // Ini akan digunakan untuk menampilkan notifikasi di daftar notifikasi
  final notificationService = NotificationService();
  await notificationService.saveNotificationToPrefs(notification);
  
  // Tidak perlu menyimpan data notifikasi untuk navigasi di sini
  // karena akan menyebabkan notifikasi ganda
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  
  // Register background handler BEFORE Firebase.initializeApp()
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  
  await Firebase.initializeApp();

  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Ambil token FCM saat aplikasi pertama kali dibuka
  await notificationService.getToken();

  // Mengatur opsi presentasi notifikasi foreground
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey, // Menggunakan navigatorKey global
          themeMode: themeProvider.themeMode,
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          locale: const Locale('id'),
          supportedLocales: const [
            Locale('id'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: authProvider.isLoggedIn ? MainScreen() : LoginPage(),
          routes: {
            '/MainScreen': (context) => MainScreen(),
            '/login': (context) => LoginPage(),
            '/settings': (context) => SettingsScreen(),
            '/notifications': (context) => NotificationScreen(),
          },
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _setupFCMToken();
  }
  
  Future<void> _setupFCMToken() async {
    try {
      debugPrint("Mencoba mendapatkan FCM token dari MainScreen...");
      final notificationService = NotificationService();
      final loggerService = LoggerService();
      
      // Dapatkan token dari NotificationService yang sudah dioptimalkan
      // Parameter forceRefresh=true untuk memastikan token diperbarui di versi release
      final fcmToken = await notificationService.getToken(forceRefresh: true);
      
      if (fcmToken == null || fcmToken.isEmpty) {
        loggerService.log(
          "FCM Token tidak tersedia", 
          tag: 'MainScreen',
          showNotification: false, // Tidak menampilkan notifikasi di versi release
          title: 'Error FCM Token',
        );
        return;
      }
      
      loggerService.log(
        "FCM Token berhasil didapatkan: ${fcmToken.substring(0, 10)}...", 
        tag: 'MainScreen'
      );
      
      // Dapatkan auth token dari provider
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isLoggedIn && authProvider.token != null) {
        // Kirim token ke server menggunakan auth token
        final success = await notificationService.sendTokenToApi(fcmToken, authProvider.token!);
        if (success) {
          loggerService.log(
            "FCM Token berhasil dikirim ke server", 
            tag: 'MainScreen',
            showNotification: false, // Tidak menampilkan notifikasi di versi release
            title: 'FCM Token Terkirim',
          );
        } else {
          loggerService.log(
            "Gagal mengirim FCM Token ke server", 
            tag: 'MainScreen',
            showNotification: false, // Tidak menampilkan notifikasi di versi release
            title: 'Error FCM Token',
          );
        }
      } else {
        // Simpan token untuk dikirim nanti setelah login
        loggerService.log(
          "FCM Token disimpan untuk dikirim setelah login", 
          tag: 'MainScreen'
        );
      }
    } catch (e) {
      final loggerService = LoggerService();
      loggerService.log(
        'Error umum Firebase Messaging: $e', 
        tag: 'MainScreen',
        showNotification: false, // Tidak menampilkan notifikasi di versi release
        title: 'Error FCM',
      );
    }
  }
  
  // Fungsi ini sudah tidak digunakan karena sudah digantikan dengan implementasi di NotificationService
  // Dihapus untuk menghindari kode yang tidak digunakan

  Future<void> _initializeNotifications() async {
    // Inisialisasi notifikasi
    final notificationService = NotificationService();
    await notificationService.initialize();
    
    // Cek apakah aplikasi dibuka dari notifikasi saat aplikasi tertutup
    final RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      debugPrint("Aplikasi dibuka dari notifikasi terminated: ${initialMessage.messageId}");

      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
      // Gunakan ID konsisten untuk mencegah duplikasi (pakai messageId FCM, fallback ke timestamp string)
      final String initialId = initialMessage.messageId ?? DateTime.now().millisecondsSinceEpoch.toString();
      // Ekstrak title/body dengan fallback ke data jika notification null (initialMessage)
      String imTitle = initialMessage.notification?.title ?? '';
      String imBody = initialMessage.notification?.body ?? '';
      if (imTitle.isEmpty && initialMessage.data.isNotEmpty) {
        imTitle = initialMessage.data['title'] ?? '';
        imBody = imBody.isEmpty ? (initialMessage.data['body'] ?? '') : imBody;
        if (imTitle.isEmpty && initialMessage.data['notification'] != null) {
          var notif = initialMessage.data['notification'];
          if (notif is String) {
            try {
              var notifMap = jsonDecode(notif);
              imTitle = notifMap['title'] ?? '';
              imBody = imBody.isEmpty ? (notifMap['body'] ?? '') : imBody;
            } catch (_) {}
          } else if (notif is Map) {
            imTitle = notif['title'] ?? '';
            imBody = imBody.isEmpty ? (notif['body'] ?? '') : imBody;
          }
        }
      }
      if (imTitle.isEmpty) imTitle = 'Notifikasi Baru';
      final notification = NotificationModel(
        id: initialId,
        title: imTitle,
        body: imBody,
        timestamp: DateTime.now(),
        data: initialMessage.data,
      );

      notificationProvider.addNotification(notification);
      
      // Pastikan navigasi ke dashboard (index 0)
      navigationProvider.currentIndex = 0;

      // Tidak menyimpan current_notification_data di sini untuk menghindari duplikasi di NotificationScreen
      notificationService.updateNotificationBadge(notificationProvider.unreadCount);

      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.of(context).pushNamedAndRemoveUntil('/MainScreen', (route) => false);
      });
    }

    await _loadBackgroundNotifications(ignoreMessageId: initialMessage?.messageId);

    // Konfigurasi Firebase Messaging untuk notifikasi saat aplikasi dibuka (foreground)
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("🔥 Foreground message diterima di siswa!");
      debugPrint("Title: ${message.notification?.title}");
      debugPrint("Body: ${message.notification?.body}");

      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      // Ekstrak title/body dengan fallback ke data jika notification null (foreground)
      String fgTitle = message.notification?.title ?? '';
      String fgBody = message.notification?.body ?? '';
      if (fgTitle.isEmpty && message.data.isNotEmpty) {
        fgTitle = message.data['title'] ?? '';
        fgBody = fgBody.isEmpty ? (message.data['body'] ?? '') : fgBody;
        if (fgTitle.isEmpty && message.data['notification'] != null) {
          var notif = message.data['notification'];
          if (notif is String) {
            try {
              var notifMap = jsonDecode(notif);
              fgTitle = notifMap['title'] ?? '';
              fgBody = fgBody.isEmpty ? (notifMap['body'] ?? '') : fgBody;
            } catch (_) {}
          } else if (notif is Map) {
            fgTitle = notif['title'] ?? '';
            fgBody = fgBody.isEmpty ? (notif['body'] ?? '') : fgBody;
          }
        }
      }
      if (fgTitle.isEmpty) fgTitle = 'Notifikasi Baru';
      final notification = NotificationModel(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: fgTitle,
        body: fgBody,
        timestamp: DateTime.now(),
        data: message.data,
      );

      notificationProvider.addNotification(notification);

      notificationService.updateNotificationBadge(notificationProvider.unreadCount);
      debugPrint("Badge diperbarui dengan ${notificationProvider.unreadCount} notifikasi belum dibaca (foreground)");

      // Putar suara notifikasi (tanpa await agar tidak blocking)
      try {
        SoundService().playNotificationSound().catchError((error) {
          debugPrint("Error playing notification sound: $error");
        });
      } catch (e) {
        debugPrint("Error initializing sound service: $e");
      }

      notificationService.showNotification(
        fgTitle,
        fgBody,
        payload: json.encode({
          'title': fgTitle,
          'body': fgBody,
          'data': message.data,
        }),
        notificationId: DateTime.now().millisecondsSinceEpoch.remainder(10000),
      );
    });

    // Konfigurasi untuk notifikasi saat aplikasi di background tapi masih berjalan
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notifikasi diklik: ${message.data}");

      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      final navigationProvider = Provider.of<NavigationProvider>(context, listen: false);
      // Ekstrak title/body dengan fallback ke data jika notification null (onMessageOpenedApp)
      String omTitle = message.notification?.title ?? '';
      String omBody = message.notification?.body ?? '';
      if (omTitle.isEmpty && message.data.isNotEmpty) {
        omTitle = message.data['title'] ?? '';
        omBody = omBody.isEmpty ? (message.data['body'] ?? '') : omBody;
        if (omTitle.isEmpty && message.data['notification'] != null) {
          var notif = message.data['notification'];
          if (notif is String) {
            try {
              var notifMap = jsonDecode(notif);
              omTitle = notifMap['title'] ?? '';
              omBody = omBody.isEmpty ? (notifMap['body'] ?? '') : omBody;
            } catch (_) {}
          } else if (notif is Map) {
            omTitle = notif['title'] ?? '';
            omBody = omBody.isEmpty ? (notif['body'] ?? '') : omBody;
          }
        }
      }
      if (omTitle.isEmpty) omTitle = 'Notifikasi Baru';
      final notification = NotificationModel(
        id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: omTitle,
        body: omBody,
        timestamp: DateTime.now(),
        data: message.data,
      );

      notificationProvider.addNotification(notification);

      notificationService.updateNotificationBadge(notificationProvider.unreadCount);
      debugPrint("Badge diperbarui dengan ${notificationProvider.unreadCount} notifikasi belum dibaca (onMessageOpenedApp)");

      // Mengatur indeks navigasi ke tab dashboard (indeks 0)
      navigationProvider.currentIndex = 0;
      
      // Navigasi ke MainScreen yang memiliki app bar dan bottom navbar dengan dashboard aktif
      Navigator.of(context).pushNamedAndRemoveUntil('/MainScreen', (route) => false);
    });
  }

  Future<void> _loadBackgroundNotifications({String? ignoreMessageId}) async {
    try {
      final notificationService = NotificationService();
      final backgroundNotifications = await notificationService.getNotificationsFromPrefs();

      if (backgroundNotifications.isNotEmpty) {
        print("Loaded ${backgroundNotifications.length} background notifications");

        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        for (var notification in backgroundNotifications) {
          // Skip the notification that opened the app to avoid duplicates
          if (ignoreMessageId != null && notification.id == ignoreMessageId) {
            continue;
          }
          final exists = notificationProvider.notifications.any((n) => n.id == notification.id);
          if (!exists) {
            notificationProvider.addNotification(notification);
          }
        }

        await notificationService.updateNotificationBadge(notificationProvider.unreadCount);
        print("Badge diperbarui dengan ${notificationProvider.unreadCount} notifikasi belum dibaca");
      }
    } catch (e) {
      print("Error loading background notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);

    final List<Widget> pages = [
      DashboardScreen(),
      ScheduleScreen(),
      ProgressScreen(),
      PackageScreen(),
      NotificationScreen(),
    ];

    return Scaffold(
      appBar: CustomAppBar(),
      body: pages[navProvider.currentIndex],
      bottomNavigationBar: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomWidgets.MainBottomNavBar(
            currentIndex: navProvider.currentIndex,
            onTap: (index) {
              // Jika tab notifikasi dipilih, tandai semua notifikasi sebagai dibaca
              if (index == 4) {
                // Perbarui badge notifikasi
                final notificationService = NotificationService();
                notificationService.updateNotificationBadge(0);
                
                // Jika ada notifikasi yang belum dibaca, tandai sebagai dibaca
                if (notificationProvider.unreadCount > 0) {
                }
              }
              
              navProvider.currentIndex = index;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}