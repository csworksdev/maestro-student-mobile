import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:maestro_client_mobile/providers/auth_provider.dart';
import 'package:maestro_client_mobile/providers/navigation_provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';

import 'package:maestro_client_mobile/screens/dashboard_screen.dart';
import 'package:maestro_client_mobile/screens/profile_screen.dart';
import 'package:maestro_client_mobile/screens/settings_screen.dart';
import 'package:maestro_client_mobile/pages/login_page.dart';

import 'package:maestro_client_mobile/widgets/app_bar.dart';
import 'package:maestro_client_mobile/widgets/bottom_nav_bar.dart' as CustomWidgets;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
          locale: const Locale('id'), // Bahasa Indonesia
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
  Widget build(BuildContext context) {
    final navProvider = Provider.of<NavigationProvider>(context);

    final List<Widget> pages = [
      DashboardScreen(),
      ProfileScreen(),
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
