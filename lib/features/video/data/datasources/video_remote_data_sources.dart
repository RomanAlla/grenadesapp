import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grenadesapp/features/video/data/models/video_model.dart';

class VideoRemoteDataSources {
  final FirebaseFirestore firestore;

  VideoRemoteDataSources({required this.firestore});

  Future<List<VideoModel>> getVideos(String mapName) async {
    if (mapName.isEmpty) {
      return [];
    }

    try {
      final normalizedMapName = mapName.toLowerCase().trim();

      final mapRef = firestore.collection('maps').doc(normalizedMapName);

      final mapDoc = await mapRef.get().catchError((error) {
        return null;
      });

      if (!mapDoc.exists) {
        return [];
      }

      final grenadesRef = mapRef.collection('grenades');
      final querySnapshot = await grenadesRef.get().catchError((error) {
        return null;
      });

      final videos = querySnapshot.docs.map((doc) {
        final data = doc.data();

        return VideoModel(
          id: doc.id,
          mapName: normalizedMapName,
          grenadeType: data['type']?.toString() ?? 'unknown',
          videoUrl: data['videoUrl']?.toString() ?? '',
          description: data['description']?.toString() ?? '',
        );
      }).toList();

      return videos;
    } catch (e) {
      print('Ошибка при получении видео: $e');
      print(e.toString());
      return [];
    }
  }
}
