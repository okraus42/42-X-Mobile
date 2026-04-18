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
  // Central weather state controller (ChangeNotifier based)
  final controller = WeatherController();

  // Text controller for search input field
  final textController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Load user location automatically on app start
    _loadLocation();
  }

  /*
    Fetches current GPS location and loads weather data

    Why this exists:
    - Provides immediate weather on app startup
    - Avoids requiring user input before showing data
  */
  Future<void> _loadLocation() async {
    try {
      final pos = await LocationService.getCurrentLocation();

      controller.fetch(
        pos.latitude,
        pos.longitude,
        "${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}",
      );
    } catch (_) {
      controller.errorType = WeatherErrorType.locationDenied;
      controller.weather = null;
      controller.notifyListeners();
    }
  }

  @override
  void dispose() {
    // Clean up controllers to prevent memory leaks
    textController.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      /*
        Rebuild UI whenever weather controller changes state

        This replaces setState for weather updates
      */
      animation: controller,
      builder: (context, _) {
        return DefaultTabController(
          length: 3,

          /*
            Scaffold is wrapped in GestureDetector to capture taps outside search UI

            Why this is necessary:
            - Search suggestions are overlay-like UI
            - They are not guaranteed to receive "outside tap" events
            - Wrapping full screen ensures consistent dismissal behavior
          */
          child: Scaffold(
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,

              /*
                Handles taps outside interactive elements

                Behavior:
                - Dismisses keyboard
                - Intended place for closing suggestions (if managed externally)
              */
              onTap: () {
                FocusScope.of(context).unfocus();
              },

              child: Stack(
                children: [
                  /*
                    Background image layer

                    Purpose:
                    - Provides visual weather context
                    - Always fills entire screen
                  */
                  Positioned.fill(
                    child: Image.asset(
                      'assets/storm.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),

                  /*
                    Dark overlay improves readability of UI elements
                    without changing background image
                  */
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.35),
                    ),
                  ),

                  /*
                    Main UI content layer
                    SafeArea prevents overlap with system UI
                  */
                  SafeArea(
                    child: Column(
                      children: [
                        /*
                          Search bar section

                          Responsibilities:
                          - City search input
                          - GPS button trigger
                          - City selection callback
                        */
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
                            
                            onSearchError: (type) {
                              switch (type) {
                                case SearchErrorType.cityNotFound:
                                  controller.setError(WeatherErrorType.cityNotFound);
                                  break;

                                case SearchErrorType.noInternet:
                                  controller.setError(WeatherErrorType.noInternet);
                                  break;

                                case SearchErrorType.unknown:
                                  controller.setError(WeatherErrorType.unknown);
                                  break;
                              }
                            },
                          ),
                        ),

                        /*
                          Tab content area

                          Uses TabBarView to switch between:
                          - Current weather
                          - Hourly forecast
                          - Weekly forecast
                        */
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

                  /*
                    Bottom TabBar navigation

                    Positioned manually to float above content
                    instead of using bottomNavigationBar
                  */
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Material(
                      color: Colors.transparent,
                      child: TabBar(
                        tabs: const [
                          Tab(icon: Icon(Icons.access_time), text: 'Currently'),
                          Tab(icon: Icon(Icons.today), text: 'Today'),
                          Tab(icon: Icon(Icons.calendar_view_week), text: 'Weekly'),
                        ],

                        labelColor: Colors.lightBlueAccent,
                        unselectedLabelColor: Colors.white70,
                        indicatorColor: Colors.lightBlueAccent,
                        indicatorWeight: 3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}