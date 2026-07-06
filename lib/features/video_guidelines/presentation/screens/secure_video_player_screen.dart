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

  void _update() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  void _markAsCompleted() {
    context.read<VideoGuidelinesBloc>().add(
      UpdateVideoProgressEvent(widget.video.id, 100.0),
    );
  }

  @override
  void dispose() {
    _controller?.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // Video Player Section
          Expanded(
            flex: 2,
            child: OmniVideoPlayer(
              callbacks: VideoPlayerCallbacks(
                onControllerCreated: (controller) {
                  _controller?.removeListener(_update);
                  _controller = controller..addListener(_update);
                },
                onFinished: _markAsCompleted,
              ),
              configuration: VideoPlayerConfiguration(
                videoSourceConfiguration:
                    VideoSourceConfiguration.youtube(
                      videoUrl: Uri.parse(widget.video.youtubeUrl),
                      enableYoutubeWebViewFallback: true,
                    ).copyWith(
                      autoPlay: true,
                      initialVolume: 1.0,
                      allowSeeking: true,
                    ),
                playerTheme: OmniVideoPlayerThemeData().copyWith(
                  icons: VideoPlayerIconTheme().copyWith(
                    error: Icons.warning,
                    playbackSpeedButton: Icons.speed,
                  ),
                ),
                playerUIVisibilityOptions: PlayerUIVisibilityOptions().copyWith(
                  showSeekBar: true,
                  showCurrentTime: true,
                  showDurationTime: true,
                  showLoadingWidget: true,
                  showErrorPlaceholder: true,
                  showReplayButton: true,
                  showFullScreenButton: true,
                  showMuteUnMuteButton: true,
                  showPlayPauseReplayButton: true,
                  fitVideoToBounds: true,
                ),
                customPlayerWidgets: CustomPlayerWidgets().copyWith(
                  loadingWidget: const Center(
                    child: CircularProgressIndicator(color: Colors.red),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
