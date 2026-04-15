// current_tab.dart

import 'package:flutter/material.dart';

class CurrentTab extends StatelessWidget {
  final String location;

  const CurrentTab({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wb_sunny, size: 60),
          const SizedBox(height: 10),

          const Text(
            "Current Weather",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text(
            location.isEmpty ? "No location selected" : location,
            style: const TextStyle(fontSize: 18),
          ),

          const SizedBox(height: 20),

          // placeholder for future API data
          const Text(
            "Temperature: --°C",
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}