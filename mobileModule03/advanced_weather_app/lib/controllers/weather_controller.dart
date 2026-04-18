// lib/controllers/weather_controller.dart

import 'package:flutter/material.dart';
import '../services/weather_service.dart';
import '../models/weather.dart';

enum WeatherErrorType {
  none,
  noInternet,
  timeout,
  locationDenied,
  locationDisabled,
  cityNotFound,
  apiError,
  unknown,
}

class WeatherController extends ChangeNotifier {
  WeatherData? weather;

  // structured error instead of raw string
  WeatherErrorType errorType = WeatherErrorType.none;

  bool isLoading = false;

  /*
    Convert error type into user-friendly message
    (UI layer only displays this)
  */
  String? get errorMessage {
    switch (errorType) {
      case WeatherErrorType.none:
        return null;
      case WeatherErrorType.noInternet:
        return "No internet connection";
      case WeatherErrorType.timeout:
        return "Request timed out. Try again";
      case WeatherErrorType.locationDenied:
        return "Location permission denied";
      case WeatherErrorType.locationDisabled:
        return "Location services are disabled";
      case WeatherErrorType.cityNotFound:
        return "City not found";
      case WeatherErrorType.apiError:
        return "Weather service unavailable";
      case WeatherErrorType.unknown:
        return "Something went wrong";
    }
  }

  Future<void> fetch(double lat, double lon, String name) async {
    isLoading = true;
    errorType = WeatherErrorType.none;
    notifyListeners();

    try {
      weather = await WeatherService.fetchWeather(
        lat: lat,
        lon: lon,
        locationName: name,
      );

      errorType = WeatherErrorType.none;
    } on WeatherException catch (e) {
      errorType = e.type;
      weather = null;
    } catch (e) {

      /*
        We now detect network errors explicitly from CityService / WeatherService
      */

      if (e.toString().contains("no_internet")) {
        errorType = WeatherErrorType.noInternet;
      } else if (e.toString().contains("timeout")) {
        errorType = WeatherErrorType.timeout;
      } else {
        errorType = WeatherErrorType.unknown;
      }

      weather = null;
    }

    isLoading = false;
    notifyListeners();
  }

  /*
    This method allows UI layer to explicitly set an error state.

    Why needed:
    - search bar detects invalid city before API call
    - we still want centralized error handling
    - keeps consistency with fetch() error system
  */
  void setError(WeatherErrorType type) {
    weather = null;
    errorType = type;

    notifyListeners();
  }
}