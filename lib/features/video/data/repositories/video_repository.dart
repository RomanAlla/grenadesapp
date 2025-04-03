import 'package:grenadesapp/features/video/data/datasources/video_remote_data_sources.dart';
import 'package:grenadesapp/features/video/data/models/video_model.dart';

class VideoRepository {
  final VideoRemoteDataSources dataSource;

  VideoRepository({required this.dataSource});

  Future<List<VideoModel>> getVideos(String mapName) async {
    return await dataSource.getVideos(mapName);
  }
}
