import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/now_playing_bar.dart';
import '../pages/player_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().initialize();
    });
  }

  void _playAndNavigate(int index) {
    final provider = context.read<MusicProvider>();
    provider.playSongAt(index);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PlayerPage()),
    );
  }

  void _showAddUrlDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加在线音乐'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '粘贴音乐 URL (mp3/m3u8/flac...)',
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
        title: const Text('鼯鼠音乐', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_link_rounded),
            tooltip: '添加在线音乐',
            onPressed: _showAddUrlDialog,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                          child: Text(
                            '热门推荐',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      if (provider.songs.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.music_note_rounded, size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text('暂无音乐', style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                                const SizedBox(height: 24),
                                FilledButton.tonalIcon(
                                  onPressed: _showAddUrlDialog,
                                  icon: const Icon(Icons.link_rounded),
                                  label: const Text('添加在线音乐链接'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (_, i) {
                              final song = provider.songs[i];
                              return SongTile(
                                song: song,
                                isPlaying: provider.mediaService.currentSong?.id == song.id,
                                onTap: () => _playAndNavigate(i),
                              );
                            },
                            childCount: provider.songs.length,
                          ),
                        ),
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                ),
                const NowPlayingBar(),
              ],
            ),
    );
  }
}
