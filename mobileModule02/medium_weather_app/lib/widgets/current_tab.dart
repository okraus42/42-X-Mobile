import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../widgets/location_header.dart';

class CurrentTab extends StatelessWidget {
  final WeatherData? weather;
  final String? error;

  const CurrentTab({super.key, this.weather, this.error});

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (weather == null) {
      return const Center(child: Text("No data"));
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LocationHeader(location: weather!.locationName),

          const SizedBox(height: 20),

          Text("${weather!.temperature}°C",
              style: const TextStyle(fontSize: 32)),

          Text(weather!.description),
          Text("${weather!.windSpeed} km/h"),
        ],
      ),
    );
  }
}