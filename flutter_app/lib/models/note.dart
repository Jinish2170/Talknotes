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
    };
  }

  // Create from JSON
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
    );
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
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
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
