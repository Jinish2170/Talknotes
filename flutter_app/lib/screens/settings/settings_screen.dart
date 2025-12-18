import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notes_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoTranscription = true;
  bool _autoSave = true;
  bool _notifications = true;
  bool _darkMode = false;
  double _recordingQuality = 1.0; // 0: Low, 1: Medium, 2: High
  int _maxRecordingDuration = 60; // seconds

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Recording Settings', [
              _buildSwitchTile(
                icon: Icons.mic,
                title: 'Auto-Transcription',
                subtitle: 'Automatically convert speech to text',
                value: _autoTranscription,
                onChanged: (value) {
                  setState(() {
                    _autoTranscription = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.save,
                title: 'Auto-Save',
                subtitle: 'Automatically save recordings',
                value: _autoSave,
                onChanged: (value) {
                  setState(() {
                    _autoSave = value;
                  });
                },
              ),
              _buildSliderTile(
                icon: Icons.high_quality,
                title: 'Recording Quality',
                subtitle: _getQualityText(_recordingQuality),
                value: _recordingQuality,
                min: 0,
                max: 2,
                divisions: 2,
                onChanged: (value) {
                  setState(() {
                    _recordingQuality = value;
                  });
                },
              ),
              _buildSliderTile(
                icon: Icons.timer,
                title: 'Max Recording Duration',
                subtitle: '$_maxRecordingDuration seconds',
                value: _maxRecordingDuration.toDouble(),
                min: 30,
                max: 300,
                divisions: 27,
                onChanged: (value) {
                  setState(() {
                    _maxRecordingDuration = value.round();
                  });
                },
              ),
            ]),

            _buildSection('App Settings', [
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Receive app notifications',
                value: _notifications,
                onChanged: (value) {
                  setState(() {
                    _notifications = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Use dark theme',
                value: _darkMode,
                onChanged: (value) {
                  setState(() {
                    _darkMode = value;
                  });
                  _showComingSoon('Dark Mode');
                },
              ),
              _buildNavigationTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: 'English (Default)',
                onTap: () => _showComingSoon('Language Settings'),
              ),
            ]),

            _buildSection('Data & Storage', [
              _buildNavigationTile(
                icon: Icons.cloud_upload,
                title: 'Backup & Sync',
                subtitle: 'Sync your notes across devices',
                onTap: () => _showComingSoon('Backup & Sync'),
              ),
              _buildNavigationTile(
                icon: Icons.storage,
                title: 'Storage Usage',
                subtitle: 'Manage local storage',
                onTap: () => _showStorageInfo(),
              ),
              _buildNavigationTile(
                icon: Icons.download,
                title: 'Export Data',
                subtitle: 'Export notes and recordings',
                onTap: () => _showComingSoon('Data Export'),
              ),
              _buildActionTile(
                icon: Icons.delete_sweep,
                title: 'Clear All Data',
                subtitle: 'Delete all notes and recordings',
                textColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () => _showClearDataDialog(),
              ),
            ]),

            _buildSection('Account', [
              _buildNavigationTile(
                icon: Icons.person,
                title: 'Edit Profile',
                subtitle: 'Update your account information',
                onTap: () => Navigator.pushNamed(context, '/profile'),
              ),
              _buildNavigationTile(
                icon: Icons.security,
                title: 'Privacy & Security',
                subtitle: 'Manage your privacy settings',
                onTap: () => _showComingSoon('Privacy Settings'),
              ),
              _buildActionTile(
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                textColor: AppColors.error,
                iconColor: AppColors.error,
                onTap: () => _showSignOutDialog(),
              ),
            ]),

            _buildSection('Support', [
              _buildNavigationTile(
                icon: Icons.help,
                title: 'Help & FAQ',
                subtitle: 'Get help and find answers',
                onTap: () => _showComingSoon('Help Center'),
              ),
              _buildNavigationTile(
                icon: Icons.feedback,
                title: 'Send Feedback',
                subtitle: 'Help us improve the app',
                onTap: () => _showComingSoon('Feedback'),
              ),
              _buildNavigationTile(
                icon: Icons.bug_report,
                title: 'Report a Bug',
                subtitle: 'Report issues or problems',
                onTap: () => _showComingSoon('Bug Report'),
              ),
              _buildNavigationTile(
                icon: Icons.star_rate,
                title: 'Rate App',
                subtitle: 'Rate us on the app store',
                onTap: () => _showComingSoon('App Rating'),
              ),
            ]),

            _buildSection('About', [
              _buildNavigationTile(
                icon: Icons.info,
                title: 'App Version',
                subtitle: '1.0.0 (Build 1)',
                onTap: () => _showAboutDialog(),
              ),
              _buildNavigationTile(
                icon: Icons.description,
                title: 'Terms of Service',
                subtitle: 'Read our terms of service',
                onTap: () => _showComingSoon('Terms of Service'),
              ),
              _buildNavigationTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () => _showComingSoon('Privacy Policy'),
              ),
            ]),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
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
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.grey600),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSliderTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.grey900,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(color: AppColors.grey600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(72, 0, 24, 16),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.grey900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: AppColors.grey600),
      ),
      trailing: const Icon(Icons.chevron_right, color: AppColors.grey400),
      onTap: onTap,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: textColor.withValues(alpha: 0.7)),
      ),
      onTap: onTap,
    );
  }

  String _getQualityText(double value) {
    switch (value.round()) {
      case 0:
        return 'Low Quality (Smaller files)';
      case 1:
        return 'Medium Quality (Balanced)';
      case 2:
        return 'High Quality (Larger files)';
      default:
        return 'Medium Quality';
    }
  }

  void _showStorageInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Storage Usage'),
        content: Consumer<NotesProvider>(
          builder: (context, notesProvider, child) {
            final noteCount = notesProvider.notes.length;
            final estimatedSize = noteCount * 2.5; // MB estimate

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Notes: $noteCount'),
                const SizedBox(height: 8),
                Text(
                  'Estimated Storage: ${estimatedSize.toStringAsFixed(1)} MB',
                ),
                const SizedBox(height: 16),
                const Text(
                  'Storage usage includes audio recordings and transcriptions.',
                  style: TextStyle(fontSize: 12, color: AppColors.grey600),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete all your notes and recordings. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'TalkNotes',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.mic, color: Colors.white, size: 32),
      ),
      children: [
        const Text(
          'A simple and intuitive voice recording app with speech-to-text capabilities.',
        ),
      ],
    );
  }

  void _clearAllData() {
    final notesProvider = Provider.of<NotesProvider>(context, listen: false);
    notesProvider.clearAllNotes();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All data has been cleared'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _signOut() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
