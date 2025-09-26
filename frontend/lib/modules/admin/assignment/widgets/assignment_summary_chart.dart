// lib/modules/admin/assignment/widgets/assignment_summary_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class AssignmentSummaryChart extends StatelessWidget {
  final String period; // "Daily" | "Weekly" | "Monthly"
  final double aspectRatio;
  const AssignmentSummaryChart({
    super.key,
    required this.period,
    this.aspectRatio = 1.9,
  });

  @override
  Widget build(BuildContext context) {
    final dataset = _dataFor(period);
    final labels = dataset.labels;
    final series = dataset.series; 

    final maxVal = [
      ...series.values.expand((e) => e),
    ].fold<int>(0, (m, v) => v > m ? v : m);
    final maxY = (maxVal <= 5)
        ? 6.0
        : (maxVal <= 10)
            ? 12.0
            : (maxVal <= 15)
                ? 16.0
                : (maxVal + 4).toDouble();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.dividerGray),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title + legend
          Row(
            children: [
              const Text(
                'Assignment Overview',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.neutral800,
                ),
              ),
              const Spacer(),
              _Legend(color: AppColors.accentBlue, label: 'Assigned'),
              const SizedBox(width: 10),
              _Legend(color: AppColors.primaryYellow, label: 'In Progress'),
              const SizedBox(width: 10),
              _Legend(color: AppColors.primaryGreen, label: 'Done'),
            ],
          ),
          const SizedBox(height: 8),

          AspectRatio(
            aspectRatio: aspectRatio,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: 2,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.dividerGray,
                    strokeWidth: 1,
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
                        if (i < 0 || i >= labels.length) return const SizedBox();
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
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(color: AppColors.dividerGray, width: 1),
                    bottom: BorderSide(color: AppColors.dividerGray, width: 1),
                  ),
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((t) {
                        return LineTooltipItem(
                          '${labels[t.x.toInt()]}: ${t.y.toInt()}',
                          const TextStyle(
                            color: AppColors.pureWhite,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  _seriesLine(series['Assigned']!, AppColors.accentBlue),
                  _seriesLine(series['In Progress']!, AppColors.primaryYellow),
                  _seriesLine(series['Done']!, AppColors.primaryGreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _seriesLine(List<int> points, Color color) {
    return LineChartBarData(
      isCurved: true,
      barWidth: 3,
      color: color,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(show: true, color: color.withOpacity(.12)),
      spots: List.generate(points.length, (i) => FlSpot(i.toDouble(), points[i].toDouble())),
    );
  }

  _Dataset _dataFor(String p) {
    switch (p) {
      case 'Weekly':
        return _Dataset(
          labels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          series: {
            'Assigned': const [3, 5, 4, 6, 7, 3, 2],
            'In Progress': const [2, 2, 3, 3, 2, 1, 1],
            'Done': const [1, 2, 2, 4, 3, 2, 1],
          },
        );
      case 'Monthly':
        return _Dataset(
          labels: const ['W1', 'W2', 'W3', 'W4'],
          series: {
            'Assigned': const [10, 8, 12, 9],
            'In Progress': const [5, 6, 4, 5],
            'Done': const [6, 7, 9, 10],
          },
        );
      case 'Daily':
      default:
        return _Dataset(
          labels: const ['09', '10', '11', '12', '13', '14', '15'],
          series: {
            'Assigned': const [2, 3, 4, 2, 3, 5, 2],
            'In Progress': const [1, 1, 2, 2, 1, 1, 1],
            'Done': const [0, 1, 1, 2, 2, 3, 1],
          },
        );
    }
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.neutral800,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Dataset {
  final List<String> labels;
  final Map<String, List<int>> series;
  _Dataset({required this.labels, required this.series});
}
