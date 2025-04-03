import 'package:cloud_firestore/cloud_firestore.dart';

class GrenadeService {
  final FirebaseFirestore firestore;
  // Кэш для хранения количества гранат
  final Map<String, int> _grenadeCountCache = {};

  GrenadeService({required this.firestore});

  Future<int> getGrenadeCountForMap(String mapName) async {
    try {
      // Нормализуем имя карты
      final normalizedMapName = mapName.toLowerCase().trim();

      print('=== Получение количества гранат ===');
      print('Карта: $normalizedMapName');

      if (_grenadeCountCache.containsKey(normalizedMapName)) {
        print('Возвращаем из кэша: ${_grenadeCountCache[normalizedMapName]}');
        return _grenadeCountCache[normalizedMapName]!;
      }

      final docRef = firestore.collection('maps').doc(normalizedMapName);
      final grenadesRef = docRef.collection('grenades');

      final querySnapshot = await grenadesRef.get();
      final grenadeCount = querySnapshot.docs.length;

      print('Найдено гранат: $grenadeCount');

      if (grenadeCount > 0) {
        _grenadeCountCache[normalizedMapName] = grenadeCount;
      }

      return grenadeCount;
    } catch (e) {
      print('Ошибка получения гранат для $mapName: $e');
      print(e.toString());
      return 0;
    }
  }

  // Метод для очистки кэша
  void clearCache() {
    print('Очистка кэша гранат');
    _grenadeCountCache.clear();
  }
}
