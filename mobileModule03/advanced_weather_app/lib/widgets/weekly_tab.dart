// widgets/weekly_tab.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/weather.dart';
import '../widgets/location_header.dart';
import '../utils/weather_icons.dart';
import '../theme/app_colors.dart';

class WeeklyTab extends StatelessWidget {
  final WeatherData? weather;
  final String? error;

  const WeeklyTab({super.key, this.weather, this.error});

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

  String _weekday(String isoDate) {
    final date = DateTime.parse(isoDate);
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[date.weekday - 1];
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

    final daily = weather!.daily;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          LocationHeader(location: weather!.locationName),

          const SizedBox(height: 12),

          // 📊 GLASS CHART
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
                height: 240,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: true,
                      horizontalInterval: 5,
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

                      rightTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) {
                            final i = value.toInt();
                            if (i < 0 || i >= daily.length) {
                              return const SizedBox.shrink();
                            }

                            return Text(
                              _weekday(daily[i].date),
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
                      // 🔵 MIN TEMP (straight line + points)
                      LineChartBarData(
                        isCurved: false,
                        color: Colors.blueAccent,
                        barWidth: 2,
                        dotData: FlDotData(
                          show: true,
                        ),
                        spots: List.generate(daily.length, (i) {
                          return FlSpot(
                            i.toDouble(),
                            daily[i].minTemp,
                          );
                        }),
                      ),

                      // 🔴 MAX TEMP (straight line + points)
                      LineChartBarData(
                        isCurved: false,
                        color: Colors.redAccent,
                        barWidth: 2,
                        dotData: FlDotData(
                          show: true,
                        ),
                        spots: List.generate(daily.length, (i) {
                          return FlSpot(
                            i.toDouble(),
                            daily[i].maxTemp,
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

          // 📜 HORIZONTAL SCROLLABLE DAYS LIST
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: daily.length,
              itemBuilder: (context, index) {
                final d = daily[index];

                final icon = WeatherIcons.fromCode(
                  _guessCode(d.description),
                );

                return Container(
                  width: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _weekday(d.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Icon(
                        icon,
                        color: AppColors.accent,
                        size: 20,
                      ),

                      const SizedBox(height: 6),

                      Text(
                        "${d.minTemp.toStringAsFixed(0)}° / ${d.maxTemp.toStringAsFixed(0)}°",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
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