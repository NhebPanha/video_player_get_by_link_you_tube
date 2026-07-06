import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/video_guidelines_bloc.dart';
import '../bloc/video_guidelines_event.dart';
import '../bloc/video_guidelines_state.dart';
import '../widgets/shimmer_loading.dart';
import '../widgets/video_card.dart';

class VideoGuidelinesScreen extends StatefulWidget {
  const VideoGuidelinesScreen({Key? key}) : super(key: key);

  @override
  State<VideoGuidelinesScreen> createState() => _VideoGuidelinesScreenState();
}

class _VideoGuidelinesScreenState extends State<VideoGuidelinesScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<VideoGuidelinesBloc>().add(LoadMoreVideos());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Guidelines'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search guidelines...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: (query) {
                context.read<VideoGuidelinesBloc>().add(SearchVideos(query));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<VideoGuidelinesBloc, VideoGuidelinesState>(
              builder: (context, state) {
                if (state is VideoGuidelinesInitial || state is VideoGuidelinesLoading) {
                  return const ShimmerLoading();
                } else if (state is VideoGuidelinesError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${state.message}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<VideoGuidelinesBloc>().add(const FetchVideos(isRefresh: true));
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (state is VideoGuidelinesLoaded) {
                  if (state.videos.isEmpty) {
                    return const Center(
                      child: Text('No videos found.'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<VideoGuidelinesBloc>().add(const FetchVideos(isRefresh: true));
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.hasReachedMax
                          ? state.videos.length
                          : state.videos.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.videos.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return VideoCard(video: state.videos[index]);
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
