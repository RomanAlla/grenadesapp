class GameMap {
  final String name;
  final String image;
  bool isFavorite;

  GameMap({
    required this.name,
    required this.image,
    this.isFavorite = false,
  });
}
