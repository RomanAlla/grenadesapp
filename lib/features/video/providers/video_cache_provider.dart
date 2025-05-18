import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grenadesapp/features/video/services/video_cache_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences должен быть инициализирован');
});

final videoCacheProvider = Provider<VideoCacheService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return VideoCacheService(prefs);
});
