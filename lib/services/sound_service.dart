import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  factory SoundService() {
    return _instance;
  }
  
  SoundService._internal();
  
  /// Memutar suara notifikasi
  Future<void> playNotificationSound() async {
    try {
      // Set mode audio untuk notifikasi
      await _audioPlayer.setReleaseMode(ReleaseMode.stop);
      
      // Set volume (0.0 - 1.0)
      await _audioPlayer.setVolume(1.0);
      
      // Putar suara dari assets
      await _audioPlayer.play(AssetSource('sounds/macox.mp3'));
      
      print('Notification sound played successfully');
    } catch (e) {
      print('Error playing notification sound: $e');
    }
  }
  
  /// Menghentikan suara notifikasi
  Future<void> stopNotificationSound() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping notification sound: $e');
    }
  }
  
  /// Dispose audio player
  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      print('Error disposing audio player: $e');
    }
  }
}