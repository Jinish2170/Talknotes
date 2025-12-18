import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../configs/network_config.dart';
import '../constants/api_endpoints.dart';
import '../models/note.dart';

class NoteService {
  final Dio _dio = NetworkConfig.dio;

  // Create a new text note
  Future<Map<String, dynamic>> createNote({
    required String noteTitle,
    required String noteStyle,
    String textNote = '',
    String audioTranscription = '',
    String aiNote = '',
  }) async {
    try {
      debugPrint('📝 NoteService: Creating note - $noteTitle');

      final response = await _dio.post(
        ApiEndpoints.userCreateNote,
        data: {
          'note_title': noteTitle,
          'note_style': noteStyle,
          'text_note': textNote,
          'audio_transcription': audioTranscription,
          'ai_note': aiNote,
        },
      );

      debugPrint('📝 NoteService: Note created successfully');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ NoteService: Create note error - ${e.message}');
      rethrow;
    }
  }

  // Get all notes
  Future<List<Note>> getNotes() async {
    try {
      debugPrint('📝 NoteService: Fetching all notes');

      final response = await _dio.get(ApiEndpoints.userGetNotes);

      if (response.data['STATUS'] == 1 && response.data['RESULT'] != null) {
        final List<dynamic> notesJson = response.data['RESULT'];
        final notes = notesJson
            .map((json) => Note.fromBackendJson(json))
            .toList();
        debugPrint('📝 NoteService: Fetched ${notes.length} notes');
        return notes;
      }

      return [];
    } on DioException catch (e) {
      debugPrint('❌ NoteService: Get notes error - ${e.message}');
      rethrow;
    }
  }

  // Update an existing note
  Future<Map<String, dynamic>> updateNote({
    required String noteId,
    String? noteTitle,
    String? noteStyle,
    String? textNote,
    String? audioTranscription,
    String? aiNote,
  }) async {
    try {
      debugPrint('📝 NoteService: Updating note - $noteId');

      final Map<String, dynamic> data = {};
      if (noteTitle != null) data['note_title'] = noteTitle;
      if (noteStyle != null) data['note_style'] = noteStyle;
      if (textNote != null) data['text_note'] = textNote;
      if (audioTranscription != null) {
        data['audio_transcription'] = audioTranscription;
      }
      if (aiNote != null) data['ai_note'] = aiNote;

      final response = await _dio.put(
        '${ApiEndpoints.userUpdateNote}/$noteId',
        data: data,
      );

      debugPrint('📝 NoteService: Note updated successfully');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ NoteService: Update note error - ${e.message}');
      rethrow;
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      debugPrint('📝 NoteService: Deleting note - $noteId');

      await _dio.delete('${ApiEndpoints.userDeleteNote}/$noteId');

      debugPrint('📝 NoteService: Note deleted successfully');
    } on DioException catch (e) {
      debugPrint('❌ NoteService: Delete note error - ${e.message}');
      rethrow;
    }
  }

  // Save audio note (upload audio to cloudinary and create note)
  Future<Map<String, dynamic>> saveAudioNote({
    required File audioFile,
    required String noteTitle,
    required String noteStyle,
    String textNote = '',
    String audioTranscription = '',
    String aiNote = '',
  }) async {
    try {
      debugPrint('🎤 NoteService: Saving audio note - $noteTitle');
      debugPrint('🎤 NoteService: Audio file path - ${audioFile.path}');

      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.path.split('/').last,
        ),
        'note_title': noteTitle,
        'note_style': noteStyle,
        'text_note': textNote,
        'audio_transcription': audioTranscription,
        'ai_note': aiNote,
      });

      final response = await _dio.post(
        ApiEndpoints.userSaveAudioNote,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      debugPrint('🎤 NoteService: Audio note saved successfully');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ NoteService: Save audio note error - ${e.message}');
      rethrow;
    }
  }

  // Process audio note (transcribe and generate AI content)
  Future<Map<String, dynamic>> processAudioNote({
    required File audioFile,
    required String styleName,
  }) async {
    try {
      debugPrint(
        '🤖 NoteService: Processing audio note with style - $styleName',
      );
      debugPrint('🤖 NoteService: Audio file path - ${audioFile.path}');

      final formData = FormData.fromMap({
        'audioFile': await MultipartFile.fromFile(
          audioFile.path,
          filename: audioFile.path.split('/').last,
        ),
        'styleName': styleName,
      });

      final response = await _dio.post(
        ApiEndpoints.userProcessAudioNote,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      debugPrint('🤖 NoteService: Audio note processed successfully');
      debugPrint('🤖 NoteService: Response - ${response.data}');
      return response.data;
    } on DioException catch (e) {
      debugPrint('❌ NoteService: Process audio note error - ${e.message}');
      rethrow;
    }
  }

  // Get available note styles
  Future<List<Map<String, dynamic>>> getNoteStyles() async {
    try {
      debugPrint('🎨 NoteService: Fetching note styles');

      final response = await _dio.get(ApiEndpoints.userGetNoteStyles);

      if (response.data['STATUS'] == 1 && response.data['RESULT'] != null) {
        final List<dynamic> stylesJson = response.data['RESULT'];
        debugPrint('🎨 NoteService: Fetched ${stylesJson.length} styles');
        return stylesJson.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      return [];
    } on DioException catch (e) {
      debugPrint('❌ NoteService: Get note styles error - ${e.message}');
      rethrow;
    }
  }
}
