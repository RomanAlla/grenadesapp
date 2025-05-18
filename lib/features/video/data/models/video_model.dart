import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grenadesapp/features/video/providers/video_cache_provider.dart';

class VideoModel {
  final String id;
  final String mapName;
  final String grenadeType;
  final String videoUrl;
  final String description;

  VideoModel({
    required this.id,
    required this.mapName,
    required this.grenadeType,
    required this.videoUrl,
    required this.description,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json,
      {String defaultMapName = ''}) {
    return VideoModel(
      id: json['id'] ?? '',
      mapName: (json['mapName'] ?? defaultMapName).toLowerCase(),
      grenadeType: json['type']?.toString() ?? 'unknown',
      videoUrl: json['videoUrl']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mapName': mapName,
      'type': grenadeType,
      'videoUrl': videoUrl,
      'description': description,
    };
  }

  Future<List<VideoModel>> getVideos(String mapName) async {
    try {
      final mapPath = mapName.toLowerCase().trim();

      final mapDoc = await FirebaseFirestore.instance
          .collection('maps')
          .doc(mapPath)
          .get();

      if (!mapDoc.exists) {
        return [];
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('maps')
          .doc(mapPath)
          .collection('grenades')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final firstDoc = querySnapshot.docs.first;
        print('First grenade data: ${firstDoc.data()}');
      }

      return querySnapshot.docs
          .map((doc) => VideoModel(
                id: doc.id,
                mapName: mapPath,
                grenadeType: (doc.data()['type'] ?? '').toString(),
                videoUrl: (doc.data()['videoUrl'] ?? '').toString(),
                description: (doc.data()['description'] ?? '').toString(),
              ))
          .toList();
    } catch (e) {
      print('Error getting videos: $e');
      return [];
    }
  }


  Future<String?> getCachedVideoUrl(WidgetRef ref) async {
    final videoCache = ref.read(videoCacheProvider);
    return await videoCache.getCachedVideo(id, videoUrl);
  }
}
