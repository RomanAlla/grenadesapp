import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grenadesapp/core/constants/app_contants.dart';
import 'package:grenadesapp/features/maps/models/game_map.dart';
import 'package:grenadesapp/features/maps/widgets/maps_list_builder.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  bool isSearchVisible = false;
  TextEditingController searchController = TextEditingController();
  List<GameMap> filteredMaps = [];

  @override
  void initState() {
    super.initState();
    filteredMaps = maps;
  }

  void _filterMaps(String query) {
    setState(() {
      filteredMaps = maps
          .where((map) => map.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (isSearchVisible) const SizedBox(height: 110),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.rocket_launch,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'CS2',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          isSearchVisible = true;
                                        });
                                      },
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: const Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () async {
                                        final result = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            backgroundColor:
                                                const Color(0xFF21222E),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            title: const Text(
                                              'Выйти',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            content: const Text(
                                              'Вы уверены, что хотите выйти?',
                                              style: TextStyle(
                                                  color: Colors.white70),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, false),
                                                child: const Text(
                                                  'Отмена',
                                                  style: TextStyle(
                                                      color: Colors.white70),
                                                ),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, true),
                                                child: const Text(
                                                  'Выйти',
                                                  style: TextStyle(
                                                      color: Colors.orange),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (result == true) {
                                          try {
                                            await FirebaseAuth.instance
                                                .signOut();

                                           
                                            await FirebaseAuth.instance
                                                .authStateChanges()
                                                .first;

                                           
                                            if (context.mounted) {
                                              Navigator.pushReplacementNamed(
                                                  context, '/');
                                            }
                                          } catch (e) {
                                            print('Ошибка при выходе: $e');
                                          }
                                        }
                                      },
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: const Icon(
                                          Icons.logout_rounded,
                                          color: Colors.orange,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            if (!isSearchVisible) ...[
                              const SizedBox(height: 24),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Найденные\nГранаты',
                                    style: TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      height: 1.2,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Рекомендуемые карты',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward,
                                        color: Colors.orange,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        child: MapsListBuilder(maps: filteredMaps),
                      ),
                    ],
                  ),
                ),
              ],
            ),
       
            if (isSearchVisible)
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(25),
                      bottomRight: Radius.circular(25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          cursorColor: Colors.orange,
                          onChanged: _filterMaps,
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Поиск карт...',
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isSearchVisible = false;
                            searchController.clear();
                            _filterMaps('');
                          });
                        },
                        child: Container(
                          width: 48,
                          height: 48,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
