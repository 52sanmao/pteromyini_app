import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  double _volume = 1.0;
  double _playbackSpeed = 1.0;
  bool _darkMode = false;
  bool _isOnline = true;
  final String _channelId = '6763235336';
  StreamSubscription? _connectivitySub;

  double get volume => _volume;
  double get playbackSpeed => _playbackSpeed;
  bool get darkMode => _darkMode;
  bool get isOnline => _isOnline;
  String get channelId => _channelId;

  SettingsProvider() {
    _loadSettings();
    _monitorConnectivity();
  }

  void _loadSettings() {
    _volume = (StorageService.getInt('volume') ?? 100) / 100.0;
    _playbackSpeed = (StorageService.getInt('playbackSpeed') ?? 100) / 100.0;
    final darkModeVal = StorageService.getInt('darkMode');
    if (darkModeVal != null) _darkMode = darkModeVal == 1;
  }

  void _monitorConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      _isOnline = results.any((r) => r != ConnectivityResult.none);
      notifyListeners();
    });
  }

  Future<void> setVolume(double vol) async {
    _volume = vol.clamp(0.0, 1.0);
    await StorageService.saveInt('volume', (_volume * 100).round());
    notifyListeners();
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed.clamp(0.5, 2.0);
    await StorageService.saveInt('playbackSpeed', (_playbackSpeed * 100).round());
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _darkMode = !_darkMode;
    await StorageService.saveInt('darkMode', _darkMode ? 1 : 0);
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
}
