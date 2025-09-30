import 'package:flutter/material.dart';
import 'privacysecurity_screen.dart';

class SettingsScreen extends StatelessWidget {
  late final List<_SettingItem> settingsItems;
  
  SettingsScreen() {
    // Inisialisasi settingsItems di constructor untuk menghindari error implicit_this_reference_in_initializer
    settingsItems = [
      _SettingItem(
        icon: Icons.person,
        title: 'Akun',
        onTap: (context) {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(builder: (context) => AccountScreen()),
          // );
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
      _SettingItem(
        icon: Icons.notifications,
        title: 'Test Notifikasi',
        onTap: (context) {
          _sendTestNotification(context);
        },
      ),
    ];
  }
  
  // Fungsi untuk mengirim notifikasi test
  void _sendTestNotification(BuildContext context) async {
    // Variabel untuk menyimpan judul dan pesan notifikasi
    String title = 'Order baru 🚀';
    String body = 'Ini pesan test ke device';
    
    // Tampilkan dialog untuk input judul dan pesan
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Test Notifikasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Judul Notifikasi',
                  hintText: 'Masukkan judul notifikasi',
                ),
                onChanged: (value) {
                  title = value.isNotEmpty ? value : 'Order baru 🚀';
                },
                controller: TextEditingController(text: title),
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Pesan Notifikasi',
                  hintText: 'Masukkan pesan notifikasi',
                ),
                onChanged: (value) {
                  body = value.isNotEmpty ? value : 'Ini pesan test ke device';
                },
                controller: TextEditingController(text: body),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Kirim'),
            ),
          ],
        );
      },
    );
    
    // Tampilkan loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Mengirim notifikasi test..."),
            ],
          ),
        );
      },
    );
    
    try {
      
      // Tutup dialog loading
      Navigator.of(context).pop();
      
    } catch (e) {
      // Tutup dialog loading jika terjadi error
      Navigator.of(context).pop();
      
      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? Colors.grey[900] : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('Setelan'),
        backgroundColor: isDarkMode ? Colors.grey[900] : const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: isDarkMode ? Colors.grey[850] : Colors.white,
      child: InkWell(
        onTap: () => item.onTap(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(item.icon, color: isDarkMode ? Colors.orangeAccent : const Color.fromARGB(201, 0, 0, 0)),
              SizedBox(width: 16),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              Spacer(),
              Icon(Icons.arrow_forward_ios, size: 16, color: isDarkMode ? Colors.white30 : Colors.black26),
            ],
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
