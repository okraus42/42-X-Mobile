// lib/services/weather_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather.dart';

class WeatherService {
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

    final response =
        await http.get(url).timeout(const Duration(seconds: 10));

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

    final hourlyCount = hourlyTemps.length.clamp(0, 24);

    return WeatherData(
      locationName: locationName,
      temperature: current['temperature'],
      windSpeed: current['windspeed'],
      weatherCode: current['weathercode'],

      hourly: List.generate(hourlyCount, (i) {
        return HourlyWeather(
          time: hourlyTimes[i].substring(11, 16),
          temp: hourlyTemps[i],
          wind: hourlyWinds[i],
          code: hourlyCodes[i],
        );
      }),

      daily: List.generate(dailyTimes.length, (i) {
        return DailyWeather(
          date: dailyTimes[i],
          minTemp: dailyMin[i],
          maxTemp: dailyMax[i],
          code: dailyCodes[i],
        );
      }),
    );
  }
}