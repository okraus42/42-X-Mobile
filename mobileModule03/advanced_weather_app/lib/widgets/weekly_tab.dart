// lib/widgets/weekly_tab.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../controllers/weather_controller.dart';
import '../widgets/location_header.dart';
import '../core/weather_icons.dart';
import '../theme/app_colors.dart';

class WeeklyTab extends StatelessWidget {
  final WeatherController controller;

  const WeeklyTab(this.controller, {super.key});

  String _weekday(String isoDate) {
    final date = DateTime.parse(isoDate);
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return days[date.weekday - 1];
  }

  /*
    Same Y-axis logic as today chart

    Ensures consistent scaling between charts
  */
  List<double> _calculateYAxis(List<double> values) {
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);

    final minRounded = (min / 5).floor() * 5;
    final maxRounded = (max / 5).ceil() * 5 + 5;

    return [minRounded.toDouble(), maxRounded.toDouble()];
  }

  @override
  Widget build(BuildContext context) {
    if (controller.errorMessage != null) {
      return Center(
        child: Text(
          controller.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final weather = controller.weather;

    if (weather == null) {
      return const Center(
        child: Text("No data", style: TextStyle(color: Colors.white)),
      );
    }

    final daily = weather.daily;

    final temps = [
      ...daily.map((e) => e.minTemp),
      ...daily.map((e) => e.maxTemp),
    ];

    final yBounds = _calculateYAxis(temps);

    final minY = yBounds[0];
    final maxY = yBounds[1];

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          LocationHeader(location: weather.locationName),

          const SizedBox(height: 12),

          /*
            WEEKLY TEMPERATURE CHART
            - min + max lines
            - consistent 5°C axis scaling
          */
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(12),
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: LineChart(
                  LineChartData(
                    minY: minY,
                    maxY: maxY,

                    borderData: FlBorderData(show: false),
                    gridData: FlGridData(show: true),

                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, _) {
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

                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 5,
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
                        color: Colors.blueAccent,
                        spots: List.generate(daily.length, (i) {
                          return FlSpot(i.toDouble(), daily[i].minTemp);
                        }),
                      ),
                      LineChartBarData(
                        color: Colors.redAccent,
                        spots: List.generate(daily.length, (i) {
                          return FlSpot(i.toDouble(), daily[i].maxTemp);
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /*
            DAILY SUMMARY CARDS
          */
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: daily.length,
              itemBuilder: (context, index) {
                final d = daily[index];
                final icon = WeatherIcons.fromCode(d.code);

                return Container(
                  width: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_weekday(d.date),
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 6),
                      Icon(icon, color: AppColors.accent, size: 20),
                      const SizedBox(height: 6),
                      Text(
                        "${d.minTemp.toStringAsFixed(0)}° / ${d.maxTemp.toStringAsFixed(0)}°",
                        style: const TextStyle(
                          fontSize: 11,
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