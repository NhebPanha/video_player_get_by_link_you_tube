import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../data/models/video_guideline_model.dart';
import '../bloc/video_guidelines_bloc.dart';
import '../bloc/video_guidelines_event.dart';
import '../widgets/custom_player_controls.dart';

class SecureVideoPlayerScreen extends StatefulWidget {
  final VideoGuideline video;

  const SecureVideoPlayerScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<SecureVideoPlayerScreen> createState() => _SecureVideoPlayerScreenState();
}

class _SecureVideoPlayerScreenState extends State<SecureVideoPlayerScreen> {
  late YoutubePlayerController _controller;
  bool _isPlaying = true;
  double _progress = 0.0;
  Timer? _progressTimer;

  @override
  void initState() {
    super.initState();
    
    final videoId = YoutubePlayerController.convertUrlToId(widget.video.youtubeUrl) ?? '';

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: false,
        showFullscreenButton: false,
        strictRelatedVideos: true,
        enableKeyboard: false,
        enableJavaScript: true, // Needed for API
        pointerEvents: PointerEvents.none, // Try to disable pointer events on web
      ),
    );

    // Initial seek if progress is saved and not completed
    if (widget.video.progress > 0 && !widget.video.isCompleted) {
      _controller.listen((event) {
        if (event.playerState == PlayerState.playing && _progress == 0.0) {
          // Calculate start time based on progress
          event.metaData.duration.inSeconds;
          final durationSecs = event.metaData.duration.inSeconds;
          if (durationSecs > 0) {
             final startSeconds = (widget.video.progress / 100) * durationSecs;
             _controller.seekTo(seconds: startSeconds, allowSeekAhead: true);
          }
        }
      });
    }

    // Start timer to periodically track and save progress
    _progressTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final duration = await _controller.duration;
      final position = await _controller.currentTime;
      final state = await _controller.playerState;

      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
          if (duration > 0) {
            _progress = position / duration;
          }
        });

        // Save progress to bloc (and shared prefs)
        if (duration > 0 && _isPlaying) {
          final percentage = (_progress * 100).clamp(0.0, 100.0);
          context.read<VideoGuidelinesBloc>().add(
            UpdateVideoProgressEvent(widget.video.id, percentage),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    _controller.close();
    super.dispose();
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _controller.pauseVideo();
    } else {
      _controller.playVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.title),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                // IgnorePointer completely blocks user from interacting with iframe directly
                IgnorePointer(
                  child: YoutubePlayer(
                    controller: _controller,
                    backgroundColor: Colors.black,
                  ),
                ),
                // Custom controls overlay
                Positioned.fill(
                  child: CustomPlayerControls(
                    isPlaying: _isPlaying,
                    onPlayPause: _togglePlayPause,
                    progress: _progress,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
