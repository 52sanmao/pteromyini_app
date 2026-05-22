import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/song_model.dart';
import '../models/playlist_model.dart';
import '../models/recording_model.dart';

class StorageService {
  static Database? _database;
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _database = await _initDatabase();
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'pteromyini.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE songs (
            id TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            artist TEXT DEFAULT '',
            album TEXT DEFAULT '',
            albumArt TEXT,
            filePath TEXT NOT NULL,
            url TEXT,
            duration INTEGER DEFAULT 0,
            isLocal INTEGER DEFAULT 1,
            createdAt INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE playlists (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            coverPath TEXT,
            songIds TEXT,
            createdAt INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE recordings (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            filePath TEXT NOT NULL,
            duration INTEGER DEFAULT 0,
            fileSize INTEGER DEFAULT 0,
            createdAt INTEGER
          )
        ''');
      },
    );
  }

  static T? getFromJson<T>(String key) {
    final json = _prefs?.getString(key);
    if (json == null) return null;
    return json as T;
  }

  static Future<void> saveToJson(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  static Future<void> saveInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  static int? getInt(String key) => _prefs?.getInt(key);

  // Songs
  static Future<List<SongModel>> getAllSongs() async {
    if (_database == null) return [];
    final maps = await _database!.query('songs', orderBy: 'createdAt DESC');
    return maps.map(SongModel.fromMap).toList();
  }

  static Future<void> insertSong(SongModel song) async {
    await _database?.insert('songs', song.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteSong(String id) async {
    await _database?.delete('songs', where: 'id = ?', whereArgs: [id]);
  }

  // Playlists
  static Future<List<PlaylistModel>> getAllPlaylists() async {
    if (_database == null) return [];
    final maps = await _database!.query('playlists', orderBy: 'createdAt DESC');
    return maps.map(PlaylistModel.fromMap).toList();
  }

  static Future<void> insertPlaylist(PlaylistModel playlist) async {
    await _database?.insert('playlists', playlist.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deletePlaylist(String id) async {
    await _database?.delete('playlists', where: 'id = ?', whereArgs: [id]);
  }

  // Recordings
  static Future<List<RecordingModel>> getAllRecordings() async {
    if (_database == null) return [];
    final maps = await _database!.query('recordings', orderBy: 'createdAt DESC');
    return maps.map((m) => RecordingModel(
          id: m['id'] as String,
          name: m['name'] as String,
          filePath: m['filePath'] as String,
          duration: Duration(milliseconds: m['duration'] as int? ?? 0),
          createdAt: m['createdAt'] as int?,
          fileSize: m['fileSize'] as int? ?? 0,
        )).toList();
  }

  static Future<void> insertRecording(RecordingModel recording) async {
    await _database?.insert('recordings', {
      'id': recording.id,
      'name': recording.name,
      'filePath': recording.filePath,
      'duration': recording.duration.inMilliseconds,
      'fileSize': recording.fileSize,
      'createdAt': recording.createdAt,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<void> deleteRecording(String id) async {
    await _database?.delete('recordings', where: 'id = ?', whereArgs: [id]);
  }
}
