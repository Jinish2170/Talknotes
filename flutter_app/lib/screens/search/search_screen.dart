import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../providers/notes_provider.dart';
import '../../models/note.dart';
import '../notes/note_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  late FocusNode _searchFocus;
  List<Note> _searchResults = [];
  bool _isSearching = false;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocus = FocusNode();

    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          decoration: InputDecoration(
            hintText: 'Search notes...',
            hintStyle: const TextStyle(color: Colors.white70),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          onChanged: _performSearch,
          textInputAction: TextInputAction.search,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          if (_currentQuery.isEmpty) {
            return _buildInitialState();
          }

          if (_isSearching) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (_searchResults.isEmpty) {
            return _buildNoResults();
          }

          return _buildSearchResults();
        },
      ),
    );
  }

  Widget _buildInitialState() {
    return Consumer<NotesProvider>(
      builder: (context, notesProvider, child) {
        final recentNotes = notesProvider.getRecentNotes();
        final allTags = notesProvider.getAllTags();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search suggestions
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search Tips',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.grey900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSearchTip(
                      Icons.search,
                      'Search by keywords in title or content',
                    ),
                    _buildSearchTip(
                      Icons.tag,
                      'Use tags to filter specific topics',
                    ),
                    _buildSearchTip(
                      Icons.date_range,
                      'Find notes by creation date',
                    ),
                    _buildSearchTip(
                      Icons.access_time,
                      'Search by recording duration',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Recent notes
              if (recentNotes.isNotEmpty) ...[
                Text(
                  'Recent Notes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.grey900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...recentNotes.take(5).map((note) => _buildNoteCard(note)),
                const SizedBox(height: 24),
              ],

              // Popular tags
              if (allTags.isNotEmpty) ...[
                Text(
                  'Popular Tags',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.grey900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: allTags
                      .take(10)
                      .map(
                        (tag) => GestureDetector(
                          onTap: () => _searchByTag(tag),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchTip(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(color: AppColors.grey600)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.grey100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.search_off, size: 60, color: AppColors.grey400),
            ),
            const SizedBox(height: 24),
            Text(
              'No results found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppColors.grey700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try searching with different keywords or check your spelling',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.refresh),
              label: const Text('Clear Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: _searchResults.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              '${_searchResults.length} result${_searchResults.length == 1 ? '' : 's'} for "$_currentQuery"',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.grey700),
            ),
          );
        }

        final note = _searchResults[index - 1];
        return _buildNoteCard(note);
      },
    );
  }

  Widget _buildNoteCard(Note note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.note_outlined, color: AppColors.primary, size: 20),
        ),
        title: Text(
          note.title.isNotEmpty ? note.title : 'Voice Note',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.transcription.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _highlightSearchTerm(note.transcription, _currentQuery),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.grey600),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: AppColors.grey400),
                const SizedBox(width: 4),
                Text(
                  _formatDate(note.createdAt),
                  style: const TextStyle(
                    color: AppColors.grey500,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.timer, size: 14, color: AppColors.grey400),
                const SizedBox(width: 4),
                Text(
                  note.formattedDuration,
                  style: const TextStyle(
                    color: AppColors.grey500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
        onTap: () => _openNoteDetail(note),
      ),
    );
  }

  String _highlightSearchTerm(String text, String searchTerm) {
    // For now, just return the text as-is
    // TODO: Implement actual highlighting
    return text;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _performSearch(String query) {
    setState(() {
      _currentQuery = query;
      _isSearching = true;
    });

    // Debounce search to avoid excessive API calls
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_currentQuery == query && mounted) {
        _executeSearch(query);
      }
    });
  }

  void _executeSearch(String query) {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);

    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
        _currentQuery = '';
      });
      return;
    }

    // Perform search
    final results = notesProvider.notes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(query.toLowerCase());
      final contentMatch = note.transcription.toLowerCase().contains(
        query.toLowerCase(),
      );
      final tagMatch = note.tags.any(
        (tag) => tag.toLowerCase().contains(query.toLowerCase()),
      );

      return titleMatch || contentMatch || tagMatch;
    }).toList();

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _searchByTag(String tag) {
    _searchController.text = tag;
    _performSearch(tag);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchResults = [];
      _currentQuery = '';
      _isSearching = false;
    });
  }

  void _openNoteDetail(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NoteDetailScreen(note: note)),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Filter Options',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(
                  Icons.calendar_today,
                  color: AppColors.primary,
                ),
                title: const Text('Date Range'),
                subtitle: const Text('Filter by creation date'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoon('Date Range Filter');
                },
              ),
              ListTile(
                leading: const Icon(Icons.timer, color: AppColors.primary),
                title: const Text('Duration'),
                subtitle: const Text('Filter by recording length'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoon('Duration Filter');
                },
              ),
              ListTile(
                leading: const Icon(Icons.tag, color: AppColors.primary),
                title: const Text('Tags'),
                subtitle: const Text('Filter by specific tags'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoon('Tag Filter');
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
