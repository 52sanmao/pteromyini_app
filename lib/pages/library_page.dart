import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/now_playing_bar.dart';
import '../utils/theme.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  void _showAddUrlDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加在线音乐'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '粘贴音乐 URL',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          FilledButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                Navigator.pop(ctx);
                context.read<MusicProvider>().playUrl(url);
              }
            },
            child: const Text('播放'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('音乐库', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_link_rounded),
            tooltip: '添加在线音乐',
            onPressed: () => _showAddUrlDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick category chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _chip(Icons.explore_rounded, '推荐', true),
                const SizedBox(width: 8),
                _chip(Icons.trending_up_rounded, '排行榜', false),
                const SizedBox(width: 8),
                _chip(Icons.favorite_rounded, '收藏', false),
              ],
            ),
          ),
          Expanded(
            child: provider.songs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.library_music_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('点击右上角添加在线音乐', style: TextStyle(color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: provider.songs.length,
                    itemBuilder: (_, i) {
                      final song = provider.songs[i];
                      return SongTile(
                        song: song,
                        isPlaying: provider.mediaService.currentSong?.id == song.id,
                        onTap: () => provider.playSongAt(i),
                        onMoreTap: () => _showSongMenu(context, song.id),
                      );
                    },
                  ),
          ),
          const NowPlayingBar(),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, bool selected) {
    return FilterChip(
      avatar: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 13)),
      selected: selected,
      selectedColor: AppTheme.primaryColor.withValues(alpha: 0.15),
      checkmarkColor: AppTheme.primaryColor,
      onSelected: (_) {},
    );
  }

  void _showSongMenu(BuildContext context, String id) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('分享'),
              onTap: () { Navigator.pop(ctx); },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: Colors.red[400]),
              title: Text('删除', style: TextStyle(color: Colors.red[400])),
              onTap: () {
                Navigator.pop(ctx);
                context.read<MusicProvider>().removeSong(id);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
