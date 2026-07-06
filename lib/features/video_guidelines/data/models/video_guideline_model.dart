import 'package:equatable/equatable.dart';

class VideoGuideline extends Equatable {
  final String id;
  final String title;
  final String description;
  final String youtubeUrl;
  final String thumbnail;
  final String duration;
  final double progress;
  final bool isCompleted;

  const VideoGuideline({
    required this.id,
    required this.title,
    required this.description,
    required this.youtubeUrl,
    required this.thumbnail,
    required this.duration,
    this.progress = 0.0,
    this.isCompleted = false,
  });

  factory VideoGuideline.fromJson(Map<String, dynamic> json) {
    return VideoGuideline(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      youtubeUrl: json['youtubeUrl'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      duration: json['duration'] ?? '',
    );
  }

  VideoGuideline copyWith({
    String? id,
    String? title,
    String? description,
    String? youtubeUrl,
    String? thumbnail,
    String? duration,
    double? progress,
    bool? isCompleted,
  }) {
    return VideoGuideline(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      thumbnail: thumbnail ?? this.thumbnail,
      duration: duration ?? this.duration,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        youtubeUrl,
        thumbnail,
        duration,
        progress,
        isCompleted,
      ];
}
