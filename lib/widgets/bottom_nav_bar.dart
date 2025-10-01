import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:maestro_client_mobile/providers/navigation_provider.dart';
import 'package:maestro_client_mobile/theme/app_theme.dart';

class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final navProvider = Provider.of<NavigationProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    final primaryColor = AppColors.navy;
    final secondaryColor = Theme.of(context).bottomNavigationBarTheme.backgroundColor ?? Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: Theme.of(context).bottomNavigationBarTheme.type ?? BottomNavigationBarType.fixed,
        backgroundColor: secondaryColor,
        selectedItemColor: primaryColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor ?? Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: navProvider.currentIndex,
        onTap: (index) {
          navProvider.currentIndex = index;
          onTap(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Jadwal',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Paket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifikasi',
          ),
        ],
      ),
    );
  }
}
