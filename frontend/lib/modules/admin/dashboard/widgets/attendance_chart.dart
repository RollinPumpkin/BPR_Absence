import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class AttendanceChart extends StatelessWidget {
  const AttendanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 15, // batas maksimal nilai Y
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text("Hadir",
                        style: TextStyle(fontSize: 10));
                  case 1:
                    return const Text("Izin",
                        style: TextStyle(fontSize: 10));
                  case 2:
                    return const Text("Sakit",
                        style: TextStyle(fontSize: 10));
                  default:
                    return const Text("");
                }
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(
              toY: 7,
              color: AppColors.primaryGreen,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(
              toY: 12,
              color: Colors.grey,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ]),
          BarChartGroupData(x: 2, barRods: [
            BarChartRodData(
              toY: 4,
              color: AppColors.primaryYellow,
              width: 20,
              borderRadius: BorderRadius.circular(4),
            ),
          ]),
        ],
      ),
    );
  }
}
