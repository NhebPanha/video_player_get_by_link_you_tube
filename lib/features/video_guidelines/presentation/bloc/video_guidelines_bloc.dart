import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/video_guideline_model.dart';
import '../../data/repositories/video_guideline_repository.dart';
import 'video_guidelines_event.dart';
import 'video_guidelines_state.dart';

class VideoGuidelinesBloc extends Bloc<VideoGuidelinesEvent, VideoGuidelinesState> {
  final VideoGuidelineRepository repository;
  
  List<VideoGuideline> _allVideos = [];
  int _currentPage = 1;
  final int _limit = 10;
  bool _isFetching = false;

  VideoGuidelinesBloc({required this.repository}) : super(VideoGuidelinesInitial()) {
    on<FetchVideos>(_onFetchVideos);
    on<LoadMoreVideos>(_onLoadMoreVideos);
    on<SearchVideos>(_onSearchVideos);
    on<UpdateVideoProgressEvent>(_onUpdateVideoProgress);
  }

  Future<void> _onFetchVideos(FetchVideos event, Emitter<VideoGuidelinesState> emit) async {
    if (event.isRefresh) {
      _currentPage = 1;
      _allVideos.clear();
    } else {
      emit(VideoGuidelinesLoading());
    }

    try {
      final videos = await repository.getVideos(page: _currentPage, limit: _limit);
      _allVideos = videos;
      
      emit(VideoGuidelinesLoaded(
        videos: videos,
        hasReachedMax: videos.length < _limit,
      ));
    } catch (e) {
      emit(VideoGuidelinesError(e.toString()));
    }
  }

  Future<void> _onLoadMoreVideos(LoadMoreVideos event, Emitter<VideoGuidelinesState> emit) async {
    if (_isFetching) return;
    
    final currentState = state;
    if (currentState is VideoGuidelinesLoaded && !currentState.hasReachedMax && currentState.searchQuery.isEmpty) {
      _isFetching = true;
      _currentPage++;
      
      try {
        final moreVideos = await repository.getVideos(page: _currentPage, limit: _limit);
        _allVideos.addAll(moreVideos);
        
        emit(VideoGuidelinesLoaded(
          videos: List.of(_allVideos),
          hasReachedMax: moreVideos.isEmpty,
          searchQuery: currentState.searchQuery,
        ));
      } catch (e) {
        // If it fails, we keep the old state but maybe show a snackbar in UI
        emit(VideoGuidelinesError(e.toString()));
      } finally {
        _isFetching = false;
      }
    }
  }

  void _onSearchVideos(SearchVideos event, Emitter<VideoGuidelinesState> emit) {
    final currentState = state;
    if (currentState is VideoGuidelinesLoaded) {
      final query = event.query.toLowerCase();
      
      if (query.isEmpty) {
        emit(currentState.copyWith(videos: _allVideos, searchQuery: ''));
        return;
      }

      final filteredVideos = _allVideos.where((video) {
        return video.title.toLowerCase().contains(query) || 
               video.description.toLowerCase().contains(query);
      }).toList();

      emit(currentState.copyWith(videos: filteredVideos, searchQuery: query));
    }
  }

  Future<void> _onUpdateVideoProgress(UpdateVideoProgressEvent event, Emitter<VideoGuidelinesState> emit) async {
    final currentState = state;
    if (currentState is VideoGuidelinesLoaded) {
      await repository.saveVideoProgress(event.videoId, event.progress);
      
      final updatedVideos = currentState.videos.map((video) {
        if (video.id == event.videoId) {
          return video.copyWith(
            progress: event.progress,
            isCompleted: event.progress >= 90.0 || video.isCompleted,
          );
        }
        return video;
      }).toList();

      // Also update the cached _allVideos
      final updatedAllVideos = _allVideos.map((video) {
        if (video.id == event.videoId) {
          return video.copyWith(
            progress: event.progress,
            isCompleted: event.progress >= 90.0 || video.isCompleted,
          );
        }
        return video;
      }).toList();
      
      _allVideos = updatedAllVideos;

      emit(currentState.copyWith(videos: updatedVideos));
    }
  }
}
