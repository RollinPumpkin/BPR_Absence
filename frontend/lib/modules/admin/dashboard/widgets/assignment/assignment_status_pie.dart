import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class AssignmentStatusPie extends StatelessWidget {
  final int assigned;
  final int inProgress;
  final int done;
  final int overdue;
  final double sectionSpace;
  final double centerSpace;
  final double aspectRatio;

  const AssignmentStatusPie({
    super.key,
    this.assigned = 12,
    this.inProgress = 8,
    this.done = 20,
    this.overdue = 3,
    this.sectionSpace = 2,
    this.centerSpace = 36,
    this.aspectRatio = 1.9,
  });

  @override
  Widget build(BuildContext context) {
    final total = (assigned + inProgress + done + overdue).clamp(1, 9999);

    List<PieChartSectionData> sections(double radius) => [
          PieChartSectionData(
            color: AppColors.primaryYellow,
            value: assigned.toDouble(),
            title: '',
            radius: radius,
          ),
          PieChartSectionData(
            color: AppColors.primaryBlue,
            value: inProgress.toDouble(),
            title: '',
            radius: radius,
          ),
          PieChartSectionData(
            color: AppColors.primaryGreen,
            value: done.toDouble(),
            title: '',
            radius: radius,
          ),
          PieChartSectionData(
            color: AppColors.errorRed,
            value: overdue.toDouble(),
            title: '',
            radius: radius,
          ),
        ];

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: LayoutBuilder(
        builder: (context, c) {
          final r = (c.biggest.shortestSide / 2.8).clamp(26, 48).toDouble();
          return Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: sectionSpace,
                  centerSpaceRadius: centerSpace,
                  startDegreeOffset: -90,
                  sections: sections(r),
                ),
              ),
              // Label tengah
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: AppColors.neutral500,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$total',
                    style: const TextStyle(
                      color: AppColors.neutral800,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              // Legenda simple di bawah (opsional taruh di luar juga boleh)
              Positioned(
                bottom: 0,
                child: Row(
                  children: const [
                    _Legend(color: AppColors.primaryYellow, text: 'Assigned'),
                    SizedBox(width: 10),
                    _Legend(color: AppColors.primaryBlue, text: 'In Progress'),
                    SizedBox(width: 10),
                    _Legend(color: AppColors.primaryGreen, text: 'Done'),
                    SizedBox(width: 10),
                    _Legend(color: AppColors.errorRed, text: 'Overdue'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;
  const _Legend({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.neutral500,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
