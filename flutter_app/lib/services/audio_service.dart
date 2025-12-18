import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';

enum AudioPlayerState { stopped, playing, paused, loading, error }

class AudioService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioPlayerState _playerState = AudioPlayerState.stopped;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  String? _currentAudioPath;
  bool _isInitialized = false;

  // Getters
  AudioPlayerState get playerState => _playerState;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  String? get currentAudioPath => _currentAudioPath;
  bool get isPlaying => _playerState == AudioPlayerState.playing;
  bool get isPaused => _playerState == AudioPlayerState.paused;
  bool get isLoading => _playerState == AudioPlayerState.loading;

  // Progress as percentage (0.0 to 1.0)
  double get progress {
    if (_totalDuration.inMilliseconds <= 0) return 0.0;
    return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
  }

  AudioService() {
    _initializePlayer();
  }

  void _initializePlayer() {
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      switch (state) {
        case PlayerState.stopped:
          _playerState = AudioPlayerState.stopped;
          _currentPosition = Duration.zero;
          break;
        case PlayerState.playing:
          _playerState = AudioPlayerState.playing;
          break;
        case PlayerState.paused:
          _playerState = AudioPlayerState.paused;
          break;
        case PlayerState.completed:
          _playerState = AudioPlayerState.stopped;
          _currentPosition = Duration.zero;
          break;
        case PlayerState.disposed:
          _playerState = AudioPlayerState.stopped;
          _currentPosition = Duration.zero;
          break;
      }
      notifyListeners();
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((Duration position) {
      _currentPosition = position;
      notifyListeners();
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      _totalDuration = duration;
      notifyListeners();
    });

    _isInitialized = true;
    debugPrint('🎵 Audio service initialized');
  }

  Future<void> playAudio(String audioPath) async {
    try {
      if (!_isInitialized) {
        _initializePlayer();
      }

      _playerState = AudioPlayerState.loading;
      _currentAudioPath = audioPath;
      notifyListeners();

      // Check if file exists
      final file = File(audioPath);
      if (!await file.exists()) {
        throw Exception('Audio file not found: $audioPath');
      }

      // Play the audio file
      await _audioPlayer.play(DeviceFileSource(audioPath));

      debugPrint('🎵 Playing audio: $audioPath');
    } catch (e) {
      debugPrint('❌ Error playing audio: $e');
      _playerState = AudioPlayerState.error;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      debugPrint('⏸️ Audio paused');
    } catch (e) {
      debugPrint('❌ Error pausing audio: $e');
      rethrow;
    }
  }

  Future<void> resumeAudio() async {
    try {
      await _audioPlayer.resume();
      debugPrint('▶️ Audio resumed');
    } catch (e) {
      debugPrint('❌ Error resuming audio: $e');
      rethrow;
    }
  }

  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _currentPosition = Duration.zero;
      debugPrint('⏹️ Audio stopped');
    } catch (e) {
      debugPrint('❌ Error stopping audio: $e');
      rethrow;
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      debugPrint('⏭️ Seeked to: ${position.inSeconds}s');
    } catch (e) {
      debugPrint('❌ Error seeking audio: $e');
      rethrow;
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      // Clamp volume between 0.0 and 1.0
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(clampedVolume);
      debugPrint('🔊 Volume set to: ${(clampedVolume * 100).toInt()}%');
    } catch (e) {
      debugPrint('❌ Error setting volume: $e');
      rethrow;
    }
  }

  Future<void> setPlaybackSpeed(double speed) async {
    try {
      // Clamp speed between 0.5 and 2.0
      final clampedSpeed = speed.clamp(0.5, 2.0);
      await _audioPlayer.setPlaybackRate(clampedSpeed);
      debugPrint('🏃 Playback speed set to: ${clampedSpeed}x');
    } catch (e) {
      debugPrint('❌ Error setting playback speed: $e');
      rethrow;
    }
  }

  // Get audio file information
  Future<Map<String, dynamic>> getAudioInfo(String audioPath) async {
    try {
      final file = File(audioPath);
      if (!await file.exists()) {
        throw Exception('Audio file not found: $audioPath');
      }

      final fileStat = await file.stat();
      final fileSize = fileStat.size;

      return {
        'path': audioPath,
        'size': fileSize,
        'sizeFormatted': _formatFileSize(fileSize),
        'lastModified': fileStat.modified,
        'exists': true,
      };
    } catch (e) {
      debugPrint('❌ Error getting audio info: $e');
      return {'path': audioPath, 'exists': false, 'error': e.toString()};
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  // Format duration for display
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    } else {
      return '${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
  }

  // Check if audio file is valid
  Future<bool> isValidAudioFile(String audioPath) async {
    try {
      final file = File(audioPath);
      if (!await file.exists()) return false;

      // Check file extension
      final validExtensions = ['.mp3', '.wav', '.m4a', '.aac', '.ogg'];
      final extension = audioPath.toLowerCase().split('.').last;

      return validExtensions.any((ext) => ext.contains(extension));
    } catch (e) {
      debugPrint('❌ Error validating audio file: $e');
      return false;
    }
  }

  // Clean up temporary audio files
  Future<void> cleanupTempFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final tempFiles = tempDir
          .listSync()
          .where(
            (entity) => entity is File && entity.path.contains('voice_note_'),
          )
          .cast<File>();

      for (final file in tempFiles) {
        // Only delete files older than 24 hours
        final fileStat = await file.stat();
        final age = DateTime.now().difference(fileStat.modified);

        if (age.inHours >= 24) {
          await file.delete();
          debugPrint('🧹 Deleted old temp file: ${file.path}');
        }
      }
    } catch (e) {
      debugPrint('❌ Error cleaning temp files: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
