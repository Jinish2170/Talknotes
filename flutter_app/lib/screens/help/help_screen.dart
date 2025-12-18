import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<FAQItem> _filteredFAQs = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _filteredFAQs = _allFAQs;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Help & Support'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'FAQ'),
            Tab(text: 'Guides'),
            Tab(text: 'Contact'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFAQTab(), _buildGuidesTab(), _buildContactTab()],
      ),
    );
  }

  Widget _buildFAQTab() {
    return Column(
      children: [
        // Search bar
        Container(
          margin: const EdgeInsets.all(16),
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
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search FAQ...',
              prefixIcon: const Icon(Icons.search, color: AppColors.grey400),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppColors.grey400),
                      onPressed: () {
                        _searchController.clear();
                        _filterFAQs('');
                      },
                    )
                  : null,
            ),
            onChanged: _filterFAQs,
          ),
        ),

        // FAQ List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredFAQs.length,
            itemBuilder: (context, index) {
              final faq = _filteredFAQs[index];
              return _buildFAQCard(faq);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFAQCard(FAQItem faq) {
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
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.grey900,
          ),
        ),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.grey400,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq.answer,
              style: const TextStyle(color: AppColors.grey600, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGuideCard(
          'Getting Started',
          'Learn the basics of using TalkNotes',
          Icons.play_circle_outline,
          [
            'Creating your first voice note',
            'Understanding the interface',
            'Basic navigation tips',
          ],
        ),
        _buildGuideCard(
          'Recording Tips',
          'Get the best results from your recordings',
          Icons.mic,
          [
            'Optimal recording conditions',
            'Speaking techniques for better transcription',
            'Managing background noise',
          ],
        ),
        _buildGuideCard(
          'Organizing Notes',
          'Keep your notes organized and accessible',
          Icons.folder_open,
          [
            'Using tags effectively',
            'Searching and filtering',
            'Creating note collections',
          ],
        ),
        _buildGuideCard(
          'Advanced Features',
          'Explore powerful features',
          Icons.star,
          [
            'Sharing and exporting notes',
            'Customizing settings',
            'Backup and sync options',
          ],
        ),
      ],
    );
  }

  Widget _buildGuideCard(
    String title,
    String description,
    IconData icon,
    List<String> topics,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
        children: [
          ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.grey900,
              ),
            ),
            subtitle: Text(
              description,
              style: const TextStyle(color: AppColors.grey600),
            ),
            trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
            onTap: () => _showComingSoon('$title Guide'),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: topics
                  .map(
                    (topic) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              topic,
                              style: const TextStyle(
                                color: AppColors.grey600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Quick Actions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                  'Need More Help?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We\'re here to help! Choose the best way to get in touch with us.',
                  style: TextStyle(color: AppColors.grey600),
                ),
                const SizedBox(height: 20),
                _buildContactOption(
                  Icons.email,
                  'Send Email',
                  'Get help via email support',
                  'support@talknotes.app',
                  () => _showComingSoon('Email Support'),
                ),
                _buildContactOption(
                  Icons.chat,
                  'Live Chat',
                  'Chat with our support team',
                  'Available 9 AM - 6 PM',
                  () => _showComingSoon('Live Chat'),
                ),
                _buildContactOption(
                  Icons.bug_report,
                  'Report Bug',
                  'Report technical issues',
                  'Help us improve the app',
                  () => _showComingSoon('Bug Report'),
                ),
                _buildContactOption(
                  Icons.feedback,
                  'Send Feedback',
                  'Share your thoughts and ideas',
                  'We value your input',
                  () => _showComingSoon('Feedback'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Response Time Info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.access_time, color: AppColors.info, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Response Time',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'We typically respond within 24 hours',
                        style: TextStyle(color: AppColors.info, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Social Links
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
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
                  'Follow Us',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey900,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSocialButton(
                      Icons.language,
                      'Website',
                      () => _showComingSoon('Website'),
                    ),
                    _buildSocialButton(
                      Icons.facebook,
                      'Facebook',
                      () => _showComingSoon('Facebook'),
                    ),
                    _buildSocialButton(
                      Icons.alternate_email,
                      'Twitter',
                      () => _showComingSoon('Twitter'),
                    ),
                    _buildSocialButton(
                      Icons.camera_alt,
                      'Instagram',
                      () => _showComingSoon('Instagram'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption(
    IconData icon,
    String title,
    String subtitle,
    String detail,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey900,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.grey600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      detail,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.grey400),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.grey600, fontSize: 12),
        ),
      ],
    );
  }

  void _filterFAQs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredFAQs = _allFAQs;
      } else {
        _filteredFAQs = _allFAQs
            .where(
              (faq) =>
                  faq.question.toLowerCase().contains(query.toLowerCase()) ||
                  faq.answer.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
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

class FAQItem {
  final String question;
  final String answer;

  FAQItem({required this.question, required this.answer});
}

final List<FAQItem> _allFAQs = [
  FAQItem(
    question: 'How do I start recording?',
    answer:
        'Tap the microphone button on the home screen or recording screen. The app will ask for microphone permission if it\'s your first time. Once granted, simply tap and hold to record or tap once to start recording.',
  ),
  FAQItem(
    question: 'What is the maximum recording length?',
    answer:
        'By default, recordings are limited to 1 minute to ensure optimal performance and quick processing. You can adjust this limit in the Settings menu up to 5 minutes.',
  ),
  FAQItem(
    question: 'How accurate is the speech-to-text feature?',
    answer:
        'The accuracy depends on factors like audio quality, background noise, and speaking clarity. For best results, record in a quiet environment and speak clearly. The app uses advanced speech recognition technology for high accuracy.',
  ),
  FAQItem(
    question: 'Can I edit the transcribed text?',
    answer:
        'Yes! After recording, you can tap on any note to view and edit the transcribed text. Changes are automatically saved.',
  ),
  FAQItem(
    question: 'Where are my recordings stored?',
    answer:
        'All recordings and transcriptions are stored locally on your device. This ensures your privacy and allows offline access to your notes.',
  ),
  FAQItem(
    question: 'Can I backup my notes?',
    answer:
        'Backup and sync features are coming soon! For now, you can export your notes individually through the share feature.',
  ),
  FAQItem(
    question: 'Does the app work offline?',
    answer:
        'Yes, basic recording functionality works offline. However, speech-to-text transcription requires an internet connection for the best accuracy.',
  ),
  FAQItem(
    question: 'How do I delete a recording?',
    answer:
        'In the notes list, swipe left on any note to reveal the delete option, or tap on a note to open it and use the delete button in the menu.',
  ),
  FAQItem(
    question: 'Can I organize my notes with tags?',
    answer:
        'Yes! When editing a note, you can add tags to help organize and categorize your recordings for easy searching.',
  ),
  FAQItem(
    question: 'What audio formats are supported?',
    answer:
        'The app records in standard audio formats compatible with most devices. All recordings are optimized for both quality and file size.',
  ),
  FAQItem(
    question: 'How do I change recording quality?',
    answer:
        'Go to Settings > Recording Settings and adjust the "Recording Quality" slider. Higher quality means better audio but larger file sizes.',
  ),
  FAQItem(
    question: 'Can I share my recordings?',
    answer:
        'Yes! You can share both the audio file and transcription text through the share button in each note. Choose from various sharing options like email, messaging, or cloud storage.',
  ),
];
