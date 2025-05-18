import 'package:cloud_firestore/cloud_firestore.dart';

class GrenadeService {
  final FirebaseFirestore firestore;

  final Map<String, int> _grenadeCountCache = {};

  GrenadeService({required this.firestore});

  Future<int> getGrenadeCountForMap(String mapName) async {
    try {
      final normalizedMapName = mapName.toLowerCase().trim();

      if (_grenadeCountCache.containsKey(normalizedMapName)) {
        return _grenadeCountCache[normalizedMapName]!;
      }

      final docRef = firestore.collection('maps').doc(normalizedMapName);
      final grenadesRef = docRef.collection('grenades');

      final querySnapshot = await grenadesRef.get();
      final grenadeCount = querySnapshot.docs.length;

      if (grenadeCount > 0) {
        _grenadeCountCache[normalizedMapName] = grenadeCount;
      }

      return grenadeCount;
    } catch (e) {
      return 0;
    }
  }

  void clearCache() {
    _grenadeCountCache.clear();
  }
}
