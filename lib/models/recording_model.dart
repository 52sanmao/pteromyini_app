class RecordingModel {
  final String id;
  final String name;
  final String filePath;
  final Duration duration;
  final int createdAt;
  final int fileSize;

  RecordingModel({
    required this.id,
    required this.name,
    required this.filePath,
    this.duration = Duration.zero,
    int? createdAt,
    this.fileSize = 0,
  }) : createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  String get formattedDuration {
    final min = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final sec = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  String get formattedSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
