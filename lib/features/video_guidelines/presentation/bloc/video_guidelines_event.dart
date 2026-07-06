import 'package:equatable/equatable.dart';

abstract class VideoGuidelinesEvent extends Equatable {
  const VideoGuidelinesEvent();

  @override
  List<Object?> get props => [];
}

class FetchVideos extends VideoGuidelinesEvent {
  final bool isRefresh;
  const FetchVideos({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class LoadMoreVideos extends VideoGuidelinesEvent {}

class SearchVideos extends VideoGuidelinesEvent {
  final String query;
  const SearchVideos(this.query);

  @override
  List<Object?> get props => [query];
}

class UpdateVideoProgressEvent extends VideoGuidelinesEvent {
  final String videoId;
  final double progress;

  const UpdateVideoProgressEvent(this.videoId, this.progress);

  @override
  List<Object?> get props => [videoId, progress];
}
