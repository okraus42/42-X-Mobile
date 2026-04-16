import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../widgets/location_header.dart';
import '../theme/app_colors.dart';
import '../utils/weather_icons.dart';

class CurrentTab extends StatelessWidget {
  final WeatherData? weather;
  final String? error;

  const CurrentTab({super.key, this.weather, this.error});

  int _guessCode(String description) {
    final d = description.toLowerCase();

    if (d.contains("clear")) return 0;
    if (d.contains("cloud")) return 1;
    if (d.contains("overcast")) return 3;
    if (d.contains("fog")) return 45;
    if (d.contains("drizzle")) return 51;
    if (d.contains("rain")) return 61;
    if (d.contains("snow")) return 71;
    if (d.contains("shower")) return 80;

    return -1;
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (weather == null) {
      return const Center(
        child: Text("No data", style: TextStyle(color: Colors.white)),
      );
    }

    final code = _guessCode(weather!.description);
    final icon = WeatherIcons.fromCode(code);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LocationHeader(location: weather!.locationName),

          const SizedBox(height: 20),

          Text(
            "${weather!.temperature.toStringAsFixed(1)}°C",
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: 10),

          Column(
            children: [
              Icon(
                icon,
                size: 38,
                color: AppColors.accent,
              ),
              const SizedBox(height: 6),
              Text(
                weather!.description,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.air,
                color: Colors.lightBlueAccent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                "${weather!.windSpeed} km/h",
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}