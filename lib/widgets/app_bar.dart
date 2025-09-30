import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maestro_client_mobile/providers/theme_provider.dart';
import 'package:maestro_client_mobile/providers/notification_provider.dart';
import 'package:maestro_client_mobile/widgets/notification_badge.dart';
import 'dart:ui';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? const Color.fromARGB(255, 30, 30, 30)
            : Color(0xFF003566)
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildAnimatedLogo(context),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications_none, color: Colors.white, size: 32),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/notifications');
                  },
                  tooltip: 'Notifikasi',
                ),
                Consumer<NotificationProvider>(
                  builder: (context, notificationProvider, child) {
                    return Positioned(
                      right: 5,
                      top: 5,
                      child: NotificationBadge(
                        count: notificationProvider.unreadCount,
                        color: Colors.red,
                        size: 18,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
      ),
    );
  }

  // ...existing code...

  Widget _buildAnimatedLogo(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: _InteractiveRotatingLogo(),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Image.asset(
          'assets/images/logo_maestro.png',
          height: 50,
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