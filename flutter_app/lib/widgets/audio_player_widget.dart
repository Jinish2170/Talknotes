import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import '../services/audio_service.dart';

class AudioPlayerWidget extends StatefulWidget {
  final String audioPath;
  final String? title;
  final bool showTitle;
  final bool compact;

  const AudioPlayerWidget({
    super.key,
    required this.audioPath,
    this.title,
    this.showTitle = true,
    this.compact = false,
  });

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  AudioService? _audioService;
  bool _isCurrentAudio = false;

  @override
  void initState() {
    super.initState();
    // We'll inject the audio service through Provider or create one locally
    _audioService = AudioService();
  }

  @override
  void dispose() {
    _audioService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AudioService>.value(
      value: _audioService!,
      child: Consumer<AudioService>(
        builder: (context, audioService, child) {
          _isCurrentAudio = audioService.currentAudioPath == widget.audioPath;

          if (widget.compact) {
            return _buildCompactPlayer(audioService);
          } else {
            return _buildFullPlayer(audioService);
          }
        },
      ),
    );
  }

  Widget _buildCompactPlayer(AudioService audioService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause Button
          GestureDetector(
            onTap: () => _togglePlayback(audioService),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _isCurrentAudio && audioService.isPlaying
                    ? AppColors.primary
                    : AppColors.grey400,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getPlayButtonIcon(audioService),
                size: 16,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Duration
          Text(
            _isCurrentAudio
                ? audioService.formatDuration(audioService.currentPosition)
                : '0:00',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey600,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullPlayer(AudioService audioService) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Title
          if (widget.showTitle && widget.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                widget.title!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.grey900,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

          // Progress Bar
          Column(
            children: [
              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.primary,
                  inactiveTrackColor: AppColors.grey200,
                  thumbColor: AppColors.primary,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 12,
                  ),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _isCurrentAudio ? audioService.progress : 0.0,
                  onChanged: _isCurrentAudio
                      ? (value) => _seekToPosition(audioService, value)
                      : null,
                ),
              ),

              // Time Display
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isCurrentAudio
                          ? audioService.formatDuration(
                              audioService.currentPosition,
                            )
                          : '0:00',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey600,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      _isCurrentAudio
                          ? audioService.formatDuration(
                              audioService.totalDuration,
                            )
                          : '--:--',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.grey600,
                        fontFeatures: [const FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Speed Control
              _buildSpeedButton(audioService),

              // Skip Backward
              _buildControlButton(
                icon: Icons.replay_10,
                onTap: () => _skipBackward(audioService),
                enabled: _isCurrentAudio,
              ),

              // Play/Pause Button
              _buildMainPlayButton(audioService),

              // Skip Forward
              _buildControlButton(
                icon: Icons.forward_10,
                onTap: () => _skipForward(audioService),
                enabled: _isCurrentAudio,
              ),

              // Volume Control
              _buildVolumeButton(audioService),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainPlayButton(AudioService audioService) {
    return GestureDetector(
      onTap: () => _togglePlayback(audioService),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: audioService.isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              )
            : Icon(
                _getPlayButtonIcon(audioService),
                size: 24,
                color: Colors.white,
              ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: enabled ? AppColors.grey100 : AppColors.grey50,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.grey700 : AppColors.grey400,
        ),
      ),
    );
  }

  Widget _buildSpeedButton(AudioService audioService) {
    return GestureDetector(
      onTap: () => _showSpeedDialog(audioService),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.grey100,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '1x',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.grey700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeButton(AudioService audioService) {
    return GestureDetector(
      onTap: () => _showVolumeDialog(audioService),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.grey100,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.volume_up, size: 20, color: AppColors.grey700),
      ),
    );
  }

  IconData _getPlayButtonIcon(AudioService audioService) {
    if (!_isCurrentAudio) return Icons.play_arrow;

    switch (audioService.playerState) {
      case AudioPlayerState.playing:
        return Icons.pause;
      case AudioPlayerState.paused:
      case AudioPlayerState.stopped:
        return Icons.play_arrow;
      case AudioPlayerState.loading:
        return Icons.hourglass_empty;
      case AudioPlayerState.error:
        return Icons.error;
    }
  }

  Future<void> _togglePlayback(AudioService audioService) async {
    try {
      if (!_isCurrentAudio ||
          audioService.playerState == AudioPlayerState.stopped) {
        await audioService.playAudio(widget.audioPath);
      } else if (audioService.isPlaying) {
        await audioService.pauseAudio();
      } else {
        await audioService.resumeAudio();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _seekToPosition(AudioService audioService, double value) async {
    final position = Duration(
      milliseconds: (value * audioService.totalDuration.inMilliseconds).round(),
    );
    await audioService.seekTo(position);
  }

  Future<void> _skipBackward(AudioService audioService) async {
    final newPosition =
        audioService.currentPosition - const Duration(seconds: 10);
    await audioService.seekTo(
      newPosition.isNegative ? Duration.zero : newPosition,
    );
  }

  Future<void> _skipForward(AudioService audioService) async {
    final newPosition =
        audioService.currentPosition + const Duration(seconds: 10);
    final maxPosition = audioService.totalDuration;
    await audioService.seekTo(
      newPosition > maxPosition ? maxPosition : newPosition,
    );
  }

  void _showSpeedDialog(AudioService audioService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Playback Speed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map((speed) {
            return ListTile(
              title: Text('${speed}x'),
              onTap: () {
                audioService.setPlaybackSpeed(speed);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showVolumeDialog(AudioService audioService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Volume'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Slider(
              value: 1.0, // Would need to track current volume
              onChanged: (value) {
                audioService.setVolume(value);
                setState(() {});
              },
              min: 0.0,
              max: 1.0,
              divisions: 10,
            );
          },
        ),
      ),
    );
  }
}
