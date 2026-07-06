import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/network/api_service.dart';
import 'features/video_guidelines/data/repositories/video_guideline_repository.dart';
import 'features/video_guidelines/presentation/bloc/video_guidelines_bloc.dart';
import 'features/video_guidelines/presentation/bloc/video_guidelines_event.dart';
import 'features/video_guidelines/presentation/screens/video_guidelines_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide the repository and bloc at the root or feature level
    return RepositoryProvider(
      create: (context) => VideoGuidelineRepository(apiService: ApiService()),
      child: BlocProvider(
        create: (context) => VideoGuidelinesBloc(
          repository: context.read<VideoGuidelineRepository>(),
        )..add(const FetchVideos()),
        child: MaterialApp(
          title: 'Video Guidelines',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              centerTitle: true,
              elevation: 0,
            ),
          ),
          home: const VideoGuidelinesScreen(),
        ),
      ),
    );
  }
}
