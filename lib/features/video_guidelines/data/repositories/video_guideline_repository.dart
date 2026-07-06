import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_service.dart';
import '../models/video_guideline_model.dart';

class VideoGuidelineRepository {
  final ApiService apiService;

  VideoGuidelineRepository({required this.apiService});

  Future<List<VideoGuideline>> getVideos({int page = 1, int limit = 10}) async {
    try {
      final videos = await apiService.fetchVideos(page: page, limit: limit);
      return await _applyLocalProgress(videos);
    } catch (e) {
      throw Exception('Failed to fetch videos: $e');
    }
  }

  Future<List<VideoGuideline>> _applyLocalProgress(List<VideoGuideline> videos) async {
    final prefs = await SharedPreferences.getInstance();
    
    return videos.map((video) {
      final progressKey = 'progress_${video.id}';
      final completedKey = 'completed_${video.id}';
      
      final savedProgress = prefs.getDouble(progressKey) ?? 0.0;
      final isCompleted = prefs.getBool(completedKey) ?? false;
      
      return video.copyWith(
        progress: savedProgress,
        isCompleted: isCompleted,
      );
    }).toList();
  }

  Future<void> saveVideoProgress(String videoId, double progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('progress_$videoId', progress);
    
    // Mark as completed if > 90%
    if (progress >= 90.0) {
      await prefs.setBool('completed_$videoId', true);
    }
  }
}
