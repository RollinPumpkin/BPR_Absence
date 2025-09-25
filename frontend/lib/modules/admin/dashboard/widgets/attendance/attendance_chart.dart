import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class AttendanceChart extends StatelessWidget {
  final List<int> data;
  final List<String> labels;
  final double barWidth;
  final double aspectRatio;

  const AttendanceChart({
    super.key,
    this.data = const [8, 10, 6, 12, 9, 7, 4],
    this.labels = const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'],
    this.barWidth = 18,
    this.aspectRatio = 1.8,
  }) : assert(data.length == labels.length, 'data & labels harus sama panjang');

  @override
  Widget build(BuildContext context) {
    final int maxVal = data.isEmpty ? 0 : data.reduce((a, b) => a > b ? a : b);
    final double maxY = (maxVal <= 5)
        ? 6
        : (maxVal <= 10)
            ? 12
            : (maxVal <= 15)
                ? 16
                : (maxVal + 4).toDouble();

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              getTooltipItem: (group, i, rod, _) => BarTooltipItem(
                '${labels[i]}: ${rod.toY.toInt()}',
                const TextStyle(
                  color: AppColors.pureWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
              fitInsideHorizontally: true,
              fitInsideVertically: true,
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: 2,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.neutral100,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: AppColors.neutral100, width: 1),
              bottom: BorderSide(color: AppColors.neutral100, width: 1),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.neutral500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                reservedSize: 30,
                showTitles: true,
                interval: 2,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.neutral400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].toDouble(),
                  width: barWidth,
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.accentBlue, AppColors.primaryBlue],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
