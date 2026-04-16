// lib/core/weather_icons.dart

import 'package:flutter/material.dart';

class WeatherIcons {
  static IconData fromCode(int code) {
    switch (code) {
      case 0:
        return Icons.wb_sunny;

      case 1:
      case 2:
        return Icons.wb_cloudy;

      case 3:
        return Icons.cloud;

      case 45:
      case 48:
        return Icons.foggy;

      case 51:
      case 53:
      case 55:
        return Icons.grain;

      case 61:
      case 63:
      case 65:
        return Icons.umbrella;

      case 71:
      case 73:
      case 75:
        return Icons.ac_unit;

      case 80:
      case 81:
      case 82:
        return Icons.thunderstorm;

      default:
        return Icons.question_mark;
    }
  }
}