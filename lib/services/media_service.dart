import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart';
import '../models/song_model.dart';

class MediaService {
  final AudioPlayer _player = AudioPlayer();
  SongModel? _currentSong;
  final ValueNotifier<SongModel?> currentSongNotifier = ValueNotifier(null);
  final ValueNotifier<Duration> positionNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> durationNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<bool> isPlayingNotifier = ValueNotifier(false);
  final ValueNotifier<double> volumeNotifier = ValueNotifier(1.0);
  final ValueNotifier<LoopMode> loopModeNotifier = ValueNotifier(LoopMode.off);

  StreamSubscription? _positionSub;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _durationSub;

  SongModel? get currentSong => _currentSong;
  AudioPlayer get player => _player;

  MediaService() {
    _setupListeners();
  }

  void _setupListeners() {
    _positionSub = _player.positionStream.listen((pos) {
      positionNotifier.value = pos;
    });
    _playerStateSub = _player.playerStateStream.listen((state) {
      isPlayingNotifier.value = state.playing;
    });
    _durationSub = _player.durationStream.listen((dur) {
      if (dur != null) durationNotifier.value = dur;
    });
  }

  Future<void> playSong(SongModel song) async {
    _currentSong = song;
    currentSongNotifier.value = song;
    try {
      if (song.isLocal && song.filePath.isNotEmpty) {
        if (File(song.filePath).existsSync()) {
          await _player.setFilePath(song.filePath);
        } else if (song.url != null) {
          await _player.setUrl(song.url!);
        }
      } else if (song.url != null) {
        await _player.setUrl(song.url!);
      }
      await _player.play();
    } catch (e) {
      debugPrint('Play error: $e');
    }
  }

  Future<void> playUrl(String url) async {
    await _player.setUrl(url);
    await _player.play();
  }

  Future<void> playFile(String path) async {
    await _player.setFilePath(path);
    await _player.play();
  }

  Future<void> togglePlay() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
    volumeNotifier.value = volume;
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  void toggleLoopMode() {
    final modes = [LoopMode.off, LoopMode.one, LoopMode.all];
    final next = modes[(modes.indexOf(loopModeNotifier.value) + 1) % modes.length];
    _player.setLoopMode(next);
    loopModeNotifier.value = next;
  }

  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  bool get isPlaying => _player.playing;

  Future<void> stop() async {
    await _player.stop();
    _currentSong = null;
    currentSongNotifier.value = null;
    isPlayingNotifier.value = false;
  }

  void dispose() {
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _player.dispose();
  }
}
