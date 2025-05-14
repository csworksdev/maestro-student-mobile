import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:package_info_plus/package_info_plus.dart';

import 'package:maestro_client_mobile/providers/auth_provider.dart';
import 'package:maestro_client_mobile/providers/navigation_provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:maestro_client_mobile/providers/kehadiran_provider.dart';
import 'package:maestro_client_mobile/providers/earnings.provider.dart';

import 'package:maestro_client_mobile/screens/dashboard_screen.dart';
import 'package:maestro_client_mobile/screens/earning_screen.dart';
import 'package:maestro_client_mobile/screens/profile_screen.dart';
import 'package:maestro_client_mobile/screens/settings_screen.dart';
import 'package:maestro_client_mobile/pages/login_page.dart';

import 'package:maestro_client_mobile/widgets/app_bar.dart';
import 'package:maestro_client_mobile/widgets/bottom_nav_bar.dart' as CustomWidgets;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => KehadiranProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, EarningsProvider>(
          create: (_) => EarningsProvider(),
          update: (context, auth, earnings) => earnings!..fetchEarnings(context),
        ),
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
          darkTheme: ThemeData.dark(),
          home: authProvider.isLoggedIn ? MainScreen() : LoginPage(),
          routes: {
            '/MainScreen': (context) => MainScreen(),
            '/login': (context) => LoginPage(),
            '/settings': (context) => SettingsScreen(),
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
  // bool _hasCheckedUpdate = false;

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   if (!_hasCheckedUpdate) {
  //     _hasCheckedUpdate = true;
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       _checkForUpdates(context);
  //     });
  //   }
  // }

  // Future<void> _checkForUpdates(BuildContext context) async {
  //   const String apiUrl = 'https://api.maestroswim.com/api/updates/latest/android/';
  //   try {
  //     final packageInfo = await PackageInfo.fromPlatform();
  //     final int buildNumber = int.parse(packageInfo.buildNumber);

  //     final response = await http.get(Uri.parse(apiUrl));
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       final int versionCode = data['versionCode'];
  //       final String apkUrl = data['apkUrl'];
  //       final String changeLog = data['changeLog'];
  //       final bool forceUpdate = data['force_update'];

  //       // Debug print for update parameters
  //       print('Update Check:');
  //       print('Current Build Number: $buildNumber');
  //       print('Latest Version Code: $versionCode');
  //       print('APK URL: $apkUrl');
  //       print('Change Log: $changeLog');
  //       print('Force Update: $forceUpdate');

  //       if (versionCode > buildNumber) {
  //         _showUpdateDialog(context, apkUrl, changeLog, forceUpdate);
  //       }
  //     }
  //   } catch (e) {
  //     print('Error checking for updates: $e');
  //   }
  // }

  // void _showUpdateDialog(BuildContext context, String apkUrl, String changeLog, bool forceUpdate) {
  //   // Debug print for dialog parameters
  //   print('Showing Update Dialog:');
  //   print('APK URL: $apkUrl');
  //   print('Change Log: $changeLog');
  //   print('Force Update: $forceUpdate');

  //   showDialog(
  //     context: context,
  //     barrierDismissible: !forceUpdate,
  //     builder: (context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(16),
  //         ),
  //         title: Row(
  //           children: [
  //             Icon(Icons.system_update, color: Colors.blue),
  //             SizedBox(width: 10),
  //             Text(
  //               'Update Available',
  //               style: TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //           ],
  //         ),
  //         content: SingleChildScrollView(
  //           child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'A new version of the app is available. Please update to enjoy the latest features and improvements!',
  //                 style: TextStyle(fontSize: 14, height: 1.5),
  //               ),
  //               SizedBox(height: 10),
  //             ],
  //           ),
  //         ),
  //         actions: [
  //           if (!forceUpdate)
  //             TextButton(
  //               onPressed: () => Navigator.of(context).pop(),
  //               child: Text(
  //                 'Later',
  //                 style: TextStyle(color: Colors.grey),
  //               ),
  //             ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               _launchURL(apkUrl);
  //             },
  //             style: ElevatedButton.styleFrom(
  //               backgroundColor: Colors.blue,
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //             ),
  //             child: Text('Update'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // void _launchURL(String url) async {
  //   if (await canLaunch(url)) {
  //     await launch(url);
  //   } else {
  //     print('Could not launch $url');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    final List<Widget> pages = [
      DashboardScreen(),
      EarningScreen(),
      ProfileScreen(),
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