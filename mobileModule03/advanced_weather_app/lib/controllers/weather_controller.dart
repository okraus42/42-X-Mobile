// lib/controllers/weather_controller.dart

import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather.dart';

class WeatherController extends ChangeNotifier {
  WeatherData? weather;
  String? error;
  bool isLoading = false;

  Future<void> fetch(double lat, double lon, String name) async {
    isLoading = true;
    notifyListeners();

    try {
      weather = await WeatherService.fetchWeather(
        lat: lat,
        lon: lon,
        locationName: name,
      );
      error = null;
    } catch (_) {
      error = "Connection issue or invalid city";
      weather = null;
    }

    isLoading = false;
    notifyListeners();
  }
}