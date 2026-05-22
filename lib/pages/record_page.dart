import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_recorder_provider.dart';
import '../utils/theme.dart';

class RecordPage extends StatefulWidget {
  const RecordPage({super.key});

  @override
  State<RecordPage> createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioRecorderProvider>().loadRecordings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AudioRecorderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('录音', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // Recording control panel
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                  AppTheme.accentColor.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              children: [
                // Timer
                Text(
                  _formatDuration(provider.recordDuration),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w300,
                    color: provider.isRecording
                        ? AppTheme.primaryColor
                        : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.isRecording
                      ? (provider.isPaused ? '已暂停' : '录音中...')
                      : '点击开始录音',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 24),
                // Record controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (provider.isRecording)
                      GestureDetector(
                        onTap: () => provider.stopRecording(),
                        child: _controlButton(Icons.stop_rounded, Colors.red[400]!),
                      ),
                    const SizedBox(width: 24),
                    GestureDetector(
                      onTap: () async {
                        if (provider.isRecording) {
                          if (provider.isPaused) {
                            await provider.resumeRecording();
                          } else {
                            await provider.pauseRecording();
                          }
                        } else {
                          await provider.startRecording();
                        }
                      },
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: provider.isRecording ? Colors.orange : AppTheme.primaryColor,
                          boxShadow: [
                            BoxShadow(
                              color: (provider.isRecording ? Colors.orange : AppTheme.primaryColor)
                                  .withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          provider.isRecording
                              ? (provider.isPaused ? Icons.mic_rounded : Icons.pause_rounded)
                              : Icons.mic_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    if (provider.isRecording)
                      const SizedBox(width: 24),
                    if (provider.isRecording)
                      GestureDetector(
                        onTap: () => provider.stopRecording(),
                        child: _controlButton(Icons.check_rounded, Colors.green),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Recordings list
          Expanded(
            child: provider.recordings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mic_none_rounded,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          '暂无录音记录',
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: provider.recordings.length,
                    itemBuilder: (_, i) {
                      final rec = provider.recordings[i];
                      return Dismissible(
                        key: Key(rec.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          color: Colors.red[400],
                          child: const Icon(Icons.delete_rounded, color: Colors.white),
                        ),
                        onDismissed: (_) => provider.deleteRecording(rec.id),
                        child: ListTile(
                          leading: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            ),
                            child: Icon(
                            Icons.graphic_eq_rounded,
                            color: AppTheme.primaryColor,
                          ),
                          ),
                          title: Text(
                            rec.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text('${rec.formattedDuration}  ·  ${rec.formattedSize}'),
                          trailing: Icon(Icons.play_circle_outline_rounded,
                              color: Colors.grey[400]),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _controlButton(IconData icon, Color color) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.1),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
