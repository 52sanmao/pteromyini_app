class PlaylistModel {
  final String id;
  final String name;
  final String? coverPath;
  final List<String> songIds;
  final int createdAt;

  PlaylistModel({
    required this.id,
    required this.name,
    this.coverPath,
    List<String>? songIds,
    int? createdAt,
  })  : songIds = songIds ?? [],
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'coverPath': coverPath,
        'songIds': songIds.join(','),
        'createdAt': createdAt,
      };

  factory PlaylistModel.fromMap(Map<String, dynamic> map) => PlaylistModel(
        id: map['id'] as String,
        name: map['name'] as String,
        coverPath: map['coverPath'] as String?,
        songIds: (map['songIds'] as String?)?.split(',').where((s) => s.isNotEmpty).toList(),
        createdAt: map['createdAt'] as int?,
      );
}
