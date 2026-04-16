// widgets/location_header.dart

import 'package:flutter/material.dart';

class LocationHeader extends StatelessWidget {
  final String location;

  const LocationHeader({
    super.key,
    required this.location,
  });

  bool _isGps(String text) {
    return RegExp(r'^\d+\.\d+,\s*\d+\.\d+$').hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final isGps = _isGps(location);

    if (isGps) {
      return Text(
        location,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14),
      );
    }

    final parts = location.split(',');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: parts.map((p) {
        return Text(
          p.trim(),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        );
      }).toList(),
    );
  }
}