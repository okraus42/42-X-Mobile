// widgets/today_tab.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/weather.dart';
import '../widgets/location_header.dart';
import '../utils/weather_icons.dart';
import '../theme/app_colors.dart';

class TodayTab extends StatelessWidget {
  final WeatherData? weather;
  final String? error;

  const TodayTab({super.key, this.weather, this.error});

  int _guessCode(String description) {
    final d = description.toLowerCase();

    if (d.contains("clear")) return 0;
    if (d.contains("cloud")) return 1;
    if (d.contains("overcast")) return 3;
    if (d.contains("fog")) return 45;
    if (d.contains("drizzle")) return 51;
    if (d.contains("rain")) return 61;
    if (d.contains("snow")) return 71;
    if (d.contains("shower")) return 80;

    return -1;
  }

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
        child: Text(error!, style: const TextStyle(color: Colors.red)),
      );
    }

    if (weather == null) {
      return const Center(
        child: Text("No data", style: TextStyle(color: Colors.white)),
      );
    }

    final hourly = weather!.hourly;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          LocationHeader(location: weather!.locationName),

          const SizedBox(height: 12),

          // 🌫️ GLASS CHART
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      drawHorizontalLine: true,
                      horizontalInterval: 5,
                      verticalInterval: 3,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.white.withOpacity(0.08),
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Colors.white.withOpacity(0.05),
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              "${value.toInt()}°",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            );
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 3,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= hourly.length) {
                              return const SizedBox.shrink();
                            }
                            return Text(
                              hourly[i].time,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: AppColors.primary,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        spots: List.generate(hourly.length, (i) {
                          return FlSpot(
                            i.toDouble(),
                            hourly[i].temp,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 📜 HORIZONTAL HOURLY SCROLL
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourly.length,
              itemBuilder: (context, index) {
                final h = hourly[index];

                final icon = WeatherIcons.fromCode(
                  _guessCode(h.description),
                );

                return Container(
                  width: 85,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        h.time,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Icon(
                        icon,
                        color: AppColors.accent,
                        size: 22,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${h.temp.toStringAsFixed(0)}°",
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.air,
                            size: 14,
                            color: Colors.lightBlueAccent,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            "${h.wind.toStringAsFixed(0)}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}