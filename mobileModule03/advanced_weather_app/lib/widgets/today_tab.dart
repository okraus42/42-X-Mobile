// lib/widgets/today_tab.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../controllers/weather_controller.dart';
import '../widgets/location_header.dart';
import '../core/weather_icons.dart';
import '../theme/app_colors.dart';

class TodayTab extends StatelessWidget {
  final WeatherController controller;

  const TodayTab(this.controller, {super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.error != null) {
      return Center(
        child: Text(controller.error!,
            style: const TextStyle(color: Colors.red)),
      );
    }

    final weather = controller.weather;

    if (weather == null) {
      return const Center(
        child: Text("No data", style: TextStyle(color: Colors.white)),
      );
    }

    final hourly = weather.hourly;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          LocationHeader(location: weather.locationName),

          const SizedBox(height: 12),

          // 📈 CHART
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(12),
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: LineChart(
                  LineChartData(
                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
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
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, _) {
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
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
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

          // 📜 HOURLY LIST
          SizedBox(
            height: 140,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: hourly.length,
              itemBuilder: (context, index) {
                final h = hourly[index];
                final icon = WeatherIcons.fromCode(h.code);

                return Container(
                  width: 85,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(16),
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
                      Icon(icon, color: AppColors.accent, size: 22),
                      const SizedBox(height: 8),
                      Text(
                        "${h.temp.toStringAsFixed(0)}°",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "${h.wind.toStringAsFixed(0)} km/h",
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white70,
                        ),
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