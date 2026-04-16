// pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/city.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

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
  final TextEditingController _controller = TextEditingController();

  WeatherData? _weather;
  String? _error;

  @override
  void initState() {
    super.initState();
    _handleLocation();
  }

  Future<void> _fetchWeather(double lat, double lon, String name) async {
    try {
      final weather = await WeatherService.fetchWeather(
        lat: lat,
        lon: lon,
        locationName: name,
      );

      setState(() {
        _weather = weather;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = "Connection issue or invalid city";
        _weather = null;
      });
    }
  }

  void _handleCitySelected(City city) {
    _fetchWeather(
      city.latitude,
      city.longitude,
      "${city.name}, ${city.region}, ${city.country}",
    );
  }

  void _handleSearch(String value) {
    setState(() {
      _error = "Invalid city name";
      _weather = null;
    });
  }

  Future<void> _handleLocation() async {
    setState(() {
      _error = null;
    });

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _error =
            "Geolocation is not available, please enable it in your App settings";
        _weather = null;
      });
      return;
    }

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      setState(() {
        _error = "Location services are disabled. Please enable GPS.";
        _weather = null;
      });
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _fetchWeather(
        position.latitude,
        position.longitude,
        "${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}",
      );
    } catch (e) {
      setState(() {
        _error = "Unable to get GPS location. Try again.";
        _weather = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        resizeToAvoidBottomInset: true,

        // 🌩️ BACKGROUND LAYER (GLOBAL FIXED IMAGE)
        body: Stack(
          children: [
            // BACKGROUND IMAGE (always behind everything)
            Positioned.fill(
              child: Image.asset(
                'assets/storm.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // DARK OVERLAY (improves readability)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
              ),
            ),

            // MAIN CONTENT
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: SearchBarWidget(
                      controller: _controller,
                      onSubmitted: _handleSearch,
                      onCitySelected: _handleCitySelected,
                      onLocationPressed: _handleLocation,
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      physics: const ClampingScrollPhysics(),
                      children: [
                        CurrentTab(weather: _weather, error: _error),
                        TodayTab(weather: _weather, error: _error),
                        WeeklyTab(weather: _weather, error: _error),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // TAB BAR MUST ALSO FLOAT ABOVE BACKGROUND
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Material(
                color: Colors.transparent,
                child: TabBar(
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: "Currently"),
                    Tab(text: "Today"),
                    Tab(text: "Weekly"),
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