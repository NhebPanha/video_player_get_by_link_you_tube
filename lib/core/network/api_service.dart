import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/video_guidelines/data/models/video_guideline_model.dart';

class ApiService {
  // Simulating an API delay
  Future<List<VideoGuideline>> fetchVideos({
    int page = 1,
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // Sample JSON response
    final String responseBody = '''
    [
      {
        "id": "vid_01",
        "title": "Welcome to the Platform",
        "description": "A quick introduction to getting started.",
        "youtubeUrl": "https://youtu.be/gh99X1BDP44?si=PmqMaTsw4klc2J48",
        "thumbnail": "https://youtu.be/gh99X1BDP44?si=PmqMaTsw4klc2J48",
        "duration": "3:32"
      }
    ]
    ''';

    final List<dynamic> jsonList = json.decode(responseBody);

    // Simulate pagination
    final startIndex = (page - 1) * limit;
    if (startIndex >= jsonList.length) {
      return [];
    }

    final endIndex = (startIndex + limit) > jsonList.length
        ? jsonList.length
        : (startIndex + limit);

    final paginatedList = jsonList.sublist(startIndex, endIndex);

    return paginatedList.map((json) => VideoGuideline.fromJson(json)).toList();
  }
}
