import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:maestro_client_mobile/providers/auth_provider.dart';
import 'package:maestro_client_mobile/screens/settings_screen.dart';

class MenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menu',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 24),
              _buildMenuItem(
                context: context,
                icon: Icons.settings,
                title: 'Setelan',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsScreen()),
                  );
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context: context,
                icon: Icons.dark_mode,
                title: isDarkMode ? 'Mode Terang' : 'Mode Gelap',
                onTap: () {
                  themeProvider.toggleTheme();
                },
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 16),
              _buildMenuItem(
                context: context,
                icon: Icons.logout,
                title: 'Keluar',
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Konfirmasi Logout'),
                      content: Text('Apakah Anda yakin ingin logout?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                          child: Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: TextButton.styleFrom(foregroundColor: Colors.green),
                          child: Text('Ya'),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout == true) {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    await authProvider.logout();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Logout berhasil!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
                isDarkMode: isDarkMode,
                isLogout: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
    bool isLogout = false,
  }) {
    final Color textColor = isLogout ? Colors.red : (isDarkMode ? Colors.white : Colors.black);
    final Color iconColor = isLogout ? Colors.red : (isDarkMode ? Colors.white : Colors.black);
    final Color cardColor = isDarkMode ? Colors.grey[800]! : Colors.grey[100]!;

    return Card(
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: iconColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}