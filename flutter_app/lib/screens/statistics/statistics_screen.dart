import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/notes_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedPeriod = 'All Time';
  final List<String> _periods = [
    'This Week',
    'This Month',
    'Last 3 Months',
    'All Time',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Statistics'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.date_range, color: Colors.white),
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => _periods
                .map(
                  (period) => PopupMenuItem(value: period, child: Text(period)),
                )
                .toList(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Activity'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
      body: Consumer<NotesProvider>(
        builder: (context, notesProvider, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(notesProvider),
              _buildActivityTab(notesProvider),
              _buildInsightsTab(notesProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverviewTab(NotesProvider notesProvider) {
    final stats = _calculateStats(notesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selector info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.date_range, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Showing data for: $_selectedPeriod',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Main stats grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                'Total Notes',
                stats.totalNotes.toString(),
                Icons.note,
                AppColors.primary,
              ),
              _buildStatCard(
                'Total Duration',
                _formatTotalDuration(stats.totalDuration),
                Icons.timer,
                AppColors.success,
              ),
              _buildStatCard(
                'Average Length',
                _formatDuration(stats.averageDuration),
                Icons.bar_chart,
                AppColors.warning,
              ),
              _buildStatCard(
                'This Week',
                stats.thisWeekNotes.toString(),
                Icons.trending_up,
                AppColors.info,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent activity
          _buildSection(
            'Recent Activity',
            Icons.history,
            _buildRecentActivity(notesProvider),
          ),

          const SizedBox(height: 24),

          // Quick stats
          _buildSection('Quick Stats', Icons.insights, _buildQuickStats(stats)),
        ],
      ),
    );
  }

  Widget _buildActivityTab(NotesProvider notesProvider) {
    final activityData = _getActivityData(notesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Activity chart placeholder
          Container(
            width: double.infinity,
            height: 200,
            margin: const EdgeInsets.only(bottom: 24),
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recording Activity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.grey900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bar_chart,
                            size: 64,
                            color: AppColors.grey300,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Activity Chart',
                            style: TextStyle(
                              color: AppColors.grey500,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Coming Soon',
                            style: TextStyle(
                              color: AppColors.grey400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Daily breakdown
          _buildSection(
            'Daily Breakdown',
            Icons.calendar_today,
            _buildDailyBreakdown(activityData),
          ),

          const SizedBox(height: 24),

          // Peak hours
          _buildSection(
            'Peak Recording Hours',
            Icons.schedule,
            _buildPeakHours(activityData),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsTab(NotesProvider notesProvider) {
    final insights = _generateInsights(notesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Achievement badges
          _buildSection(
            'Achievements',
            Icons.emoji_events,
            _buildAchievements(insights),
          ),

          const SizedBox(height: 24),

          // Usage patterns
          _buildSection(
            'Usage Patterns',
            Icons.psychology,
            _buildUsagePatterns(insights),
          ),

          const SizedBox(height: 24),

          // Recommendations
          _buildSection(
            'Recommendations',
            Icons.lightbulb,
            _buildRecommendations(insights),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: AppColors.grey600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
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
        const SizedBox(height: 16),
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
          child: content,
        ),
      ],
    );
  }

  Widget _buildRecentActivity(NotesProvider notesProvider) {
    final recentNotes = notesProvider.getRecentNotes().take(5).toList();

    if (recentNotes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No recent activity',
            style: TextStyle(color: AppColors.grey500),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: recentNotes
            .map(
              (note) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title.isNotEmpty ? note.title : 'Voice Note',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.grey900,
                            ),
                          ),
                          Text(
                            _formatRelativeTime(note.createdAt),
                            style: const TextStyle(
                              color: AppColors.grey500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      note.formattedDuration,
                      style: const TextStyle(
                        color: AppColors.grey600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildQuickStats(StatsData stats) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildQuickStatRow(
            'Longest Recording',
            _formatDuration(stats.longestDuration),
          ),
          _buildQuickStatRow(
            'Shortest Recording',
            _formatDuration(stats.shortestDuration),
          ),
          _buildQuickStatRow('Most Productive Day', stats.mostProductiveDay),
          _buildQuickStatRow('Favorite Recording Time', stats.favoriteTime),
        ],
      ),
    );
  }

  Widget _buildQuickStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey600)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyBreakdown(Map<String, int> activityData) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: days.map((day) {
          final count = activityData[day] ?? 0;
          final maxCount = activityData.values.isNotEmpty
              ? activityData.values.reduce((a, b) => a > b ? a : b)
              : 1;
          final percentage = maxCount > 0 ? count / maxCount : 0.0;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 30,
                  child: Text(
                    day,
                    style: const TextStyle(
                      color: AppColors.grey600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: percentage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 20,
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: AppColors.grey600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPeakHours(Map<String, int> activityData) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPeakHourItem(
            'Morning (6-12)',
            'High activity',
            AppColors.success,
          ),
          _buildPeakHourItem(
            'Afternoon (12-18)',
            'Medium activity',
            AppColors.warning,
          ),
          _buildPeakHourItem(
            'Evening (18-24)',
            'Low activity',
            AppColors.error,
          ),
          _buildPeakHourItem(
            'Night (0-6)',
            'Very low activity',
            AppColors.grey400,
          ),
        ],
      ),
    );
  }

  Widget _buildPeakHourItem(String time, String activity, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.grey900,
              ),
            ),
          ),
          Text(
            activity,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(InsightsData insights) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
        children: insights.achievements
            .map(
              (achievement) => Container(
                decoration: BoxDecoration(
                  color: achievement.isUnlocked
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: achievement.isUnlocked
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : AppColors.grey300,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Icon(
                        achievement.icon,
                        color: achievement.isUnlocked
                            ? AppColors.primary
                            : AppColors.grey400,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        achievement.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: achievement.isUnlocked
                              ? AppColors.grey900
                              : AppColors.grey500,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildUsagePatterns(InsightsData insights) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: insights.patterns
            .map(
              (pattern) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(pattern.icon, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(pattern.description)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildRecommendations(InsightsData insights) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: insights.recommendations
            .map(
              (recommendation) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb, color: AppColors.warning, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(recommendation)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  StatsData _calculateStats(NotesProvider notesProvider) {
    final notes = notesProvider.notes;
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));

    int thisWeekNotes = 0;
    int totalDurationSeconds = 0;
    int longestDurationSeconds = 0;
    int shortestDurationSeconds = notes.isNotEmpty
        ? notes.first.duration.inSeconds
        : 0;

    for (final note in notes) {
      final durationSeconds = note.duration.inSeconds;
      totalDurationSeconds += durationSeconds;

      if (durationSeconds > longestDurationSeconds) {
        longestDurationSeconds = durationSeconds;
      }
      if (durationSeconds < shortestDurationSeconds) {
        shortestDurationSeconds = durationSeconds;
      }

      if (note.createdAt.isAfter(weekStart)) {
        thisWeekNotes++;
      }
    }

    return StatsData(
      totalNotes: notes.length,
      totalDuration: totalDurationSeconds,
      averageDuration: notes.isNotEmpty
          ? totalDurationSeconds ~/ notes.length
          : 0,
      thisWeekNotes: thisWeekNotes,
      longestDuration: longestDurationSeconds,
      shortestDuration: shortestDurationSeconds,
      mostProductiveDay: 'Monday', // Placeholder
      favoriteTime: '2:00 PM', // Placeholder
    );
  }

  Map<String, int> _getActivityData(NotesProvider notesProvider) {
    // Placeholder data - in real app, calculate from actual notes
    return {
      'Mon': 5,
      'Tue': 3,
      'Wed': 7,
      'Thu': 4,
      'Fri': 6,
      'Sat': 2,
      'Sun': 1,
    };
  }

  InsightsData _generateInsights(NotesProvider notesProvider) {
    final notes = notesProvider.notes;

    return InsightsData(
      achievements: [
        Achievement('First Note', Icons.mic, notes.isNotEmpty),
        Achievement(
          'Week Streak',
          Icons.local_fire_department,
          notes.length >= 7,
        ),
        Achievement('Note Master', Icons.star, notes.length >= 50),
        Achievement(
          'Long Recording',
          Icons.timer,
          notes.any((n) => n.duration.inSeconds >= 300),
        ),
      ],
      patterns: [
        Pattern(Icons.schedule, 'You record most often in the afternoon'),
        Pattern(Icons.trending_up, 'Your recording frequency is increasing'),
        Pattern(Icons.mic, 'Average recording length: 45 seconds'),
      ],
      recommendations: [
        'Try recording in a quieter environment for better transcription',
        'Consider using tags to organize your notes better',
        'Your most productive recording time is 2-4 PM',
      ],
    );
  }

  String _formatTotalDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class StatsData {
  final int totalNotes;
  final int totalDuration;
  final int averageDuration;
  final int thisWeekNotes;
  final int longestDuration;
  final int shortestDuration;
  final String mostProductiveDay;
  final String favoriteTime;

  StatsData({
    required this.totalNotes,
    required this.totalDuration,
    required this.averageDuration,
    required this.thisWeekNotes,
    required this.longestDuration,
    required this.shortestDuration,
    required this.mostProductiveDay,
    required this.favoriteTime,
  });
}

class InsightsData {
  final List<Achievement> achievements;
  final List<Pattern> patterns;
  final List<String> recommendations;

  InsightsData({
    required this.achievements,
    required this.patterns,
    required this.recommendations,
  });
}

class Achievement {
  final String title;
  final IconData icon;
  final bool isUnlocked;

  Achievement(this.title, this.icon, this.isUnlocked);
}

class Pattern {
  final IconData icon;
  final String description;

  Pattern(this.icon, this.description);
}
