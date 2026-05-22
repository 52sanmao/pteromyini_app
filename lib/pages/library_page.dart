import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../widgets/song_tile.dart';
import '../widgets/now_playing_bar.dart';
import '../utils/theme.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showAddPlaylistDialog() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建歌单'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '输入歌单名称',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      context.read<MusicProvider>().createPlaylist(name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('音乐库', style: TextStyle(fontWeight: FontWeight.w700)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryColor,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: '歌曲'),
            Tab(text: '歌单'),
            Tab(text: '专辑'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add_rounded),
            onPressed: _showAddPlaylistDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Songs tab
                provider.songs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.library_music_outlined,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              '点击右上角导入本地音乐',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
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
                            isPlaying:
                                provider.mediaService.currentSong?.id == song.id &&
                                    provider.mediaService.isPlaying,
                            onTap: () => provider.playSongAtIndex(i),
                            onMoreTap: () => _showSongMenu(song.id),
                          );
                        },
                      ),
                // Playlists tab
                provider.playlists.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.playlist_play_rounded,
                                size: 64, color: Colors.grey[300]),
                            const SizedBox(height: 16),
                            Text(
                              '暂无歌单，点击右上角创建',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 80),
                        itemCount: provider.playlists.length,
                        itemBuilder: (_, i) {
                          final p = provider.playlists[i];
                          return ListTile(
                            leading: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryColor.withValues(alpha: 0.7),
                                    AppTheme.accentColor.withValues(alpha: 0.5),
                                  ],
                                ),
                              ),
                              child: const Icon(Icons.playlist_play_rounded,
                                  color: Colors.white),
                            ),
                            title: Text(p.name),
                            subtitle: Text('${p.songIds.length} 首'),
                          );
                        },
                      ),
                // Albums tab (placeholder)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.album_rounded, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        '专辑功能开发中',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const NowPlayingBar(),
        ],
      ),
    );
  }

  void _showSongMenu(String id) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add_rounded),
              title: const Text('添加到歌单'),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('分享'),
              onTap: () {
                Navigator.pop(ctx);
              },
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
