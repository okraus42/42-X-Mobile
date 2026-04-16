class WeatherData {
  final String locationName;

  final double temperature;
  final double windSpeed;
  final String description;

  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  WeatherData({
    required this.locationName,
    required this.temperature,
    required this.windSpeed,
    required this.description,
    required this.hourly,
    required this.daily,
  });
}

class HourlyWeather {
  final String time;
  final double temp;
  final double wind;
  final String description;

  HourlyWeather({
    required this.time,
    required this.temp,
    required this.wind,
    required this.description,
  });
}

class DailyWeather {
  final String date;
  final double minTemp;
  final double maxTemp;
  final String description;

  DailyWeather({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.description,
  });
}