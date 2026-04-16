import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../widgets/location_header.dart';

class WeeklyTab extends StatelessWidget {
  final WeatherData? weather;
  final String? error;

  const WeeklyTab({super.key, this.weather, this.error});

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

    return Column(
      children: [
        const SizedBox(height: 10),

        LocationHeader(location: weather!.locationName),

        const SizedBox(height: 10),

        Expanded(
          child: ListView(
            children: weather!.daily.map((d) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    "${d.date}    ${d.minTemp}°C    ${d.maxTemp}°C    ${d.description}",
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}