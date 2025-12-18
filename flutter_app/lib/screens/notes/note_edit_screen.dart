import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/notes_provider.dart';
import '../../models/note.dart';
import '../../widgets/audio_player_widget.dart';

class NoteEditScreen extends StatefulWidget {
  final Note note;
  final bool isNewNote;

  const NoteEditScreen({super.key, required this.note, this.isNewNote = false});

  @override
  State<NoteEditScreen> createState() => _NoteEditScreenState();
}

class _NoteEditScreenState extends State<NoteEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _transcriptionController;
  late TextEditingController _tagsController;
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _transcriptionFocus = FocusNode();
  final FocusNode _tagsFocus = FocusNode();

  bool _hasChanges = false;
  bool _isSaving = false;
  List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _transcriptionController = TextEditingController(
      text: widget.note.transcription,
    );
    _tags = List.from(widget.note.tags);
    _tagsController = TextEditingController(text: _tags.join(', '));

    // Listen for changes
    _titleController.addListener(_onTextChanged);
    _transcriptionController.addListener(_onTextChanged);
    _tagsController.addListener(_onTagsChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _transcriptionController.dispose();
    _tagsController.dispose();
    _titleFocus.dispose();
    _transcriptionFocus.dispose();
    _tagsFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _hasChanges) {
          _showUnsavedChangesDialog();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('Edit Note'),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _isSaving ? null : _saveNote,
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share, size: 20),
                    title: Text('Share'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: ListTile(
                    leading: Icon(Icons.copy, size: 20),
                    title: Text('Duplicate'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, size: 20, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Audio player section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Original Recording',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.grey900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    AudioPlayerWidget(
                      audioPath: widget.note.audioPath,
                      title: widget.note.title.isNotEmpty
                          ? widget.note.title
                          : 'Voice Note',
                      showTitle: false,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Duration: ${widget.note.formattedDuration}',
                          style: const TextStyle(
                            color: AppColors.grey600,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(widget.note.createdAt),
                          style: const TextStyle(
                            color: AppColors.grey600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Title editing
              _buildEditSection(
                'Title',
                Icons.title,
                _buildTextField(
                  controller: _titleController,
                  focusNode: _titleFocus,
                  hintText: 'Enter note title...',
                  maxLines: 1,
                ),
              ),

              const SizedBox(height: 24),

              // Transcription editing
              _buildEditSection(
                'Transcription',
                Icons.text_fields,
                _buildTextField(
                  controller: _transcriptionController,
                  focusNode: _transcriptionFocus,
                  hintText: 'Edit transcription...',
                  maxLines: null,
                  minLines: 4,
                ),
              ),

              const SizedBox(height: 24),

              // Tags editing
              _buildEditSection(
                'Tags',
                Icons.tag,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      controller: _tagsController,
                      focusNode: _tagsFocus,
                      hintText: 'Enter tags separated by commas...',
                      maxLines: 1,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Separate tags with commas (e.g., meeting, important, work)',
                      style: TextStyle(color: AppColors.grey500, fontSize: 12),
                    ),
                    if (_tags.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _tags
                            .map(
                              (tag) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tag,
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => _removeTag(tag),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _hasChanges ? _discardChanges : null,
                      icon: const Icon(Icons.undo),
                      label: const Text('Discard Changes'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _hasChanges && !_isSaving ? _saveNote : null,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isSaving ? 'Saving...' : 'Save Note'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditSection(String title, IconData icon, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(padding: const EdgeInsets.all(16), child: content),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hintText,
    int? maxLines,
    int? minLines,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      minLines: minLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.grey400),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: const TextStyle(color: AppColors.grey900, fontSize: 16),
    );
  }

  void _onTextChanged() {
    final newTitle = _titleController.text;
    final newTranscription = _transcriptionController.text;

    final hasChanges =
        newTitle != widget.note.title ||
        newTranscription != widget.note.transcription ||
        !_listsEqual(_tags, widget.note.tags);

    if (hasChanges != _hasChanges) {
      setState(() {
        _hasChanges = hasChanges;
      });
    }
  }

  void _onTagsChanged() {
    final tagsText = _tagsController.text;
    final newTags = tagsText
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    if (!_listsEqual(_tags, newTags)) {
      setState(() {
        _tags = newTags;
      });
      _onTextChanged();
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
      _tagsController.text = _tags.join(', ');
    });
    _onTextChanged();
  }

  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }

  Future<void> _saveNote() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);

      final updatedNote = widget.note.copyWith(
        title: _titleController.text.trim().isEmpty
            ? 'Untitled Note'
            : _titleController.text.trim(),
        transcription: _transcriptionController.text.trim(),
        tags: _tags,
        updatedAt: DateTime.now(),
      );

      if (widget.isNewNote) {
        await notesProvider.addNote(updatedNote);
      } else {
        await notesProvider.updateNote(updatedNote);
      }

      setState(() {
        _hasChanges = false;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note saved successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, updatedNote);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving note: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _discardChanges() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes'),
        content: const Text('Are you sure you want to discard your changes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetFields();
            },
            child: const Text(
              'Discard',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _resetFields() {
    setState(() {
      _titleController.text = widget.note.title;
      _transcriptionController.text = widget.note.transcription;
      _tags = List.from(widget.note.tags);
      _tagsController.text = _tags.join(', ');
      _hasChanges = false;
    });
  }

  void _showUnsavedChangesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have unsaved changes. What would you like to do?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Discard',
              style: TextStyle(color: AppColors.error),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Editing'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _saveNote();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'share':
        _showComingSoon('Share Note');
        break;
      case 'duplicate':
        _showComingSoon('Duplicate Note');
        break;
      case 'delete':
        _showDeleteDialog();
        break;
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text(
          'Are you sure you want to delete this note? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteNote();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteNote() async {
    try {
      final notesProvider = Provider.of<NotesProvider>(context, listen: false);
      await notesProvider.deleteNote(widget.note.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Note deleted successfully'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, 'deleted');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting note: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour == 0
        ? 12
        : (date.hour > 12 ? date.hour - 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
