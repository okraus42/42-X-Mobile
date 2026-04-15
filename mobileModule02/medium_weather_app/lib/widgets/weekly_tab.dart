// weekly_tab.dart

import 'package:flutter/material.dart';

class WeeklyTab extends StatelessWidget {
  final String location;

  const WeeklyTab({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final days = [
      "Monday",
      "Tuesday",
      "Wednesday",
      "Thursday",
      "Friday",
      "Saturday",
      "Sunday",
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Text(
            "Weekly Forecast - ${location.isEmpty ? "No location selected" : location}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 20),

        for (final day in days)
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(day),
              subtitle: const Text("Weather: --"),
              trailing: const Text("--°C"),
            ),
          ),
      ],
    );
  }
}