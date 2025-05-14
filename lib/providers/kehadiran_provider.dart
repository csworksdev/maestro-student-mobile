import 'package:flutter/material.dart';
import 'package:maestro_client_mobile/models/kehadiran.dart';

class KehadiranProvider extends ChangeNotifier {
  List<Kehadiran> _kehadiranList = [];

  List<Kehadiran> get kehadiranList => _kehadiranList;

  void addKehadiran(Kehadiran kehadiran) {
    _kehadiranList.add(kehadiran);
    notifyListeners();
  }

  void removeKehadiran(Kehadiran kehadiran) {
    _kehadiranList.remove(kehadiran);
    notifyListeners();
  }

  void clearKehadiran() {
    _kehadiranList.clear();
    notifyListeners();
  }
}