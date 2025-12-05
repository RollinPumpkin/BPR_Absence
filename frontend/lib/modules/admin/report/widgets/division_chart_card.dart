import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/division_report.dart';

class DivisionChartCard extends StatelessWidget {
  final DivisionReport report;

  const DivisionChartCard({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE6E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: report.yInterval,
                      getTitlesWidget: (val, meta) => Text(
                        val.toInt().toString(),
                        style: const TextStyle(fontSize: 10, color: Color(0xFF8E96A4)),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (val, meta) {
                        final idx = val.toInt();
                        if (idx >= 0 && idx < report.labels.length) {
                          return Text(report.labels[idx],
                              style: const TextStyle(fontSize: 10, color: Color(0xFF8E96A4)));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (report.points.length - 1).toDouble(),
                minY: report.minY,
                maxY: report.maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (var i = 0; i < report.points.length; i++)
                        FlSpot(i.toDouble(), report.points[i]),
                    ],
                    isCurved: true,
                    barWidth: 3,
                    color: const Color(0xFF00B894), // hijau utama
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (p0, p1, p2, p3) => FlDotCirclePainter(
                        radius: 3,
                        color: const Color(0xFF00B894),
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x3300B894),
                          Color(0x1100B894),
                          Colors.transparent
                        ],
                      ),
                    ),
                  ),
                ],
                // highlight window opsional (contoh: area hijau tengah)
                betweenBarsData: const [],
                rangeAnnotations: RangeAnnotations(
                  verticalRangeAnnotations: [
                    if (report.highlightStart != null && report.highlightEnd != null)
                      VerticalRangeAnnotation(
                        x1: report.highlightStart!.toDouble(),
                        x2: report.highlightEnd!.toDouble(),
                        color: const Color(0x2200B894),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                report.divisionName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const Icon(Icons.more_horiz, color: Color(0xFF8E96A4)),
          ],
        ),
        if (report.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            report.subtitle!,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8E96A4),
            ),
          ),
        ],
      ],
    );
  }
}
