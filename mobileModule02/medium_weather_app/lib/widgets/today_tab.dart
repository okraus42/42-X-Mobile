// today_tab.dart

import 'package:flutter/material.dart';

class TodayTab extends StatelessWidget {
  final String location;

  const TodayTab({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: Text(
            "Today - ${location.isEmpty ? "No location selected" : location}",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),

        const SizedBox(height: 20),

        // placeholder hourly forecast
        for (int i = 0; i < 6; i++)
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time),
              title: Text("${8 + i * 2}:00"),
              subtitle: const Text("Weather: --"),
              trailing: const Text("--°C"),
            ),
          ),
      ],
    );
  }
}