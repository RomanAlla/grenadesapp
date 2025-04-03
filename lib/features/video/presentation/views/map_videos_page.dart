import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grenadesapp/core/constants/app_contants.dart';
import 'package:grenadesapp/features/video/presentation/providers/video_provider.dart';
import 'package:grenadesapp/features/video/presentation/widgets/video_list_widget.dart';

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
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.mapName,
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Поиск...',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon:
                          const Icon(Icons.search, color: Colors.orange),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildTypeButton('Все', null),
                        _buildTypeButton('Smoke', 'smoke'),
                        _buildTypeButton('Flash', 'flash'),
                        _buildTypeButton('Molotov', 'molotov'),
                        _buildTypeButton('HE', 'he'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: VideoListWidget(
                searchQuery: searchQuery,
                selectedType: selectedType,
                mapName: widget.mapName,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, String? type) {
    final isSelected = selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            selectedType = isSelected ? null : type;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.orange : Colors.orange.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
