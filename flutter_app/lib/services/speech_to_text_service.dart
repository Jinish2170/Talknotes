import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../configs/network_config.dart';

class SpeechToTextService {
  final Dio _dio = NetworkConfig.dio;

  // Convert audio file to text using backend API
  Future<Map<String, dynamic>> transcribeAudio(String audioFilePath) async {
    try {
      debugPrint('🎤 Starting transcription for: $audioFilePath');

      // Check if file exists
      final audioFile = File(audioFilePath);
      if (!await audioFile.exists()) {
        throw Exception('Audio file not found: $audioFilePath');
      }

      // Prepare form data for file upload
      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFilePath,
          filename: audioFilePath.split('/').last,
        ),
        'language': 'en-US', // Default language
        'model': 'whisper-1', // Use OpenAI Whisper model
      });

      // Send request to backend
      final response = await _dio.post(
        '/api/audio/transcribe',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          receiveTimeout: const Duration(
            minutes: 5,
          ), // Allow longer processing time
          sendTimeout: const Duration(minutes: 2),
        ),
      );

      debugPrint('✅ Transcription response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': true,
          'transcription': data['transcription'] ?? '',
          'confidence': data['confidence'] ?? 0.0,
          'language': data['language'] ?? 'en-US',
          'duration': data['duration'] ?? 0,
          'processingTime': data['processingTime'] ?? 0,
        };
      } else {
        throw Exception(
          'Transcription failed with status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException in transcription: ${e.message}');
      debugPrint('   Response: ${e.response?.data}');

      if (e.response?.statusCode == 413) {
        throw Exception(
          'Audio file is too large. Please record a shorter note.',
        );
      } else if (e.response?.statusCode == 415) {
        throw Exception('Unsupported audio format. Please try again.');
      } else if (e.response?.statusCode == 429) {
        throw Exception(
          'Too many requests. Please wait a moment and try again.',
        );
      } else {
        throw Exception('Transcription service error: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ Unexpected error in transcription: $e');
      throw Exception('Failed to transcribe audio: ${e.toString()}');
    }
  }

  // Get supported languages from backend
  Future<List<Map<String, String>>> getSupportedLanguages() async {
    try {
      final response = await _dio.get('/api/audio/languages');

      if (response.statusCode == 200) {
        final List<dynamic> languages = response.data['languages'] ?? [];
        return languages
            .map(
              (lang) => {
                'code': lang['code'].toString(),
                'name': lang['name'].toString(),
              },
            )
            .toList();
      } else {
        throw Exception('Failed to get supported languages');
      }
    } catch (e) {
      debugPrint('❌ Error getting supported languages: $e');
      // Return default languages if API fails
      return [
        {'code': 'en-US', 'name': 'English (US)'},
        {'code': 'en-GB', 'name': 'English (UK)'},
        {'code': 'es-ES', 'name': 'Spanish'},
        {'code': 'fr-FR', 'name': 'French'},
        {'code': 'de-DE', 'name': 'German'},
        {'code': 'it-IT', 'name': 'Italian'},
        {'code': 'pt-BR', 'name': 'Portuguese'},
        {'code': 'ru-RU', 'name': 'Russian'},
        {'code': 'ja-JP', 'name': 'Japanese'},
        {'code': 'ko-KR', 'name': 'Korean'},
        {'code': 'zh-CN', 'name': 'Chinese (Simplified)'},
      ];
    }
  }

  // Check transcription service status
  Future<Map<String, dynamic>> getServiceStatus() async {
    try {
      final response = await _dio.get('/api/audio/status');

      if (response.statusCode == 200) {
        return {
          'available': response.data['available'] ?? false,
          'model': response.data['model'] ?? 'unknown',
          'version': response.data['version'] ?? '1.0.0',
          'maxFileSize':
              response.data['maxFileSize'] ?? 25 * 1024 * 1024, // 25MB default
          'supportedFormats':
              response.data['supportedFormats'] ?? ['m4a', 'mp3', 'wav'],
        };
      } else {
        throw Exception('Failed to get service status');
      }
    } catch (e) {
      debugPrint('❌ Error getting service status: $e');
      return {'available': false, 'error': e.toString()};
    }
  }

  // Convert text to speech (TTS) - for future feature
  Future<String?> textToSpeech(String text, {String language = 'en-US'}) async {
    try {
      debugPrint(
        '🔊 Converting text to speech: ${text.substring(0, text.length.clamp(0, 50))}...',
      );

      final response = await _dio.post(
        '/api/audio/text-to-speech',
        data: {'text': text, 'language': language, 'voice': 'default'},
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      if (response.statusCode == 200) {
        // Save audio data to file
        final audioData = response.data as List<int>;
        final fileName = 'tts_${DateTime.now().millisecondsSinceEpoch}.mp3';

        // This would save to temporary directory
        // Implementation depends on where you want to store TTS files

        debugPrint('✅ Text-to-speech conversion completed');
        return fileName;
      } else {
        throw Exception('TTS failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error in text-to-speech: $e');
      rethrow;
    }
  }

  // Validate audio file before transcription
  Future<Map<String, dynamic>> validateAudioFile(String audioFilePath) async {
    try {
      final file = File(audioFilePath);

      if (!await file.exists()) {
        return {'valid': false, 'error': 'File does not exist'};
      }

      final fileStat = await file.stat();
      final fileSize = fileStat.size;

      // Check file size (max 25MB)
      const maxFileSize = 25 * 1024 * 1024;
      if (fileSize > maxFileSize) {
        return {
          'valid': false,
          'error': 'File too large. Maximum size is 25MB.',
          'currentSize': fileSize,
          'maxSize': maxFileSize,
        };
      }

      // Check file extension
      final supportedFormats = ['m4a', 'mp3', 'wav', 'aac', 'ogg'];
      final extension = audioFilePath.toLowerCase().split('.').last;

      if (!supportedFormats.contains(extension)) {
        return {
          'valid': false,
          'error':
              'Unsupported format. Supported: ${supportedFormats.join(', ')}',
          'currentFormat': extension,
          'supportedFormats': supportedFormats,
        };
      }

      return {
        'valid': true,
        'fileSize': fileSize,
        'format': extension,
        'duration': null, // Could be determined by audio analysis
      };
    } catch (e) {
      return {'valid': false, 'error': 'Validation error: ${e.toString()}'};
    }
  }

  // Get transcription history (if backend supports it)
  Future<List<Map<String, dynamic>>> getTranscriptionHistory() async {
    try {
      final response = await _dio.get('/api/audio/history');

      if (response.statusCode == 200) {
        final List<dynamic> history = response.data['history'] ?? [];
        return history.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Failed to get transcription history');
      }
    } catch (e) {
      debugPrint('❌ Error getting transcription history: $e');
      return [];
    }
  }
}
