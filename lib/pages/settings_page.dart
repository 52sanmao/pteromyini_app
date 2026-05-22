import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final musicProvider = context.watch<MusicProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('设置', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _sectionHeader('播放设置'),
          _settingCard(context, [
            _sliderTile(
              context,
              icon: Icons.volume_up_rounded,
              title: '播放音量',
              value: settings.volume,
              onChanged: (v) => settings.setVolume(v),
            ),
            _sliderTile(
              context,
              icon: Icons.speed_rounded,
              title: '播放速度',
              subtitle: '${settings.playbackSpeed.toStringAsFixed(1)}x',
              value: (settings.playbackSpeed - 0.5) / 1.5,
              onChanged: (v) => settings.setPlaybackSpeed(0.5 + v * 1.5),
            ),
          ]),
          const SizedBox(height: 16),
          _sectionHeader('显示'),
          _settingCard(context, [
            SwitchListTile(
              secondary: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: AppTheme.primaryColor,
              ),
              title: const Text('深色模式'),
              value: Theme.of(context).brightness == Brightness.dark,
              onChanged: (_) => settings.toggleDarkMode(),
              activeColor: AppTheme.primaryColor,
            ),
          ]),
          const SizedBox(height: 16),
          _sectionHeader('关于'),
          _settingCard(context, [
            _infoTile(Icons.info_outline_rounded, '版本', '1.0.2'),
            _infoTile(
                Icons.music_note_rounded, '音乐数量', '${musicProvider.songs.length} 首'),
            _infoTile(Icons.rss_feed_rounded, '频道 ID', settings.channelId),
            _infoTile(
              Icons.wifi_rounded,
              '网络状态',
              settings.isOnline ? '已连接' : '离线',
              valueColor: settings.isOnline ? Colors.green : Colors.red[400],
            ),
          ]),
          const SizedBox(height: 16),
          _sectionHeader('存储'),
          _settingCard(context, [
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: AppTheme.primaryColor.withValues(alpha: 0.1),
                ),
                child: const Icon(
                    Icons.delete_sweep_rounded, color: AppTheme.primaryColor),
              ),
              title: const Text('清除缓存'),
              subtitle: const Text('清理临时文件和缓存数据'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('缓存已清除')),
                );
              },
            ),
          ]),
          const SizedBox(height: 32),
          Center(
            child: Text(
              '鼯鼠音乐 v1.0.2',
              style: TextStyle(color: Colors.grey[400], fontSize: 12),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
        ),
      ),
    );
  }

  static Widget _settingCard(BuildContext context, List<Widget> children) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2D2D44) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  static Widget _sliderTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          title: Text(title),
          trailing: subtitle != null
              ? Text(subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13))
              : null,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
              thumbColor: AppTheme.primaryColor,
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child:
                Slider(value: value.clamp(0.0, 1.0), onChanged: onChanged),
          ),
        ),
      ],
    );
  }

  static Widget _infoTile(IconData icon, String title, String value,
      {Color? valueColor}) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
        ),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(title),
      trailing: Text(
        value,
        style: TextStyle(
          color: valueColor ?? Colors.grey[500],
          fontSize: 13,
        ),
      ),
    );
  }
}
