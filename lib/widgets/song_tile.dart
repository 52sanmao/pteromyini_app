import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../utils/theme.dart';

class SongTile extends StatelessWidget {
  final SongModel song;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final bool isPlaying;

  const SongTile({
    super.key,
    required this.song,
    this.onTap,
    this.onMoreTap,
    this.isPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tileBg = isDark ? const Color(0xFF2D2D44) : Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: tileBg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: isPlaying
                          ? [AppTheme.primaryColor, AppTheme.accentColor]
                          : [Colors.grey[300]!, Colors.grey[200]!],
                    ),
                  ),
                  child: isPlaying
                      ? const Icon(Icons.music_note_rounded, color: Colors.white, size: 24)
                      : const Icon(Icons.music_note_rounded, color: Colors.grey, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isPlaying ? FontWeight.w700 : FontWeight.w500,
                          color: isPlaying ? AppTheme.primaryColor : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        song.artist.isNotEmpty ? song.artist : '未知艺术家',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
                if (onMoreTap != null)
                  IconButton(
                    icon: Icon(Icons.more_horiz, color: Colors.grey[400], size: 20),
                    onPressed: onMoreTap,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
