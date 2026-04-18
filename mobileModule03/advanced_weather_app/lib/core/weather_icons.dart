// lib/core/weather_icons.dart

import 'package:flutter/material.dart';

class WeatherIcons {
  static IconData fromCode(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny;

      case 1:
        return Icons.wb_cloudy_outlined;

      case 2:
      case 3:
        return Icons.wb_cloudy;

      case 45:
      case 48:
        return Icons.foggy;

      case 51:
      case 53:
      case 55:
        return Icons.water_drop_outlined;

      case 56:
      case 57:
        return Icons.ac_unit; // freezing drizzle ❄️💧

      case 61:
      case 63:
      case 65:
        return Icons.water_drop_outlined;

      case 66:
      case 67:
        return Icons.ac_unit; // freezing rain

      case 71:
      case 73:
      case 75:
        return Icons.ac_unit;

      case 77:
        return Icons.grain; // snow grains

      case 80:
      case 81:
      case 82:
        return Icons.water_drop;

      case 85:
      case 86:
        return Icons.ac_unit; // snow showers

      case 95:
        return Icons.thunderstorm_outlined; // thunderstorm

      case 96:
      case 99:
        return Icons.thunderstorm_outlined; // hail storms (better alternative icon)

      default:
        return Icons.help_outline;
    }
  }
}