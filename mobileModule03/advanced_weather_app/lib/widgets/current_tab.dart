// lib/widgets/current_tab.dart

import 'package:flutter/material.dart';

import '../controllers/weather_controller.dart';
import '../widgets/location_header.dart';
import '../theme/app_colors.dart';
import '../core/weather_icons.dart';
import '../core/weather_utils.dart';

class CurrentTab extends StatelessWidget {
  final WeatherController controller;

  const CurrentTab(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    final weather = controller.weather;

    if (controller.error != null) {
      return Center(
        child: Text(
          controller.error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (weather == null) {
      return const Center(
        child: Text(
          "No data",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    final icon = WeatherIcons.fromCode(weather.weatherCode);
    final description =
        WeatherUtils.codeToString(weather.weatherCode);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: IntrinsicHeight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🌍 Location (now bold + multi-line)
              LocationHeader(location: weather.locationName),

              const SizedBox(height: 30),

              // 🌡 Temperature
              Text(
                "${weather.temperature.toStringAsFixed(1)}°C",
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 12),

              // 🌤 Icon + description
              Column(
                children: [
                  Icon(
                    icon,
                    size: 48,
                    color: AppColors.accent,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 💨 wind
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.air,
                    color: Colors.lightBlueAccent,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${weather.windSpeed} km/h",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}