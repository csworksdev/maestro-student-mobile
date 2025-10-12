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
    final backgroundColor = isDarkMode ? Color(0xFF121212) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.05, 
            vertical: size.height * 0.01
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * 0.02),
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
    final Color cardColor = isDarkMode ? Color(0xFF2C2C2E) : Colors.white;
    final Color shadowColor = isDarkMode ? Colors.black12 : Colors.black12;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  color: iconColor.withOpacity(0.7),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}