import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../services/media_service.dart';
import '../widgets/seek_bar.dart';
import '../utils/theme.dart';

class PlayerPage extends StatelessWidget {
  const PlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final media = provider.mediaService;
    final song = media.currentSong;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = media.playbackStateNotifier.value;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121220) : Colors.white,
      body: SafeArea(
        child: song == null
            ? const Center(child: Text('暂无播放', style: TextStyle(color: Colors.grey)))
            : Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_down_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.more_horiz_rounded),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // Album art
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppTheme.primaryColor, AppTheme.accentColor],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                                  blurRadius: 40,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(Icons.music_note_rounded, size: 80, color: Colors.white54),
                            ),
                          ),
                          // Loading spinner
                          if (state == PlaybackState.loading)
                            Container(
                              width: 280,
                              height: 280,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: Colors.black26,
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 36, height: 36,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                    ),
                                    SizedBox(height: 8),
                                    Text('缓冲中...', style: TextStyle(color: Colors.white70, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          // Error overlay
                          if (state == PlaybackState.error)
                            Container(
                              width: 280,
                              height: 280,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                color: Colors.black54,
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.error_outline_rounded, color: Colors.orangeAccent, size: 36),
                                      const SizedBox(height: 8),
                                      Text(
                                        media.errorMessageNotifier.value ?? '播放失败',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Song info
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(
                                song.artist.isNotEmpty ? song.artist : '未知艺术家',
                                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_outline_rounded),
                          color: Colors.grey[400],
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Seek bar
                  SeekBar(
                    position: media.positionNotifier.value,
                    duration: media.durationNotifier.value,
                    onSeek: (pos) => media.seek(pos),
                  ),
                  // Controls
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(
                            media.loopModeNotifier.value == LoopMode.one
                                ? Icons.repeat_one_rounded : Icons.repeat_rounded,
                            color: media.loopModeNotifier.value != LoopMode.off
                                ? AppTheme.primaryColor : Colors.grey[400],
                          ),
                          onPressed: () => media.toggleLoopMode(),
                        ),
                        IconButton(
                          icon: Icon(Icons.skip_previous_rounded, color: Colors.grey[600], size: 36),
                          onPressed: () {},
                        ),
                        Container(
                          width: 64, height: 64,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppTheme.primaryColor, AppTheme.accentColor],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x406C5CE7), blurRadius: 16, offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: state == PlaybackState.loading
                              ? const Center(
                                  child: SizedBox(
                                    width: 24, height: 24,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                  ),
                                )
                              : IconButton(
                                  icon: Icon(
                                    media.isPlayingNotifier.value
                                        ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: Colors.white, size: 36,
                                  ),
                                  onPressed: () => media.togglePlay(),
                                ),
                        ),
                        IconButton(
                          icon: Icon(Icons.skip_next_rounded, color: Colors.grey[600], size: 36),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.shuffle_rounded, color: Colors.grey[400]),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Volume
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Row(
                      children: [
                        Icon(Icons.volume_down_rounded, color: Colors.grey[400], size: 18),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: AppTheme.primaryColor,
                              inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
                              thumbColor: AppTheme.primaryColor,
                              trackHeight: 2,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 4),
                            ),
                            child: Slider(
                              value: media.volumeNotifier.value,
                              onChanged: (v) => media.setVolume(v),
                            ),
                          ),
                        ),
                        Icon(Icons.volume_up_rounded, color: Colors.grey[400], size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
      ),
    );
  }
}
