import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grenadesapp/core/constants/app_contants.dart';
import 'package:grenadesapp/features/video/presentation/providers/video_provider.dart';
import 'package:grenadesapp/features/video/presentation/widgets/video_list_widget.dart';
import 'package:grenadesapp/features/positions/presentation/views/positions_training_page.dart';

class MapVideosPage extends ConsumerStatefulWidget {
  final String mapName;

  const MapVideosPage({
    super.key,
    required this.mapName,
  });

  @override
  ConsumerState<MapVideosPage> createState() => _MapVideosPageState();
}

class _MapVideosPageState extends ConsumerState<MapVideosPage> {
  String searchQuery = '';
  String? selectedType;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(selectedMapProvider.notifier).state = widget.mapName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        title: Text(
          widget.mapName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.orange),
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz, color: Colors.orange),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PositionsTrainingPage(
                    mapName: widget.mapName,
                  ),
                ),
              );
            },
            tooltip: 'Тренировка позиций',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Поиск гранат...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTypeChip(null),
                      _buildTypeChip('smoke'),
                      _buildTypeChip('flash'),
                      _buildTypeChip('he'),
                      _buildTypeChip('molotov'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: VideoListWidget(
              mapName: widget.mapName,
              searchQuery: searchQuery,
              selectedType: selectedType,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String? type) {
    final isSelected = selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Text(
          type?.toUpperCase() ?? 'ВСЕ',
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.orange,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white.withOpacity(0.05),
        selectedColor: Colors.orange,
        checkmarkColor: Colors.white,
        onSelected: (selected) {
          setState(() {
            selectedType = selected ? type : null;
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
