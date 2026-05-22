import 'dart:async';
import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import '../models/song_model.dart';

enum PlaybackState { idle, loading, playing, paused, error }

class MediaService {
  final AudioPlayer _player = AudioPlayer();
  SongModel? _currentSong;

  final currentSongNotifier = ValueNotifier<SongModel?>(null);
  final positionNotifier = ValueNotifier<Duration>(Duration.zero);
  final durationNotifier = ValueNotifier<Duration>(Duration.zero);
  final isPlayingNotifier = ValueNotifier<bool>(false);
  final volumeNotifier = ValueNotifier<double>(1.0);
  final loopModeNotifier = ValueNotifier<LoopMode>(LoopMode.off);
  final playbackStateNotifier = ValueNotifier<PlaybackState>(PlaybackState.idle);
  final errorMessageNotifier = ValueNotifier<String?>(null);

  StreamSubscription? _positionSub;
  StreamSubscription? _playerStateSub;
  StreamSubscription? _durationSub;

  SongModel? get currentSong => _currentSong;
  AudioPlayer get player => _player;

  MediaService() {
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playback,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.music,
        usage: AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
    ));
    _setupListeners();
  }

  void _setupListeners() {
    _positionSub = _player.positionStream.listen((pos) {
      positionNotifier.value = pos;
    });

    _playerStateSub = _player.playerStateStream.listen((state) {
      isPlayingNotifier.value = state.playing;
      switch (state.processingState) {
        case ProcessingState.idle:
          playbackStateNotifier.value = PlaybackState.idle;
        case ProcessingState.loading:
        case ProcessingState.buffering:
          playbackStateNotifier.value = PlaybackState.loading;
        case ProcessingState.ready:
          playbackStateNotifier.value =
              state.playing ? PlaybackState.playing : PlaybackState.paused;
          errorMessageNotifier.value = null;
        case ProcessingState.completed:
          playbackStateNotifier.value = PlaybackState.idle;
          isPlayingNotifier.value = false;
      }
    });

    _durationSub = _player.durationStream.listen((dur) {
      if (dur != null && dur > Duration.zero) {
        durationNotifier.value = dur;
      }
    });

    _player.playbackEventStream.listen((event) {
      final err = event.dataSourceException;
      if (err != null) {
        errorMessageNotifier.value = _describeError(err);
        playbackStateNotifier.value = PlaybackState.error;
      }
    });
  }

  String _describeError(dynamic error) {
    final msg = error.toString().toLowerCase();
    if (msg.contains('404') || msg.contains('not found')) return '歌曲链接不存在 (404)';
    if (msg.contains('403') || msg.contains('forbidden')) return '歌曲链接被拒绝 (403)';
    if (msg.contains('timeout') || msg.contains('timed out')) return '连接超时，请检查网络';
    if (msg.contains('dns')) return 'DNS 解析失败';
    if (msg.contains('ssl') || msg.contains('certificate')) return 'SSL 连接错误';
    if (msg.contains('no such host') || msg.contains('host')) return '无法连接到服务器';
    if (msg.contains('cancelled')) return '已取消';
    return '播放失败: $error';
  }

  Future<void> playSong(SongModel song) async {
    _currentSong = song;
    currentSongNotifier.value = song;
    errorMessageNotifier.value = null;
    playbackStateNotifier.value = PlaybackState.loading;

    try {
      if (song.isLocal && song.filePath != null && File(song.filePath!).existsSync()) {
        await _player.setFilePath(song.filePath!);
      } else if (song.url != null && song.url!.isNotEmpty) {
        await _player.setAudioSource(
          AudioSource.uri(Uri.parse(song.url!), tag: song),
        );
      } else {
        errorMessageNotifier.value = '没有可播放的链接';
        playbackStateNotifier.value = PlaybackState.error;
        return;
      }
      await _player.play();
    } catch (e) {
      playbackStateNotifier.value = PlaybackState.error;
      errorMessageNotifier.value = _describeError(e);
    }
  }

  Future<void> playUrl(String url) async {
    errorMessageNotifier.value = null;
    playbackStateNotifier.value = PlaybackState.loading;
    try {
      await _player.setAudioSource(AudioSource.uri(Uri.parse(url)));
      await _player.play();
    } catch (e) {
      playbackStateNotifier.value = PlaybackState.error;
      errorMessageNotifier.value = _describeError(e);
    }
  }

  Future<void> togglePlay() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      if (_currentSong == null && _player.sequenceState == null) return;
      await _player.play();
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume);
    volumeNotifier.value = volume;
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  void toggleLoopMode() {
    final modes = [LoopMode.off, LoopMode.one, LoopMode.all];
    final next = modes[(modes.indexOf(loopModeNotifier.value) + 1) % modes.length];
    _player.setLoopMode(next);
    loopModeNotifier.value = next;
  }

  Duration get position => _player.position;
  Duration get duration => _player.duration ?? Duration.zero;
  bool get isPlaying => _player.playing;

  Future<void> stop() async {
    await _player.stop();
    _currentSong = null;
    currentSongNotifier.value = null;
    isPlayingNotifier.value = false;
    playbackStateNotifier.value = PlaybackState.idle;
    errorMessageNotifier.value = null;
  }

  void dispose() {
    _positionSub?.cancel();
    _playerStateSub?.cancel();
    _durationSub?.cancel();
    _player.dispose();
  }
}
