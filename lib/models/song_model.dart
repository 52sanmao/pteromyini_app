class SongModel {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String? albumArt;
  final String filePath;
  final String? url;
  final Duration duration;
  final bool isLocal;
  final int createdAt;

  SongModel({
    required this.id,
    required this.title,
    required this.artist,
    this.album = '',
    this.albumArt,
    required this.filePath,
    this.url,
    this.duration = Duration.zero,
    this.isLocal = true,
    int? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'albumArt': albumArt,
        'filePath': filePath,
        'url': url,
        'duration': duration.inMilliseconds,
        'isLocal': isLocal ? 1 : 0,
        'createdAt': createdAt,
      };

  factory SongModel.fromMap(Map<String, dynamic> map) => SongModel(
        id: map['id'] as String,
        title: map['title'] as String,
        artist: map['artist'] as String? ?? '',
        album: map['album'] as String? ?? '',
        albumArt: map['albumArt'] as String?,
        filePath: map['filePath'] as String,
        url: map['url'] as String?,
        duration: Duration(milliseconds: map['duration'] as int? ?? 0),
        isLocal: (map['isLocal'] as int? ?? 1) == 1,
        createdAt: map['createdAt'] as int? ?? 0,
      );
}
