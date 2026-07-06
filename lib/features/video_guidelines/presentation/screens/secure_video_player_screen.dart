import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:omni_video_player/omni_video_player.dart';
import '../../data/models/video_guideline_model.dart';
import '../bloc/video_guidelines_bloc.dart';
import '../bloc/video_guidelines_event.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoGuideline video;

  const VideoPlayerScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  OmniPlaybackController? _controller;
  double _progress = 0.0;
  Timer? _progressTimer;

  void _update() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    // Position tracking removed as OmniPlaybackController does not expose current position directly in this version
  }

  void _saveProgress() {
    final percentage = (_progress * 100).clamp(0.0, 100.0);
    context.read<VideoGuidelinesBloc>().add(
      UpdateVideoProgressEvent(widget.video.id, percentage),
    );
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _controller?.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.video.title)),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: OmniVideoPlayer(
              callbacks: VideoPlayerCallbacks(
                onControllerCreated: (controller) {
                  _controller?.removeListener(_update);
                  _controller = controller..addListener(_update);
                  
                  // Initial Seek if we have saved progress
                  if (widget.video.progress > 0 && !widget.video.isCompleted) {
                     Future.delayed(const Duration(milliseconds: 500), () {
                        if (_controller != null) {
                           final durationMs = _controller!.duration.inMilliseconds;
                           if (durationMs > 0) {
                             final targetPos = Duration(milliseconds: ((widget.video.progress / 100) * durationMs).toInt());
                             _controller!.seekTo(targetPos);
                           }
                        }
                     });
                  }
                },
                onFinished: () {
                  _progress = 1.0;
                  _saveProgress();
                },
                // Add default empty callbacks required by OmniVideoPlayer if needed
                onFullScreenToggled: (isFullScreen) {},
                onOverlayControlsVisibilityChanged: (areVisible) {},
                onCenterControlsVisibilityChanged: (areVisible) {},
                onMuteToggled: (isMute) {},
                onSeekStart: (pos) {},
                onSeekEnd: (pos) {},
                onSeekRequest: (target) => true,
                onReplay: () {},
              ),
              configuration: VideoPlayerConfiguration(
                videoSourceConfiguration: VideoSourceConfiguration.youtube(
                  videoUrl: Uri.parse(widget.video.youtubeUrl),
                  preferredQualities: [OmniVideoQuality.high720, OmniVideoQuality.medium480],
                  availableQualities: [OmniVideoQuality.high1080, OmniVideoQuality.high720, OmniVideoQuality.medium480],
                  enableYoutubeWebViewFallback: true,
                  forceYoutubeWebViewOnly: false,
                ).copyWith(
                  autoPlay: true,
                  initialPosition: Duration.zero,
                  initialVolume: 1.0,
                  initialPlaybackSpeed: 1.0,
                  availablePlaybackSpeed: [0.5, 1.0, 1.25, 1.5, 2.0],
                  autoMuteOnStart: false,
                  allowSeeking: true,
                  synchronizeMuteAcrossPlayers: true,
                  timeoutDuration: const Duration(seconds: 30),
                ),
                playerTheme: OmniVideoPlayerThemeData().copyWith(
                  icons: VideoPlayerIconTheme().copyWith(
                    error: Icons.warning,
                    playbackSpeedButton: Icons.speed,
                  ),
                  // Removed invalid backdrop property
                ),
                playerUIVisibilityOptions: PlayerUIVisibilityOptions().copyWith(
                  showSeekBar: true,
                  showCurrentTime: true,
                  showDurationTime: true,
                  showRemainingTime: true,
                  showLiveIndicator: false,
                  showLoadingWidget: true,
                  showErrorPlaceholder: true,
                  showReplayButton: true,
                  showThumbnailAtStart: true,
                  showVideoBottomControlsBar: true,
                  showBottomControlsBarOnEndedFullscreen: true,
                  showFullScreenButton: true,
                  showSwitchVideoQuality: true,
                  showSwitchWhenOnlyAuto: true,
                  showPlaybackSpeedButton: true,
                  showMuteUnMuteButton: true,
                  showPlayPauseReplayButton: true,
                  useSafeAreaForBottomControls: true,
                  showGradientBottomControl: true,
                  enableForwardGesture: true,
                  enableBackwardGesture: true,
                  enableExitFullscreenOnVerticalSwipe: true,
                  enableOrientationLock: true,
                  controlsPersistenceDuration: const Duration(seconds: 3),
                  showBottomControlsBarOnPause: false,
                  alwaysShowBottomControlsBar: false,
                  fitVideoToBounds: true,
                ),
                customPlayerWidgets: CustomPlayerWidgets().copyWith(
                  loadingWidget: const Center(child: CircularProgressIndicator(color: Colors.red)),
                ),
                enableBackgroundOverlayClip: true,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.video.isCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text('Completed', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    widget.video.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),
                  // Additional controls as requested by the user snippet
                  Center(
                    child: Builder(
                      builder: (context) {
                        if (_controller == null) {
                          return const CircularProgressIndicator();
                        }

                        final isPlaying = _controller!.isPlaying;

                        return ElevatedButton.icon(
                          onPressed: () {
                            isPlaying ? _controller!.pause() : _controller!.play();
                          },
                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                          label: Text(isPlaying ? 'Pause Video' : 'Play Video'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            textStyle: const TextStyle(fontSize: 18),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
