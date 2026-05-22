import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../models/recording_model.dart';
import '../services/storage_service.dart';

class AudioRecorderProvider extends ChangeNotifier {
  final AudioRecorder _recorder = AudioRecorder();
  List<RecordingModel> _recordings = [];
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordDuration = Duration.zero;
  Timer? _timer;
  String? _currentFilePath;

  List<RecordingModel> get recordings => _recordings;
  bool get isRecording => _isRecording;
  bool get isPaused => _isPaused;
  Duration get recordDuration => _recordDuration;

  Future<void> loadRecordings() async {
    _recordings = await StorageService.getAllRecordings();
    notifyListeners();
  }

  Future<bool> startRecording() async {
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) return false;

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      _currentFilePath = '${dir.path}/recording_$timestamp.m4a';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _currentFilePath!,
      );

      _isRecording = true;
      _isPaused = false;
      _recordDuration = Duration.zero;
      _startTimer();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Start recording error: $e');
      return false;
    }
  }

  Future<void> pauseRecording() async {
    if (!_isRecording) return;
    await _recorder.pause();
    _isPaused = true;
    _timer?.cancel();
    notifyListeners();
  }

  Future<void> resumeRecording() async {
    if (!_isPaused) return;
    await _recorder.resume();
    _isPaused = false;
    _startTimer();
    notifyListeners();
  }

  Future<RecordingModel?> stopRecording() async {
    if (!_isRecording) return null;

    _timer?.cancel();
    final path = await _recorder.stop();
    _isRecording = false;
    _isPaused = false;

    if (path == null || !File(path).existsSync()) {
      notifyListeners();
      return null;
    }

    final file = File(path);
    final recording = RecordingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: '录音 ${DateTime.now().toString().substring(5, 19).replaceAll(':', '-')}',
      filePath: path,
      duration: _recordDuration,
      fileSize: await file.length(),
    );

    _recordings.insert(0, recording);
    await StorageService.insertRecording(recording);
    notifyListeners();
    return recording;
  }

  Future<void> deleteRecording(String id) async {
    final recording = _recordings.firstWhere((r) => r.id == id);
    final file = File(recording.filePath);
    if (await file.exists()) await file.delete();
    _recordings.removeWhere((r) => r.id == id);
    await StorageService.deleteRecording(id);
    notifyListeners();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _recordDuration += const Duration(seconds: 1);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}
