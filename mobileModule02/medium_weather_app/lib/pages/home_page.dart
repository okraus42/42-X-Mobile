// home_page.dart

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

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
  String _displayText = '';

  void _handleSearch(String value) {
    setState(() {
      _displayText = value;
    });
  }

  @override
  void initState() {
    super.initState();
    _handleLocation();
  }

  Future<void> _handleLocation() async {
    LocationPermission permission;

    // Check current permission
    permission = await Geolocator.checkPermission();

    // Request if denied
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // If still denied → handle gracefully
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _displayText = "Location permission denied";
      });
      return;
    }

    // If granted → get position
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _displayText =
            "Lat: ${position.latitude}, Lon: ${position.longitude}";
      });
    } catch (e) {
      setState(() {
        _displayText = "Error getting location";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: SearchBarWidget(
            controller: _controller,
            onSubmitted: _handleSearch,
            onLocationPressed: _handleLocation,
          ),
        ),
        body: TabBarView(
          children: [
            CurrentTab(location: _displayText),
            TodayTab(location: _displayText),
            WeeklyTab(location: _displayText),
          ],
        ),
        bottomNavigationBar: const BottomAppBar(
          child: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.access_time), text: 'Currently'),
              Tab(icon: Icon(Icons.today), text: 'Today'),
              Tab(icon: Icon(Icons.calendar_view_week), text: 'Weekly'),
            ],
          ),
        ),
      ),
    );
  }
}