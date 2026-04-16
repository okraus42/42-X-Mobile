import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather.dart';

class WeatherService {
  static String _weatherCodeToString(int code) {
    switch (code) {
      case 0:
        return "Clear sky";
      case 1:
        return "Mainly clear";
      case 2:
        return "Partly cloudy";
      case 3:
        return "Overcast";
      case 45:
      case 48:
        return "Fog";
      case 51:
      case 53:
      case 55:
        return "Drizzle";
      case 61:
      case 63:
      case 65:
        return "Rain";
      case 71:
      case 73:
      case 75:
        return "Snow";
      case 80:
      case 81:
      case 82:
        return "Rain showers";
      default:
        return "Unknown";
    }
  }

  static Future<WeatherData> fetchWeather({
    required double lat,
    required double lon,
    required String locationName,
  }) async {
    final url = Uri.parse(
      "https://api.open-meteo.com/v1/forecast"
      "?latitude=$lat&longitude=$lon"
      "&current_weather=true"
      "&hourly=temperature_2m,weathercode,windspeed_10m"
      "&daily=temperature_2m_min,temperature_2m_max,weathercode"
      "&timezone=auto",
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception("API error");
    }

    final data = jsonDecode(response.body);

    final current = data['current_weather'];

    final hourlyTimes = List<String>.from(data['hourly']['time']);
    final hourlyTemps = List<double>.from(data['hourly']['temperature_2m']);
    final hourlyWinds = List<double>.from(data['hourly']['windspeed_10m']);
    final hourlyCodes = List<int>.from(data['hourly']['weathercode']);

    final dailyTimes = List<String>.from(data['daily']['time']);
    final dailyMin = List<double>.from(data['daily']['temperature_2m_min']);
    final dailyMax = List<double>.from(data['daily']['temperature_2m_max']);
    final dailyCodes = List<int>.from(data['daily']['weathercode']);

    return WeatherData(
      locationName: locationName,
      temperature: current['temperature'],
      windSpeed: current['windspeed'],
      description: _weatherCodeToString(current['weathercode']),

      hourly: List.generate(24, (i) {
        return HourlyWeather(
          time: hourlyTimes[i].substring(11, 16),
          temp: hourlyTemps[i],
          wind: hourlyWinds[i],
          description: _weatherCodeToString(hourlyCodes[i]),
        );
      }),

      daily: List.generate(dailyTimes.length, (i) {
        return DailyWeather(
          date: dailyTimes[i],
          minTemp: dailyMin[i],
          maxTemp: dailyMax[i],
          description: _weatherCodeToString(dailyCodes[i]),
        );
      }),
    );
  }
}