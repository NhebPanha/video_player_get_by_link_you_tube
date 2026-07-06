import 'package:equatable/equatable.dart';
import '../../data/models/video_guideline_model.dart';

abstract class VideoGuidelinesState extends Equatable {
  const VideoGuidelinesState();

  @override
  List<Object?> get props => [];
}

class VideoGuidelinesInitial extends VideoGuidelinesState {}

class VideoGuidelinesLoading extends VideoGuidelinesState {}

class VideoGuidelinesLoaded extends VideoGuidelinesState {
  final List<VideoGuideline> videos;
  final bool hasReachedMax;
  final String searchQuery;

  const VideoGuidelinesLoaded({
    required this.videos,
    this.hasReachedMax = false,
    this.searchQuery = '',
  });

  VideoGuidelinesLoaded copyWith({
    List<VideoGuideline>? videos,
    bool? hasReachedMax,
    String? searchQuery,
  }) {
    return VideoGuidelinesLoaded(
      videos: videos ?? this.videos,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [videos, hasReachedMax, searchQuery];
}

class VideoGuidelinesError extends VideoGuidelinesState {
  final String message;

  const VideoGuidelinesError(this.message);

  @override
  List<Object?> get props => [message];
}
