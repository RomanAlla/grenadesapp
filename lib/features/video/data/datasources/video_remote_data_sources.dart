import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grenadesapp/features/video/data/models/video_model.dart';

class VideoRemoteDataSources {
  final FirebaseFirestore firestore;

  VideoRemoteDataSources({required this.firestore});

  Future<List<VideoModel>> getVideos(String mapName) async {
    if (mapName.isEmpty) {
      print('Пустое имя карты');
      return [];
    }

    try {
      print('=== Начало загрузки видео ===');
      print('Получение видео для карты: $mapName');

      final normalizedMapName = mapName.toLowerCase().trim();

      final mapRef = firestore.collection('maps').doc(normalizedMapName);
      print('Путь к документу: ${mapRef.path}');

      final mapDoc = await mapRef.get().catchError((error) {
        print('Ошибка доступа к Firestore: $error');
        return null;
      });

      if (!mapDoc.exists) {
        print('Документ карты не найден для: $normalizedMapName');
        return [];
      }

      final grenadesRef = mapRef.collection('grenades');
      final querySnapshot = await grenadesRef.get().catchError((error) {
        print('Ошибка при получении гранат: $error');
        return null;
      });

      print('Количество найденных документов: ${querySnapshot.docs.length}');

      final videos = querySnapshot.docs.map((doc) {
        final data = doc.data();
        print('Обработка документа ${doc.id}: $data');

        return VideoModel(
          id: doc.id,
          mapName: normalizedMapName,
          grenadeType: data['type']?.toString() ?? 'unknown',
          videoUrl: data['videoUrl']?.toString() ?? '',
          description: data['description']?.toString() ?? '',
        );
      }).toList();

      print('=== Загружено ${videos.length} видео ===');
      return videos;
    } catch (e) {
      print('Ошибка при получении видео: $e');
      print(e.toString());
      return [];
    }
  }
}
