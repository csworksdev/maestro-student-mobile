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

import 'package:maestro_client_mobile/screens/dashboard_screen.dart';
import 'package:maestro_client_mobile/screens/profile_screen.dart';
import 'package:maestro_client_mobile/screens/settings_screen.dart';
import 'package:maestro_client_mobile/screens/menu_screen.dart';
import 'package:maestro_client_mobile/screens/notification_screen.dart';
import 'package:maestro_client_mobile/pages/login_page.dart';

import 'package:maestro_client_mobile/widgets/app_bar.dart';
import 'package:maestro_client_mobile/widgets/bottom_nav_bar.dart' as CustomWidgets;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:maestro_client_mobile/models/notification.dart';
import 'package:maestro_client_mobile/services/notification_service.dart';
import 'package:maestro_client_mobile/services/api_service.dart';

@pragma("vm:entry-point")
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Pesan diterima di background: ${message.messageId}");
  debugPrint("Background message data: ${message.data}");
  debugPrint("Background message notification: ${message.notification?.title} - ${message.notification?.body}");

  final notification = {
    'messageId': message.messageId,
    'title': message.notification?.title,
    'body': message.notification?.body,
    'data': message.data,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'isRead': false,
  };

  debugPrint("Background notification data: $notification");

  final notificationService = NotificationService();
  await notificationService.saveNotificationToPrefs(notification);

  debugPrint("Background message saved to shared preferences");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await Firebase.initializeApp();

  final notificationService = NotificationService();
  await notificationService.initialize();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
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
          themeMode: themeProvider.themeMode,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF0F0F0F),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF0F0F0F),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            cardColor: const Color(0xFF1A1A1A),
            dividerColor: const Color(0xFF2A2A2A),
            primaryColor: const Color.fromARGB(240, 0, 53, 102),
            colorScheme: const ColorScheme.dark(
              primary: Color.fromARGB(240, 0, 53, 102),
              secondary: Color.fromARGB(240, 0, 53, 102),
              surface: Color(0xFF1A1A1A),
              background: Color(0xFF0F0F0F),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.white,
              onBackground: Colors.white,
            ),
          ),
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

    try {
      debugPrint("Mencoba mendapatkan FCM token...");
      FirebaseMessaging.instance.getToken(
        vapidKey: "BBpYnY0UFcX2KhZWVQaWytwVlRqSLTwAhKQEfkuVnCKQBjymJRo6IeifLov-A8OvkhhM_yiPJO8I1vZaypxWjG8",
      ).then((token) async {
        if (token == null) {
          debugPrint("FCM Token tidak tersedia");
          return;
        }

        debugPrint("FCM Token berhasil didapatkan: $token");

        try {
          debugPrint("Mengirim FCM token ke server...");
          final apiClient = ApiClient();
          final response = await apiClient.post(
            'notifikasi/save-token/',
            body: {
              'token': token,
              'device_type': 'mobile',
              'origin': 'https://client.maestroswim.com/',
            },
          );

          if (response.statusCode >= 200 && response.statusCode < 300) {
            debugPrint('FCM token berhasil dikirim ke server! Status: ${response.statusCode}');
          } else {
            debugPrint('Gagal mengirim FCM token ke server. Status: ${response.statusCode} - ${response.body}');
          }
        } catch (e) {
          debugPrint('Error mengirim FCM token: $e');
        }
        setState(() {});
      }).catchError((error) {
        debugPrint('Error mendapatkan FCM token: $error');
      });
    } catch (e) {
      debugPrint('Error umum Firebase Messaging: $e');
    }
  }

  Future<void> _initializeNotifications() async {
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint("Aplikasi dibuka dari notifikasi terminated: ${message.messageId}");

        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        final notification = NotificationModel.fromFirebaseMessage({
          'messageId': message.messageId,
          'notification': {
            'title': message.notification?.title,
            'body': message.notification?.body,
          },
          'data': message.data,
        });

        notificationProvider.addNotification(notification);

        final notificationService = NotificationService();
        notificationService.updateNotificationBadge(notificationProvider.unreadCount);

        Future.delayed(Duration(milliseconds: 500), () {
          Navigator.of(context).pushNamed('/notifications');
        });
      }
    });

    await _loadBackgroundNotifications();

    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint("Notifikasi foreground: ${message.notification?.title}");

      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      final notification = NotificationModel.fromFirebaseMessage({
        'messageId': message.messageId,
        'notification': {
          'title': message.notification?.title,
          'body': message.notification?.body,
        },
        'data': message.data,
      });

      notificationProvider.addNotification(notification);

      final notificationService = NotificationService();
      notificationService.updateNotificationBadge(notificationProvider.unreadCount);
      debugPrint("Badge diperbarui dengan ${notificationProvider.unreadCount} notifikasi belum dibaca (foreground)");

      notificationService.showLocalNotification(
        title: message.notification?.title ?? "Notifikasi",
        body: message.notification?.body ?? "",
        payload: json.encode(message.data),
        notificationId: DateTime.now().millisecondsSinceEpoch.remainder(10000),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notifikasi diklik: ${message.data}");

      final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
      final notification = NotificationModel.fromFirebaseMessage({
        'messageId': message.messageId,
        'notification': {
          'title': message.notification?.title,
          'body': message.notification?.body,
        },
        'data': message.data,
      });

      notificationProvider.addNotification(notification);

      final notificationService = NotificationService();
      notificationService.updateNotificationBadge(notificationProvider.unreadCount);
      debugPrint("Badge diperbarui dengan ${notificationProvider.unreadCount} notifikasi belum dibaca (onMessageOpenedApp)");

      Navigator.of(context).pushNamed('/notifications');
    });
  }

  Future<void> _loadBackgroundNotifications() async {
    try {
      final notificationService = NotificationService();
      final backgroundNotifications = await notificationService.getNotificationsFromPrefs();

      if (backgroundNotifications.isNotEmpty) {
        print("Loaded ${backgroundNotifications.length} background notifications");

        final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
        for (var notification in backgroundNotifications) {
          final exists = notificationProvider.notifications.any((n) => n.id == notification.id);
          if (!exists) {
            notificationProvider.addNotification(notification);
          }
        }

        await notificationService.updateNotificationBadge(notificationProvider.unreadCount);
        print("Badge diperbarui dengan ${notificationProvider.unreadCount} notifikasi belum dibaca");

        if (backgroundNotifications.isNotEmpty) {
          for (int i = 0; i < backgroundNotifications.length; i++) {
            final notification = backgroundNotifications[i];
            await notificationService.showLocalNotification(
              title: notification.title,
              body: notification.body,
              payload: notification.data != null ? json.encode(notification.data) : null,
              notificationId: 100 + i,
            );
            await Future.delayed(Duration(milliseconds: 100));
          }
        }
      }
    } catch (e) {
      print("Error loading background notifications: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    final List<Widget> pages = [
      DashboardScreen(),
      ProfileScreen(),
      ProfileScreen(),
      MenuScreen(),
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
              navProvider.currentIndex = index;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }
}
