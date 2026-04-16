// lib/pages/home_page.dart

import 'package:flutter/material.dart';

import '../core/location_service.dart';
import '../controllers/weather_controller.dart';

import '../widgets/search_bar.dart';
import '../widgets/current_tab.dart';
import '../widgets/today_tab.dart';
import '../widgets/weekly_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final controller = WeatherController();
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    try {
      final pos = await LocationService.getCurrentLocation();

      controller.fetch(
        pos.latitude,
        pos.longitude,
        "${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}",
      );
    } catch (e) {
      controller.error = e.toString();
      controller.notifyListeners();
    }
  }

  @override
  void dispose() {
    textController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return DefaultTabController(
          length: 3,
          child: Scaffold(
            body: Stack(
              children: [
                // 🌩️ Background
                Positioned.fill(
                  child: Image.asset(
                    'assets/storm.jpg',
                    fit: BoxFit.cover,
                  ),
                ),

                // 🌑 Overlay
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.35),
                  ),
                ),

                // 📱 Main content
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: SearchBarWidget(
                          controller: textController,
                          onCitySelected: (city) {
                            controller.fetch(
                              city.latitude,
                              city.longitude,
                              "${city.name}, ${city.region}, ${city.country}",
                            );
                          },
                          onLocationPressed: _loadLocation,
                        ),
                      ),

                      Expanded(
                        child: TabBarView(
                          children: [
                            CurrentTab(controller),
                            TodayTab(controller),
                            WeeklyTab(controller),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ FIXED TAB BAR (INSIDE BUILD, NOT CONST)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: TabBar(
                      indicatorColor: Colors.lightBlueAccent,
                      indicatorWeight: 3,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.wb_sunny),
                          text: "Currently",
                        ),
                        Tab(
                          icon: Icon(Icons.today),
                          text: "Today",
                        ),
                        Tab(
                          icon: Icon(Icons.calendar_view_week),
                          text: "Weekly",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}