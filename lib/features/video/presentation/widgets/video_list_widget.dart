import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grenadesapp/features/video/presentation/providers/video_provider.dart';
import 'package:grenadesapp/features/video/data/models/video_model.dart';
import 'package:grenadesapp/features/video/presentation/views/video_detail_page.dart';

class VideoListWidget extends ConsumerWidget {
  final String searchQuery;
  final String? selectedType;
  final String mapName;

  const VideoListWidget({
    super.key,
    this.searchQuery = '',
    this.selectedType,
    required this.mapName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final videosAsync = ref.watch(filteredVideoProvider);

    return videosAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Ошибка загрузки: $error'),
      ),
      data: (List<VideoModel> videos) {
        var filteredVideos = videos.where((VideoModel video) {
          final matchesSearch = video.description.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ??
              false;
          final matchesType = selectedType == null ||
              video.grenadeType.toLowerCase() == selectedType?.toLowerCase();
          return matchesSearch && matchesType;
        }).toList();

        if (filteredVideos.isNotEmpty) {
    
          for (final video in filteredVideos) {
            if (video.videoUrl.isNotEmpty) {
           
              video.getCachedVideoUrl(ref);
            }
          }
        }

        if (filteredVideos.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.orange),
                SizedBox(height: 16),
                Text('Ничего не найдено',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredVideos.length,
          itemBuilder: (context, index) {
            final video = filteredVideos[index];
            return _GrenadeCard(video: video, mapName: mapName);
          },
        );
      },
    );
  }
}

class _GrenadeCard extends StatelessWidget {
  final VideoModel video;
  final String mapName;

  const _GrenadeCard({required this.video, required this.mapName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  VideoDetailPage(video: video, mapName: mapName),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getGrenadeIcon(video.grenadeType),
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.description ?? 'Без описания',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      video.grenadeType.toUpperCase(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.orange.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.orange,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getGrenadeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'smoke':
        return Icons.cloud;
      case 'flash':
        return Icons.flash_on;
      case 'he':
        return Icons.sports_hockey;
      case 'molotov':
        return Icons.local_fire_department;
      default:
        return Icons.sports_hockey;
    }
  }
}
