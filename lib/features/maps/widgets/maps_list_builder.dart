import 'package:flutter/material.dart';
import '../models/game_map.dart';

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
  final List<GameMap> maps;
  const MapsListBuilder({super.key, required this.maps});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: maps.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            image: DecorationImage(
              image: AssetImage(maps[index].image),
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
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      maps[index].isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          maps[index].isFavorite ? Colors.orange : Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      maps[index].name,
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
                          onPressed: () {
                            // Навигация к деталям карты
                          },
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
                          child: const Row(
                            children: [
                              Icon(
                                Icons.flash_on,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 4),
                              Text(
                                '12 гранат',
                                style: TextStyle(
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
      },
    );
  }
}
