import 'package:grenadesapp/features/video/data/models/video_model.dart';
import 'package:grenadesapp/features/video/data/repositories/video_repository.dart';

class GetVideosUseCase {
  final VideoRepository repository;

  GetVideosUseCase({required this.repository});

  Future<List<VideoModel>> call({required String mapName}) async {
    return await repository.getVideos(mapName);
  }
}
