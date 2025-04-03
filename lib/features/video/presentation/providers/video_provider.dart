import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grenadesapp/features/video/domain/usecases/get_videos_use_case.dart';
import 'package:grenadesapp/features/video/data/models/video_model.dart';

final getVideosUseCaseProvider = Provider<GetVideosUseCase>((ref) {
  throw UnimplementedError();
});

final selectedMapProvider = StateProvider<String>((ref) => '');

final videoProvider = FutureProvider<List<VideoModel>>((ref) async {
  final getVideosUseCase = ref.watch(getVideosUseCaseProvider);
  final selectedMap = ref.watch(selectedMapProvider);

  if (selectedMap.isEmpty) {
    return [];
  }

  try {
    return await getVideosUseCase.call(mapName: selectedMap);
  } catch (e) {
    print('Ошибка при загрузке видео: $e');
    return [];
  }
});

final filteredVideoProvider = FutureProvider<List<VideoModel>>((ref) async {
  final videos = await ref.watch(videoProvider.future);
  final selectedMap = ref.watch(selectedMapProvider);

  if (selectedMap.isEmpty) {
    return videos;
  }

  return videos
      .where(
          (video) => video.mapName.toLowerCase() == selectedMap.toLowerCase())
      .toList();
});
