import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';
import '../services/storage_service.dart';
import '../services/media_service.dart';

class MusicProvider extends ChangeNotifier {
  final MediaService _mediaService = MediaService();
  List<SongModel> _songs = [];
  List<PlaylistModel> _playlists = [];
  bool _isLoading = false;
  bool _initialized = false;

  MediaService get mediaService => _mediaService;
  List<SongModel> get songs => _songs;
  List<PlaylistModel> get playlists => _playlists;
  bool get isLoading => _isLoading;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;
    _isLoading = true;
    notifyListeners();

    await StorageService.init();
    _songs = await StorageService.getAllSongs();
    _playlists = await StorageService.getAllPlaylists();
    _isLoading = false;
    _initialized = true;
    notifyListeners();
  }

  Future<void> importLocalSongs() async {
    final fallbackDir = Directory('/storage/emulated/0/Music');
    if (!await fallbackDir.exists()) return;

    final files = fallbackDir.listSync(recursive: true).whereType<File>().where((f) {
      final ext = f.path.split('.').last.toLowerCase();
      return ['mp3', 'wav', 'flac', 'aac', 'ogg', 'm4a'].contains(ext);
    }).toList();

    for (final file in files) {
      final song = SongModel(
        id: file.path.hashCode.toString(),
        title: file.path.split(Platform.pathSeparator).last.replaceAll(RegExp(r'\.\w+$'), ''),
        artist: '本地音乐',
        filePath: file.path,
        isLocal: true,
      );
      if (!_songs.any((s) => s.id == song.id)) {
        _songs.insert(0, song);
        await StorageService.insertSong(song);
      }
    }
    notifyListeners();
  }

  Future<void> addSong(SongModel song) async {
    _songs.insert(0, song);
    await StorageService.insertSong(song);
    notifyListeners();
  }

  Future<void> removeSong(String id) async {
    _songs.removeWhere((s) => s.id == id);
    await StorageService.deleteSong(id);
    notifyListeners();
  }

  Future<void> createPlaylist(String name) async {
    final playlist = PlaylistModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    _playlists.insert(0, playlist);
    await StorageService.insertPlaylist(playlist);
    notifyListeners();
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index == -1) return;
    final playlist = _playlists[index];
    if (playlist.songIds.contains(songId)) return;

    final updated = PlaylistModel(
      id: playlist.id,
      name: playlist.name,
      coverPath: playlist.coverPath,
      songIds: [...playlist.songIds, songId],
      createdAt: playlist.createdAt,
    );
    _playlists[index] = updated;
    await StorageService.insertPlaylist(updated);
    notifyListeners();
  }

  Future<void> playSong(SongModel song) async {
    await _mediaService.playSong(song);
  }

  Future<void> playSongAtIndex(int index) async {
    if (index < 0 || index >= _songs.length) return;
    await _mediaService.playSong(_songs[index]);
  }

  @override
  void dispose() {
    _mediaService.dispose();
    super.dispose();
  }
}
