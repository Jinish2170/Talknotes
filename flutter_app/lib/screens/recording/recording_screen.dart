import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../constants/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../providers/recording_provider.dart';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Record Voice Note'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<RecordingProvider>(
        builder: (context, recordingProvider, child) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                children: [
                  // Status Card
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
                      children: [
                        Text(
                          _getStatusText(recordingProvider.recordingState),
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: _getStatusColor(recordingProvider.recordingState),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getSubtitleText(recordingProvider.recordingState),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.grey600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Timer Display
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      _formatDuration(recordingProvider.recordingDuration),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.grey800,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Time Remaining
                  Text(
                    'Time remaining: ${_formatDuration(const Duration(seconds: 60) - recordingProvider.recordingDuration)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.grey600,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Recording Button
                  Center(
                    child: GestureDetector(
                      onTap: () => _handleRecordingAction(recordingProvider),
                      child: AnimatedBuilder(
                        animation: recordingProvider.isRecording ? _pulseController : _waveController,
                        builder: (context, child) {
                          if (recordingProvider.isRecording) {
                            _pulseController.repeat(reverse: true);
                          } else {
                            _pulseController.stop();
                          }
                          
                          return Transform.scale(
                            scale: recordingProvider.isRecording 
                                ? _pulseAnimation.value 
                                : _scaleAnimation.value,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                gradient: recordingProvider.isRecording
                                    ? AppColors.recordingGradient
                                    : AppColors.primaryGradient,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: recordingProvider.isRecording
                                        ? AppColors.recordingActive.withValues(alpha: 0.4)
                                        : AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                recordingProvider.isRecording ? Icons.stop : Icons.mic,
                                size: 80,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Action Text
                  Text(
                    recordingProvider.isRecording 
                        ? 'Tap to stop recording' 
                        : 'Tap to start recording',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.grey700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Warning for 1-minute limit
                  if (!recordingProvider.isRecording)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            color: AppColors.warning,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Recording is limited to 1 minute. The recording will automatically stop at 60 seconds.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const Spacer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getStatusText(RecordingState state) {
    switch (state) {
      case RecordingState.idle:
        return 'Ready to Record';
      case RecordingState.recording:
        return 'Recording...';
      case RecordingState.stopped:
        return 'Recording Complete';
      case RecordingState.processing:
        return 'Processing...';
    }
  }

  String _getSubtitleText(RecordingState state) {
    switch (state) {
      case RecordingState.idle:
        return 'Tap the microphone to start recording your voice note';
      case RecordingState.recording:
        return 'Speak clearly into your device microphone';
      case RecordingState.stopped:
        return 'Your voice note has been recorded successfully';
      case RecordingState.processing:
        return 'Converting your voice to text...';
    }
  }

  Color _getStatusColor(RecordingState state) {
    switch (state) {
      case RecordingState.idle:
        return AppColors.primary;
      case RecordingState.recording:
        return AppColors.recordingActive;
      case RecordingState.stopped:
        return AppColors.success;
      case RecordingState.processing:
        return AppColors.warning;
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _handleRecordingAction(RecordingProvider provider) async {
    if (provider.isRecording) {
      // Stop recording
      await provider.stopRecording();
      if (mounted) {
        _showRecordingCompleteDialog();
      }
    } else {
      // Start recording
      final hasPermission = await _checkMicrophonePermission();
      if (hasPermission) {
        await provider.startRecording();
        _waveController.forward();
      } else {
        if (mounted) {
          _showPermissionDialog();
        }
      }
    }
  }

  Future<bool> _checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }
    
    return false;
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Microphone Permission Required'),
        content: const Text(
          'TalkNotes needs access to your microphone to record voice notes. Please grant permission in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showRecordingCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recording Complete'),
        content: const Text('Your voice note has been recorded successfully. What would you like to do next?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
            },
            child: const Text('Save & Go Back'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to note editing screen
            },
            child: const Text('Edit Note'),
          ),
        ],
      ),
    );
  }
}
