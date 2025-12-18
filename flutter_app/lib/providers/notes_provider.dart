import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../services/note_service.dart';

class NotesProvider extends ChangeNotifier {
  List<Note> _notes = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;
  final NoteService _noteService = NoteService();
  final bool _useBackend = true; // Toggle to switch between local and backend storage

  // Getters
  List<Note> get notes {
    if (_searchQuery.isEmpty) {
      return _notes;
    }
    return _notes.where((note) {
      return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          note.transcription.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          note.tags.any(
            (tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()),
          );
    }).toList();
  }

  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  int get totalNotes => _notes.length;
  String? get error => _error;

  // Load notes - tries backend first, falls back to local storage
  Future<void> loadNotes() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_useBackend) {
        try {
          // Try to fetch from backend
          _notes = await _noteService.getNotes();
          // Also cache locally
          await _saveNotesLocally();
          debugPrint('📝 Loaded ${_notes.length} notes from backend');
        } catch (e) {
          debugPrint('⚠️ Backend unavailable, loading from local storage: $e');
          await _loadNotesLocally();
        }
      } else {
        await _loadNotesLocally();
      }

      // Sort notes by creation date (newest first)
      _notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      debugPrint('❌ Error loading notes: $e');
      notifyListeners();
      rethrow;
    }
  }

  // Load notes from local storage only
  Future<void> _loadNotesLocally() async {
    final notesJson = StorageService.getString('notes');
    if (notesJson != null && notesJson.isNotEmpty) {
      final List<dynamic> notesList = json.decode(notesJson);
      _notes = notesList.map((noteData) => Note.fromJson(noteData)).toList();
      debugPrint('📝 Loaded ${_notes.length} notes from local storage');
    } else {
      _notes = [];
    }
  }

  // Save notes to local storage
  Future<void> _saveNotesLocally() async {
    try {
      final notesJson = json.encode(
        _notes.map((note) => note.toJson()).toList(),
      );
      await StorageService.saveString('notes', notesJson);
      debugPrint('💾 Saved ${_notes.length} notes to local storage');
    } catch (e) {
      debugPrint('❌ Error saving notes locally: $e');
    }
  }

  // Add a new note
  Future<void> addNote(Note note) async {
    try {
      _notes.insert(0, note); // Add to beginning for newest first
      await _saveNotesLocally();
      notifyListeners();
      debugPrint('➕ Added new note: ${note.id}');
    } catch (e) {
      debugPrint('❌ Error adding note: $e');
      rethrow;
    }
  }

  // Update an existing note
  Future<void> updateNote(Note updatedNote) async {
    try {
      final index = _notes.indexWhere((note) => note.id == updatedNote.id);
      if (index != -1) {
        _notes[index] = updatedNote.copyWith(updatedAt: DateTime.now());
        await _saveNotesLocally();
        notifyListeners();
        debugPrint('✏️ Updated note: ${updatedNote.id}');
      } else {
        throw Exception('Note not found: ${updatedNote.id}');
      }
    } catch (e) {
      debugPrint('❌ Error updating note: $e');
      rethrow;
    }
  }

  // Delete a note
  Future<void> deleteNote(String noteId) async {
    try {
      final noteIndex = _notes.indexWhere((note) => note.id == noteId);
      if (noteIndex != -1) {
        if (_useBackend) {
          try {
            await _noteService.deleteNote(noteId);
          } catch (e) {
            debugPrint('⚠️ Backend delete failed, removing locally: $e');
          }
        }
        _notes.removeAt(noteIndex);
        await _saveNotesLocally();
        notifyListeners();
        debugPrint('🗑️ Deleted note: $noteId');
      } else {
        throw Exception('Note not found: $noteId');
      }
    } catch (e) {
      debugPrint('❌ Error deleting note: $e');
      rethrow;
    }
  }

  // Search notes
  void searchNotes(String query) {
    _searchQuery = query.trim();
    notifyListeners();
    debugPrint('🔍 Searching notes with query: "$query"');
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Get note by ID
  Note? getNoteById(String id) {
    try {
      return _notes.firstWhere((note) => note.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get notes by tag
  List<Note> getNotesByTag(String tag) {
    return _notes.where((note) => note.tags.contains(tag)).toList();
  }

  // Get all unique tags
  List<String> getAllTags() {
    final Set<String> allTags = {};
    for (final note in _notes) {
      allTags.addAll(note.tags);
    }
    return allTags.toList()..sort();
  }

  // Get recent notes (last 7 days)
  List<Note> getRecentNotes() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _notes
        .where((note) => note.createdAt.isAfter(sevenDaysAgo))
        .toList();
  }

  // Get notes statistics
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final monthStart = DateTime(now.year, now.month, 1);

    final todayNotes = _notes
        .where((note) => note.createdAt.isAfter(todayStart))
        .length;
    final weekNotes = _notes
        .where((note) => note.createdAt.isAfter(weekStart))
        .length;
    final monthNotes = _notes
        .where((note) => note.createdAt.isAfter(monthStart))
        .length;

    final totalDuration = _notes.fold<Duration>(
      Duration.zero,
      (total, note) => total + note.duration,
    );

    return {
      'totalNotes': _notes.length,
      'todayNotes': todayNotes,
      'weekNotes': weekNotes,
      'monthNotes': monthNotes,
      'totalDuration': totalDuration,
      'averageDuration': _notes.isNotEmpty
          ? Duration(seconds: totalDuration.inSeconds ~/ _notes.length)
          : Duration.zero,
    };
  }

  // Mark note as processing/completed
  Future<void> updateNoteProcessingStatus(
    String noteId,
    bool isProcessing,
  ) async {
    try {
      final index = _notes.indexWhere((note) => note.id == noteId);
      if (index != -1) {
        _notes[index] = _notes[index].copyWith(
          isProcessing: isProcessing,
          updatedAt: DateTime.now(),
        );
        await _saveNotesLocally();
        notifyListeners();
        debugPrint(
          '🔄 Updated processing status for note: $noteId ($isProcessing)',
        );
      }
    } catch (e) {
      debugPrint('❌ Error updating note processing status: $e');
      rethrow;
    }
  }

  // Update note transcription
  Future<void> updateNoteTranscription(
    String noteId,
    String transcription,
  ) async {
    try {
      final index = _notes.indexWhere((note) => note.id == noteId);
      if (index != -1) {
        _notes[index] = _notes[index].copyWith(
          transcription: transcription,
          isProcessing: false,
          updatedAt: DateTime.now(),
        );
        await _saveNotesLocally();
        notifyListeners();
        debugPrint('📝 Updated transcription for note: $noteId');
      }
    } catch (e) {
      debugPrint('❌ Error updating note transcription: $e');
      rethrow;
    }
  }

  // Clear all notes
  Future<void> clearAllNotes() async {
    try {
      _notes.clear();
      await _saveNotesLocally();
      notifyListeners();
      debugPrint('🗑️ Cleared all notes');
    } catch (e) {
      debugPrint('❌ Error clearing notes: $e');
      rethrow;
    }
  }
}
