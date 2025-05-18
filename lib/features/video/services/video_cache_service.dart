import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;


class VideoCacheMetadata {
  final String url;
  final DateTime lastAccessed;
  final int size;
  final String localPath;

  VideoCacheMetadata({
    required this.url,
    required this.lastAccessed,
    required this.size,
    required this.localPath,
  });

  Map<String, dynamic> toJson() => {
        'url': url,
        'lastAccessed': lastAccessed.toIso8601String(),
        'size': size,
        'localPath': localPath,
      };

  factory VideoCacheMetadata.fromJson(Map<String, dynamic> json) {
    return VideoCacheMetadata(
      url: json['url'],
      lastAccessed: DateTime.parse(json['lastAccessed']),
      size: json['size'],
      localPath: json['localPath'],
    );
  }
}

class VideoCacheService {
  static const String _cacheKey = 'video_cache';
  static const String _metadataKey = 'video_metadata';
  final SharedPreferences _prefs;
  final Map<String, VideoCacheMetadata> _metadata = {};

  VideoCacheService(this._prefs) {
    _loadMetadata();
  }


  Future<void> _loadMetadata() async {
    final String? metadataJson = _prefs.getString(_metadataKey);
    if (metadataJson != null) {
      final Map<String, dynamic> decoded = json.decode(metadataJson);
      _metadata.clear();
      decoded.forEach((key, value) {
        _metadata[key] = VideoCacheMetadata.fromJson(value);
      });
    }
  }

  // Сохранение метаданных в SharedPreferences
  Future<void> _saveMetadata() async {
    final Map<String, dynamic> encoded = {};
    _metadata.forEach((key, value) {
      encoded[key] = value.toJson();
    });
    await _prefs.setString(_metadataKey, json.encode(encoded));
  }

 
  Future<String?> getCachedVideo(String videoId, String videoUrl) async {
    final metadata = _metadata[videoId];

    if (metadata != null) {
      final file = File(metadata.localPath);
      if (await file.exists()) {
 
        _metadata[videoId] = VideoCacheMetadata(
          url: metadata.url,
          lastAccessed: DateTime.now(),
          size: metadata.size,
          localPath: metadata.localPath,
        );
        await _saveMetadata();
        return metadata.localPath;
      }
    }

    
    return await _cacheVideo(videoId, videoUrl);
  }

 
  Future<String?> _cacheVideo(String videoId, String videoUrl) async {
    try {
     
      final cacheDir = await getTemporaryDirectory();
      final videoDir = Directory('${cacheDir.path}/videos');
      if (!await videoDir.exists()) {
        await videoDir.create(recursive: true);
      }

     
      final fileName = '$videoId.mp4';
      final filePath = '${videoDir.path}/$fileName';

     
      final response = await http.get(Uri.parse(videoUrl));
      if (response.statusCode == 200) {
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

    
        _metadata[videoId] = VideoCacheMetadata(
          url: videoUrl,
          lastAccessed: DateTime.now(),
          size: response.bodyBytes.length,
          localPath: filePath,
        );
        await _saveMetadata();

        return filePath;
      }
    } catch (e) {
      print('Ошибка кэширования видео: $e');
    }
    return null;
  }


  Future<void> clearCache() async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final videoDir = Directory('${cacheDir.path}/videos');

      if (await videoDir.exists()) {
        await videoDir.delete(recursive: true);
      }

      _metadata.clear();
      await _saveMetadata();
    } catch (e) {
      print('Ошибка очистки кэша: $e');
    }
  }


  Future<int> getCacheSize() async {
    int totalSize = 0;
    _metadata.forEach((_, metadata) {
      totalSize += metadata.size;
    });
    return totalSize;
  }
}
