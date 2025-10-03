import 'package:flutter/material.dart';
import 'privacysecurity_screen.dart';
import 'package:maestro_client_mobile/screens/account_screen.dart';

class SettingsScreen extends StatelessWidget {
  late final List<_SettingItem> settingsItems;
  
  SettingsScreen() {
    // Inisialisasi settingsItems di constructor untuk menghindari error implicit_this_reference_in_initializer
    settingsItems = [
      _SettingItem(
        icon: Icons.person,
        title: 'Akun',
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AccountScreen()),
          );
        },
      ),
      _SettingItem(
        icon: Icons.lock,
        title: 'Sandi & Keamanan',
        onTap: (context) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PrivacySecurityScreen()),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: settingsItems.length,
        itemBuilder: (context, index) {
          final item = settingsItems[index];
          return _buildSettingCard(context, item, isDarkMode);
        },
      ),
    );
  }

  Widget _buildSettingCard(BuildContext context, _SettingItem item, bool isDarkMode) {
    final size = MediaQuery.of(context).size;
    
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: size.height * 0.01,
        horizontal: size.width * 0.02,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF121212) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode 
                ? Colors.black.withOpacity(0.3) 
                : Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => item.onTap(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.05,
              vertical: size.height * 0.02,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? Colors.white.withOpacity(0.1) 
                        : Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.icon,
                    color: isDarkMode ? Colors.white : Colors.black,
                    size: 22,
                  ),
                ),
                SizedBox(width: size.width * 0.04),
                Expanded(
                  child: Text(
                    item.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDarkMode ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7),
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

class _SettingItem {
  final IconData icon;
  final String title;
  final Function(BuildContext) onTap;

  _SettingItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}
