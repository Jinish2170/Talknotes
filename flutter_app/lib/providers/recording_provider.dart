import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../services/note_service.dart';
import '../models/note.dart';
import '../providers/notes_provider.dart';

enum RecordingState { idle, recording, stopped, processing }

class RecordingProvider extends ChangeNotifier {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final NoteService _noteService = NoteService();

  RecordingState _recordingState = RecordingState.idle;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String? _recordingPath;
  String _transcriptionText = '';
  double _transcriptionConfidence = 0.0;

  // Dependencies that will be injected
  NotesProvider? _notesProvider;

  // Maximum recording duration (1 minute)
  static const Duration maxRecordingDuration = Duration(minutes: 1);

  RecordingProvider() {
    debugPrint('🎤 RecordingProvider initialized');
  }

  // Getters
  RecordingState get recordingState => _recordingState;
  Duration get recordingDuration => _recordingDuration;
  bool get isRecording => _recordingState == RecordingState.recording;
  bool get isProcessing => _recordingState == RecordingState.processing;
  String? get recordingPath => _recordingPath;
  String get transcriptionText => _transcriptionText;
  double get transcriptionConfidence => _transcriptionConfidence;

  // Set notes provider dependency
  void setNotesProvider(NotesProvider notesProvider) {
    _notesProvider = notesProvider;
  }

  Future<void> startRecording() async {
    try {
      debugPrint('🎤 RecordingProvider: Attempting to start recording...');
      debugPrint('🎤 RecordingProvider: Current state = $_recordingState');

      // Check if device supports recording
      final hasPermission = await _audioRecorder.hasPermission();
      debugPrint('🎤 RecordingProvider: hasPermission() = $hasPermission');

      if (hasPermission) {
        debugPrint(
          '🎤 RecordingProvider: Permission granted, setting up recording...',
        );

        // Get temporary directory for recording
        final directory = await getTemporaryDirectory();
        final fileName =
            'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _recordingPath = '${directory.path}/$fileName';

        debugPrint('🎤 RecordingProvider: Recording to: $_recordingPath');

        // Configure recording settings
        const config = RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );

        // Start recording
        debugPrint('🎤 RecordingProvider: Starting audio recorder...');
        await _audioRecorder.start(config, path: _recordingPath!);

        _recordingState = RecordingState.recording;
        _recordingDuration = Duration.zero;

        // Start timer to track recording duration
        _startRecordingTimer();

        notifyListeners();

        debugPrint(
          '🎤 RecordingProvider: Recording started successfully: $_recordingPath',
        );
      } else {
        debugPrint('🎤 RecordingProvider: Microphone permission not granted');
        throw Exception('Microphone permission not granted');
      }
    } catch (e) {
      debugPrint('❌ RecordingProvider: Error starting recording: $e');
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

    bool backendSuccess = false;
    String? errorMessage;

    try {
      if (_recordingPath != null) {
        debugPrint('🔄 Starting transcription for: $_recordingPath');

        // Validate audio file first
        final audioFile = File(_recordingPath!);
        if (!await audioFile.exists()) {
          throw Exception('Audio file not found');
        }

        final fileSize = await audioFile.length();
        if (fileSize > 25 * 1024 * 1024) {
          throw Exception('File too large. Maximum size is 25MB.');
        }

        debugPrint('📤 Processing audio with backend...');

        try {
          // Process the audio for transcription using backend API
          final processResult = await _noteService.processAudioNote(
            audioFile: audioFile,
            styleName: 'default',
          );

          debugPrint('🔄 Process result: $processResult');

          if (processResult['STATUS'] == 1 ||
              processResult['success'] == true) {
            final result = processResult['RESULT'] ?? processResult;
            _transcriptionText =
                result['audioTranscription'] ??
                result['audio_transcription'] ??
                result['transcription'] ??
                '';
            _transcriptionConfidence = 0.85;

            debugPrint(
              '✅ Transcription completed: ${_transcriptionText.length} characters',
            );

            // Now save the audio note to backend
            final saveResult = await _noteService.saveAudioNote(
              audioFile: audioFile,
              noteTitle: _generateNoteTitle(_transcriptionText),
              noteStyle: 'default',
              audioTranscription: _transcriptionText,
              textNote: result['textNote'] ?? result['text_note'] ?? '',
              aiNote: result['aiNote'] ?? result['ai_note'] ?? '',
            );

            debugPrint('💾 Save result: $saveResult');

            // Create a local note and save it
            if (_notesProvider != null) {
              final savedData = saveResult['RESULT'] ?? saveResult;
              final note = Note(
                id:
                    savedData['_id']?.toString() ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                title: _generateNoteTitle(_transcriptionText),
                transcription: _transcriptionText,
                audioPath:
                    savedData['audioUrl'] ??
                    savedData['audio_url'] ??
                    _recordingPath!,
                duration: _recordingDuration,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
                isProcessing: false,
                tags: _extractTags(_transcriptionText),
                textNote: result['textNote'] ?? result['text_note'],
                aiNote: result['aiNote'] ?? result['ai_note'],
                audioPublicId:
                    savedData['audioPublicId'] ?? savedData['audio_public_id'],
              );

              await _notesProvider!.addNote(note);
              debugPrint('💾 Note saved successfully');
              backendSuccess = true;
            }
          } else {
            errorMessage =
                processResult['MESSAGE'] ?? 'Backend processing failed';
            throw Exception(errorMessage);
          }
        } catch (e) {
          debugPrint('⚠️ Backend processing failed: $e');
          errorMessage = _getReadableError(e.toString());
          // Continue to save locally
        }

        // If backend failed, save note locally with audio path
        if (!backendSuccess && _notesProvider != null) {
          debugPrint('💾 Saving note locally (backend unavailable)...');
          final note = Note(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'Voice Note ${DateTime.now().day}/${DateTime.now().month}',
            transcription: errorMessage != null
                ? '⏳ Pending transcription (saved offline)'
                : '',
            audioPath: _recordingPath!,
            duration: _recordingDuration,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isProcessing: true, // Mark as needing processing
            tags: ['offline'],
          );
          await _notesProvider!.addNote(note);
          debugPrint('💾 Note saved locally');
          _transcriptionText = note.transcription;
        }
      }
    } catch (e) {
      debugPrint('❌ Error processing recording: $e');
      _transcriptionText = '⏳ Pending transcription';
      _transcriptionConfidence = 0.0;

      // Still save the note locally even if everything fails
      if (_notesProvider != null && _recordingPath != null) {
        final note = Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Voice Note ${DateTime.now().day}/${DateTime.now().month}',
          transcription: '⏳ Pending transcription',
          audioPath: _recordingPath!,
          duration: _recordingDuration,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isProcessing: true,
          tags: ['offline'],
        );
        await _notesProvider!.addNote(note);
        debugPrint('💾 Note saved locally (error recovery)');
      }
    }

