class PositionModel {
  final String id;
  final String mapName;
  final String correctName;
  final String imageUrl;
  final List<String> options;

  PositionModel({
    required this.id,
    required this.mapName,
    required this.correctName,
    required this.imageUrl,
    required this.options,
  });

  factory PositionModel.fromJson(Map<String, dynamic> json) {
    return PositionModel(
      id: json['id'] ?? '',
      mapName: json['mapName'] ?? '',
      correctName: json['correctName'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      options: List<String>.from(json['options'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mapName': mapName,
      'correctName': correctName,
      'imageUrl': imageUrl,
      'options': options,
    };
  }
}
