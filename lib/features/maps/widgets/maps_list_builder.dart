import 'package:flutter/material.dart';
import 'package:grenadesapp/features/maps/data/grenade_service.dart';
import '../models/game_map.dart';
import 'package:grenadesapp/features/video/data/repositories/video_repository.dart';
import 'package:grenadesapp/features/video/presentation/views/map_videos_page.dart';

List<GameMap> maps = [
  GameMap(
      name: 'Mirage',
      image: 'lib/assets/maps_images/de_mirage.png',
      isFavorite: false),
  GameMap(
      name: 'Dust 2',
      image: 'lib/assets/maps_images/de_dust2.png',
      isFavorite: false),
  GameMap(
      name: 'Inferno',
      image: 'lib/assets/maps_images/de_inferno.png',
      isFavorite: false),
  GameMap(
      name: 'Nuke',
      image: 'lib/assets/maps_images/de_nuke.png',
      isFavorite: false),
  GameMap(
      name: 'Anubis',
      image: 'lib/assets/maps_images/de_anubis.jpeg',
      isFavorite: false),
  GameMap(
      name: 'Ancient',
      image: 'lib/assets/maps_images/de_ancient.jpg',
      isFavorite: false),
  GameMap(
      name: 'Vertigo',
      image: 'lib/assets/maps_images/de_vertigo.jpg',
      isFavorite: false),
];

class MapsListBuilder extends StatelessWidget {
  final GrenadeService grenadeService;
  final List<GameMap> maps;
  final VideoRepository videoRepository;

  const MapsListBuilder({
    super.key,
    required this.grenadeService,
    required this.maps,
    required this.videoRepository,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: maps.length,
      itemBuilder: (context, index) {
        return FutureBuilder<int>(
          future: grenadeService
              .getGrenadeCountForMap(maps[index].name.toLowerCase()),
          builder: (context, snapshot) {
            // Показываем карточку даже если количество гранат загружается
            return MapCard(
              map: maps[index],
              grenadeCount: snapshot.data ?? 0,
              isLoading: snapshot.connectionState == ConnectionState.waiting,
              onError: snapshot.hasError,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MapVideosPage(
                      mapName: maps[index].name,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// Выносим карточку в отдельный виджет
class MapCard extends StatelessWidget {
  final GameMap map;
  final int grenadeCount;
  final bool isLoading;
  final bool onError;
  final VoidCallback onTap;

  const MapCard({
    super.key,
    required this.map,
    required this.grenadeCount,
    required this.isLoading,
    required this.onError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: AssetImage(map.image),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Align(alignment: Alignment.topRight),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  map.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Смотреть',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isLoading
                                ? Icons.hourglass_empty
                                : onError
                                    ? Icons.error_outline
                                    : Icons.flash_on,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isLoading
                                ? 'Загрузка...'
                                : onError
                                    ? 'Ошибка'
                                    : '$grenadeCount гранат',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
