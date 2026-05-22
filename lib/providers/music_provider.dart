import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/song_model.dart';
import '../services/storage_service.dart';
import '../services/media_service.dart';

class MusicProvider extends ChangeNotifier {
  final MediaService _mediaService = MediaService();
  List<SongModel> _songs = [];
  bool _isLoading = false;
  bool _initialized = false;

  MediaService get mediaService => _mediaService;
  List<SongModel> get songs => _songs;
  bool get isLoading => _isLoading;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    _isLoading = true;
    notifyListeners();

    await StorageService.init();
    _songs = await StorageService.getAllSongs();

    if (_songs.isEmpty) {
      await _loadDefaultPlaylist();
    }

    _isLoading = false;
    _initialized = true;
    notifyListeners();
  }

  Future<void> _loadDefaultPlaylist() async {
    _songs = [
      SongModel(id: 'sample_1', title: 'SoundHelix 1', artist: 'SoundHelix', url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', isLocal: false),
      SongModel(id: 'sample_2', title: 'SoundHelix 2', artist: 'SoundHelix', url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3', isLocal: false),
      SongModel(id: 'sample_3', title: 'SoundHelix 3', artist: 'SoundHelix', url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3', isLocal: false),
      SongModel(id: 'sample_4', title: 'SoundHelix 4', artist: 'SoundHelix', url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3', isLocal: false),
      SongModel(id: 'sample_5', title: 'SoundHelix 5', artist: 'SoundHelix', url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3', isLocal: false),
      SongModel(id: 'sample_6', title: 'SoundHelix 6', artist: 'SoundHelix', url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3', isLocal: false),
      SongModel(id: 'sample_7', title: 'SoundHelix 7', artist: 'SoundHelix', url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3', isLocal: false),
      SongModel(id: 'sample_8', title: 'SoundHelix 8', artist: 'SoundHelix', url: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3', isLocal: false),
    ];
    for (final s in _songs) {
      await StorageService.insertSong(s);
    }
  }

  Future<void> playSongAt(int index) async {
    if (index < 0 || index >= _songs.length) return;
    await _mediaService.playSong(_songs[index]);
  }

  Future<void> playSong(SongModel song) async {
    await _mediaService.playSong(song);
  }

  Future<void> playUrl(String url) async {
    final song = SongModel(
      id: url.hashCode.toString(),
      title: url.split('/').last.replaceAll(RegExp(r'\.\w+$'), ''),
      artist: '在线音乐',
      url: url,
      isLocal: false,
    );
    _songs.insert(0, song);
    await StorageService.insertSong(song);
    notifyListeners();
    await _mediaService.playSong(song);
  }

  Future<void> removeSong(String id) async {
    _songs.removeWhere((s) => s.id == id);
    await StorageService.deleteSong(id);
    notifyListeners();
  }

  @override
  void dispose() {
    _mediaService.dispose();
    super.dispose();
  }
}
