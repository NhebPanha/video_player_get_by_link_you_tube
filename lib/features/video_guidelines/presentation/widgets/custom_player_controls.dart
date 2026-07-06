import 'package:flutter/material.dart';

class CustomPlayerControls extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final double progress; // 0.0 to 1.0

  const CustomPlayerControls({
    Key? key,
    required this.isPlaying,
    required this.onPlayPause,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent, // Allow taps to pass to the controls overlay, not through to iframe
      child: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTap: onPlayPause,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[800],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}
