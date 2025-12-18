class Note {
  final String id;
  final String title;
  final String transcription;
  final String audioPath;
  final Duration duration;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isProcessing;
  final List<String> tags;
  final String? noteStyle;
  final String? textNote;
  final String? aiNote;
  final String? audioPublicId;

  Note({
    required this.id,
    required this.title,
    required this.transcription,
    required this.audioPath,
    required this.duration,
    required this.createdAt,
    required this.updatedAt,
    this.isProcessing = false,
    this.tags = const [],
    this.noteStyle,
    this.textNote,
    this.aiNote,
    this.audioPublicId,
  });

  // Create a copy of the note with updated fields
  Note copyWith({
    String? id,
    String? title,
    String? transcription,
    String? audioPath,
    Duration? duration,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isProcessing,
    List<String>? tags,
    String? noteStyle,
    String? textNote,
    String? aiNote,
    String? audioPublicId,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      transcription: transcription ?? this.transcription,
      audioPath: audioPath ?? this.audioPath,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isProcessing: isProcessing ?? this.isProcessing,
      tags: tags ?? this.tags,
      noteStyle: noteStyle ?? this.noteStyle,
      textNote: textNote ?? this.textNote,
      aiNote: aiNote ?? this.aiNote,
      audioPublicId: audioPublicId ?? this.audioPublicId,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'transcription': transcription,
      'audioPath': audioPath,
      'duration': duration.inSeconds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isProcessing': isProcessing,
      'tags': tags,
      'noteStyle': noteStyle,
      'textNote': textNote,
      'aiNote': aiNote,
      'audioPublicId': audioPublicId,
    };
  }

  // Create from JSON (local storage format)
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      transcription: json['transcription'] ?? '',
      audioPath: json['audioPath'] ?? '',
      duration: Duration(seconds: json['duration'] ?? 0),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      isProcessing: json['isProcessing'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      noteStyle: json['noteStyle'],
      textNote: json['textNote'],
      aiNote: json['aiNote'],
      audioPublicId: json['audioPublicId'],
    );
  }

  // Create from backend JSON format
  factory Note.fromBackendJson(Map<String, dynamic> json) {
    return Note(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['note_title'] ?? json['title'] ?? '',
      transcription: json['audio_transcription'] ?? json['transcription'] ?? '',
      audioPath: json['audio_url'] ?? json['audioPath'] ?? '',
      duration: Duration(seconds: json['duration'] ?? 0),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isProcessing: json['isProcessing'] ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      noteStyle: json['note_style'],
      textNote: json['text_note'],
      aiNote: json['ai_note'],
      audioPublicId: json['audio_public_id'],
    );
  }

  // Convert to backend format for API calls
  Map<String, dynamic> toBackendJson() {
    return {
      'note_title': title,
      'note_style': noteStyle ?? 'default',
      'text_note': textNote ?? '',
      'audio_transcription': transcription,
      'ai_note': aiNote ?? '',
    };
  }

  // Generate a preview of the transcription
  String get preview {
    if (transcription.isEmpty) return 'No transcription available';
    const maxLength = 100;
    if (transcription.length <= maxLength) return transcription;
    return '${transcription.substring(0, maxLength)}...';
  }

  // Check if note has content
  bool get hasContent => transcription.isNotEmpty || title.isNotEmpty;

  // Get formatted duration string
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  String toString() {
    return 'Note(id: $id, title: $title, duration: $formattedDuration, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
