// lib/models/weather.dart

class WeatherData {
  final String locationName;
  final double temperature;
  final double windSpeed;
  final int weatherCode;

  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  WeatherData({
    required this.locationName,
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.hourly,
    required this.daily,
  });
}

class HourlyWeather {
  final String time;
  final double temp;
  final double wind;
  final int code;

  HourlyWeather({
    required this.time,
    required this.temp,
    required this.wind,
    required this.code,
  });
}

class DailyWeather {
  final String date;
  final double minTemp;
  final double maxTemp;
  final int code;

  DailyWeather({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.code,
  });
}