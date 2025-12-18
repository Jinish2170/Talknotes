import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

enum RecordingState {
  idle,
  recording,
  stopped,
  processing,
}

class RecordingProvider extends ChangeNotifier {
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  RecordingState _recordingState = RecordingState.idle;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String? _recordingPath;
  
  // Maximum recording duration (1 minute)
  static const Duration maxRecordingDuration = Duration(minutes: 1);
  
  // Getters
  RecordingState get recordingState => _recordingState;
  Duration get recordingDuration => _recordingDuration;
  bool get isRecording => _recordingState == RecordingState.recording;
  String? get recordingPath => _recordingPath;
  
  Future<void> startRecording() async {
    try {
      // Check if device supports recording
      if (await _audioRecorder.hasPermission()) {
        // Get temporary directory for recording
        final directory = await getTemporaryDirectory();
        final fileName = 'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _recordingPath = '${directory.path}/$fileName';
        
        // Configure recording settings
        const config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );
        
        // Start recording
        await _audioRecorder.start(config, path: _recordingPath!);
        
        _recordingState = RecordingState.recording;
        _recordingDuration = Duration.zero;
        
        // Start timer to track recording duration
        _startRecordingTimer();
        
        notifyListeners();
        
        debugPrint('🎤 Recording started: $_recordingPath');
      } else {
        throw Exception('Microphone permission not granted');
      }
    } catch (e) {
      debugPrint('❌ Error starting recording: $e');
      _recordingState = RecordingState.idle;
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> stopRecording() async {
    try {
      if (_recordingState == RecordingState.recording) {
        // Stop the recording
        final path = await _audioRecorder.stop();
        _stopRecordingTimer();
        
        _recordingState = RecordingState.stopped;
        _recordingPath = path;
        
        notifyListeners();
        
        debugPrint('🎤 Recording stopped: $path');
        debugPrint('🎤 Duration: ${_recordingDuration.inSeconds} seconds');
        
        // Simulate processing (for now just wait a bit)
        await _processRecording();
      }
    } catch (e) {
      debugPrint('❌ Error stopping recording: $e');
      _recordingState = RecordingState.idle;
      notifyListeners();
      rethrow;
    }
  }
  
  Future<void> _processRecording() async {
    _recordingState = RecordingState.processing;
    notifyListeners();
    
    // TODO: Here we'll integrate with speech-to-text API
    // For now, just simulate processing time
    await Future.delayed(const Duration(seconds: 2));
    
    _recordingState = RecordingState.stopped;
    notifyListeners();
  }
  
  void _startRecordingTimer() {
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _recordingDuration = Duration(seconds: timer.tick);
      
      // Auto-stop recording at 1 minute limit
      if (_recordingDuration >= maxRecordingDuration) {
        stopRecording();
        return;
      }
      
      notifyListeners();
    });
  }
  
  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }
  
  void resetRecording() {
    _recordingState = RecordingState.idle;
    _recordingDuration = Duration.zero;
    _recordingPath = null;
    _stopRecordingTimer();
    notifyListeners();
  }
  
  Future<void> deleteRecording() async {
    if (_recordingPath != null) {
      try {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
          debugPrint('🗑️ Recording file deleted: $_recordingPath');
        }
      } catch (e) {
        debugPrint('❌ Error deleting recording file: $e');
      }
    }
    resetRecording();
  }
  
  // Get recording file size in bytes
  Future<int?> getRecordingSize() async {
    if (_recordingPath != null) {
      try {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          return await file.length();
        }
      } catch (e) {
        debugPrint('❌ Error getting file size: $e');
      }
    }
    return null;
  }
  
  // Format file size for display
  String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  
  @override
  void dispose() {
    _stopRecordingTimer();
    _audioRecorder.dispose();
    super.dispose();
  }
}