    _recordingState = RecordingState.stopped;
    notifyListeners();
  }

  String _getReadableError(String error) {
    if (error.contains('SocketException') ||
        error.contains('Connection refused')) {
      return 'Server unavailable - note saved offline';
    } else if (error.contains('TimeoutException')) {
      return 'Connection timeout - note saved offline';
    } else if (error.contains('bad response')) {
      return 'Server error - note saved offline';
    }
    return 'Processing failed - note saved offline';
  }

  String _generateNoteTitle(String transcription) {
    if (transcription.isEmpty) {
      return 'Voice Note ${DateTime.now().day}/${DateTime.now().month}';
    }

    // Take first sentence or first 30 characters as title
    final sentences = transcription.split(RegExp(r'[.!?]'));
    if (sentences.isNotEmpty && sentences.first.trim().isNotEmpty) {
      final title = sentences.first.trim();
      return title.length > 30 ? '${title.substring(0, 30)}...' : title;
    }

    return transcription.length > 30
        ? '${transcription.substring(0, 30)}...'
        : transcription;
  }

  List<String> _extractTags(String transcription) {
    // Simple tag extraction based on keywords
    final tags = <String>[];
    final lowerText = transcription.toLowerCase();

    // Common categories
    if (lowerText.contains(RegExp(r'\b(meeting|call|conference)\b'))) {
      tags.add('meeting');
    }
    if (lowerText.contains(RegExp(r'\b(idea|think|thought)\b'))) {
      tags.add('idea');
    }
    if (lowerText.contains(RegExp(r'\b(todo|task|remind)\b'))) {
      tags.add('todo');
    }
    if (lowerText.contains(RegExp(r'\b(important|urgent|critical)\b'))) {
      tags.add('important');
    }
    if (lowerText.contains(RegExp(r'\b(project|work)\b'))) {
      tags.add('work');
    }
    if (lowerText.contains(RegExp(r'\b(personal|family)\b'))) {
      tags.add('personal');
    }

    return tags;
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
