import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Duration _backgroundTaskInterval = Duration(minutes: 15);
const String _foregroundChannelId = 'maestro_background_service';

// Fungsi ini akan menginisialisasi layanan latar belakang.
Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  // Konfigurasi untuk Android dan iOS.
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: _foregroundChannelId,
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
  service.startService();
}

// Entry point untuk background fetch di iOS.
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

// Entry point utama untuk layanan latar belakang.
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  Timer? periodicTimer;

  service.on('stopService').listen((event) {
    periodicTimer?.cancel();
    service.stopSelf();
  });

  // Panggil ini segera untuk mempromosikan layanan ke foreground
  if (service is AndroidServiceInstance) {
    service.setForegroundNotificationInfo(
      title: "Maestro Client App",
      content: "Layanan latar belakang aktif",
    );
  }

  // Tugas yang akan dijalankan secara berkala di latar belakang.
  periodicTimer = Timer.periodic(_backgroundTaskInterval, (timer) async {
    if (service is AndroidServiceInstance) {
      service.setForegroundNotificationInfo(
        title: "Maestro Client App",
        content: "Sinkronisasi data sedang berjalan pada ${DateTime.now()}",
      );
    }

    // Contoh tugas: sinkronisasi data atau memeriksa notifikasi.
    // Anda dapat menambahkan logika Anda di sini.
    debugPrint('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // Contoh: menyimpan data ke SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_sync', DateTime.now().toIso8601String());
  });
}