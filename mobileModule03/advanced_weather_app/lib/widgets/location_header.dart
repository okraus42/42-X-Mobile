// lib/widgets/location_header.dart

import 'package:flutter/material.dart';

class LocationHeader extends StatelessWidget {
  final String location;

  const LocationHeader({
    super.key,
    required this.location,
  });

  @override
  Widget build(BuildContext context) {
    final parts = location.split(',');

    if (parts.length == 1) {
      return Text(
        parts.first.trim(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }

    return Column(
      children: [
        // 🟢 CITY (big + bold)
        Text(
          parts.first.trim(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 2),

        // 🟢 REGION + COUNTRY
        Text(
          parts.skip(1).join(', ').trim(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}