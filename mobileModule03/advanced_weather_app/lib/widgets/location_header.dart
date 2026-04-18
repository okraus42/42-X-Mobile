// lib/widgets/location_header.dart

import 'package:flutter/material.dart';

class LocationHeader extends StatelessWidget {
  final String location;

  const LocationHeader({
    super.key,
    required this.location,
  });

  bool _isGps(String text) {
    return RegExp(r'^-?\d+\.\d+,\s*-?\d+\.\d+$').hasMatch(text);
  }

  String _formatCoords(String text) {
    final parts = text.split(',');

    final lat = double.parse(parts[0]);
    final lon = double.parse(parts[1]);

    final latDir = lat >= 0 ? 'N' : 'S';
    final lonDir = lon >= 0 ? 'E' : 'W';

    return "${lat.abs().toStringAsFixed(4)}$latDir "
        "${lon.abs().toStringAsFixed(4)}$lonDir";
  }

  @override
  Widget build(BuildContext context) {
    // 📍 GPS case
    if (_isGps(location)) {
      return Column(
        children: [
          const Text(
            "My location",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatCoords(location),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      );
    }

    // 🌍 City case
    final parts = location.split(',');

    if (parts.length == 1) {
      return Text(
        parts.first.trim(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }

    return Column(
      children: [
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