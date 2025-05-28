import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:maestro_client_mobile/providers/auth_provider.dart';
import 'dart:ui';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return AppBar(
      backgroundColor: const Color.fromARGB(240, 0, 53, 102), // Warna putih sepenuhnya
      elevation: 0, // Hilangkan bayangan
      leading: _buildMenuButton(context, isDarkMode, themeProvider),
      actions: [
        _buildNotificationIcon(context),
        _buildMaestroLogo(context),
      ],
    );
  }

  Widget _buildMenuButton(BuildContext context, bool isDarkMode, ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: PopupMenuButton<int>(
        onSelected: (value) async {
          if (value == 0) {
            Navigator.of(context).pushNamed('/login');
          } else if (value == 1) {
            Navigator.of(context).pushNamed('/settings');
          } else if (value == 2) {
            themeProvider.toggleTheme();
          } else if (value == 3) {
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
          }
        },
        offset: Offset(0, 50),
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        icon: Icon(
          Icons.menu_rounded,
          color: const Color.fromARGB(255, 255, 255, 255), // Ikon menu berwarna hitam
          size: 32,
        ),
        itemBuilder: (context) => [
          _buildPopupMenuItem(value: 1, icon: Icons.settings, title: "Setelan", isDarkMode: isDarkMode),
          _buildPopupMenuItem(value: 3, icon: Icons.logout, title: "Keluar", isDarkMode: isDarkMode),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: IconButton(
        icon: Icon(
          Icons.notifications_none_rounded,
          size: 32,
          color: const Color.fromARGB(255, 255, 255, 255),
        ),
        onPressed: () {
          Navigator.of(context).pushNamed('/notifications');
        },
      ),
    );
  }

  Widget _buildMaestroLogo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(
        'assets/images/logo_maestro.png',
        width: 40,
        height: 40,
        fit: BoxFit.contain,
      ),
    );
  }

  PopupMenuItem<int> _buildPopupMenuItem({
    required int value,
    required IconData icon,
    required String title,
    required bool isDarkMode,
  }) {
    return PopupMenuItem(
      value: value,
      child: Container(
        width: 120,
        child: ListTile(
          leading: Icon(
            icon,
            color: value == 3 ? Colors.red : Colors.black,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: value == 3 ? Colors.red : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _InteractiveRotatingLogo extends StatefulWidget {
  @override
  State<_InteractiveRotatingLogo> createState() => _InteractiveRotatingLogoState();
}

class _InteractiveRotatingLogoState extends State<_InteractiveRotatingLogo> {
  double _rotationY = 0.0;

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _rotationY += details.delta.dx * 0.01;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _rotationY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            onHorizontalDragUpdate: _onDragUpdate,
            onHorizontalDragEnd: _onDragEnd,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_rotationY),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/images/logo_maestro.png',
                    fit: BoxFit.contain,
                    width: 280,
                    height: 280,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}
