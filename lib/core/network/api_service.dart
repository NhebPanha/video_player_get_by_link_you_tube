import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../features/video_guidelines/data/models/video_guideline_model.dart';

class ApiService {
  // Simulating an API delay
  Future<List<VideoGuideline>> fetchVideos({int page = 1, int limit = 10}) async {
    await Future.delayed(const Duration(seconds: 1));

    // Sample JSON response
    final String responseBody = '''
    [
      {
        "id": "vid_01",
        "title": "Welcome to the Platform",
        "description": "A quick introduction to getting started.",
        "youtubeUrl": "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
        "thumbnail": "https://img.youtube.com/vi/dQw4w9WgXcQ/0.jpg",
        "duration": "3:32"
      },
      {
        "id": "vid_02",
        "title": "Security Guidelines",
        "description": "Learn how to keep your account secure.",
        "youtubeUrl": "https://www.youtube.com/watch?v=jNQXAC9IVRw",
        "thumbnail": "https://img.youtube.com/vi/jNQXAC9IVRw/0.jpg",
        "duration": "0:19"
      },
      {
        "id": "vid_03",
        "title": "Advanced Features Tutorial",
        "description": "Deep dive into advanced features.",
        "youtubeUrl": "https://www.youtube.com/watch?v=tPEE9ZwTmy0",
        "thumbnail": "https://img.youtube.com/vi/tPEE9ZwTmy0/0.jpg",
        "duration": "1:25"
      },
      {
        "id": "vid_04",
        "title": "Community Rules",
        "description": "Understanding our community guidelines.",
        "youtubeUrl": "https://www.youtube.com/watch?v=vVceE8OA7Xw",
        "thumbnail": "https://img.youtube.com/vi/vVceE8OA7Xw/0.jpg",
        "duration": "2:10"
      },
      {
        "id": "vid_05",
        "title": "Troubleshooting Common Issues",
        "description": "How to fix the most common problems.",
        "youtubeUrl": "https://www.youtube.com/watch?v=1b-b461_oIE",
        "thumbnail": "https://img.youtube.com/vi/1b-b461_oIE/0.jpg",
        "duration": "4:45"
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
