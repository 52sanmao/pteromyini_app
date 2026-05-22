import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../models/playlist_model.dart';
import '../widgets/song_tile.dart';
import '../widgets/playlist_card.dart';
import '../widgets/now_playing_bar.dart';
import '../utils/theme.dart';

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
      context.read<MusicProvider>().initialize().then((_) {
        context.read<MusicProvider>().importLocalSongs();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '鼯鼠音乐',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
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
                      // Recommended playlists
                      SliverToBoxAdapter(
                        child: _buildSectionHeader('推荐歌单'),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: provider.playlists.isNotEmpty
                                ? provider.playlists.length
                                : 3,
                            itemBuilder: (_, i) {
                              if (provider.playlists.isEmpty) {
                                final dummyNames = ['每日推荐', '最近播放', '我的收藏'];
                                return PlaylistCard(
                                  playlist: PlaylistModel(
                                    id: 'dummy_$i',
                                    name: dummyNames[i],
                                  ),
                                  onTap: () {},
                                );
                              }
                              final p = provider.playlists[i];
                              return PlaylistCard(
                                playlist: p,
                                songCount: p.songIds.length,
                                onTap: () {},
                              );
                            },
                          ),
                        ),
                      ),
                      // Recent songs
                      SliverToBoxAdapter(
                        child: _buildSectionHeader('最近播放'),
                      ),
                      if (provider.songs.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.music_note_rounded, size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                Text(
                                  '暂无音乐',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '在音乐库中添加本地音乐',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[400],
                                  ),
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
                                isPlaying: provider.mediaService.currentSong?.id == song.id &&
                                    provider.mediaService.isPlaying,
                                onTap: () => provider.playSong(song),
                              );
                            },
                            childCount: provider.songs.length,
                          ),
                        ),
                      // Bottom padding for now-playing bar
                      const SliverToBoxAdapter(child: SizedBox(height: 80)),
                    ],
                  ),
                ),
                // Now playing bar
                const NowPlayingBar(),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '查看全部',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
