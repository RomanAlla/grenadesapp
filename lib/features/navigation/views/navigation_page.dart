import 'package:flutter/material.dart';
import 'package:grenadesapp/core/constants/app_contants.dart';
import 'package:grenadesapp/features/favorites/views/favorites_page.dart';
import 'package:grenadesapp/features/maps/views/maps_page.dart';

import 'package:grenadesapp/features/positions/presentation/views/select_map_page.dart';

import 'package:grenadesapp/features/video/domain/usecases/get_videos_use_case.dart';

class NavigationPage extends StatefulWidget {
  final GetVideosUseCase getVideosUseCase;
  const NavigationPage({super.key, required this.getVideosUseCase});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _selectedIndex = 0;

  List<Widget> get _pages {
    return [
      MapsPage(getVideosUseCase: widget.getVideosUseCase),
      const FavoritesPage(),
      const SelectMapPage()
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: SizedBox(
        height: 55,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF21222E),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0, Icons.map_outlined, Icons.map, 'Карты'),
              _buildNavItem(
                  1, Icons.favorite_outline, Icons.favorite, 'Избранное'),
              _buildNavItem(
                  2, Icons.location_on_outlined, Icons.location_on, 'Позиции'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.orange.withOpacity(0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected ? Colors.orange : Colors.white.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
