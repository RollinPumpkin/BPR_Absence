import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'attendance_detail_sheet.dart';
import 'status_breakdown_chart.dart';

class AttendanceCard extends StatelessWidget {
  final String title;
  final Widget chart;
  final int? present;
  final int? absent;
  final int? lateCount;
  final Map<String, int>? statusBreakdown;
  final double chartHeight;
  final bool showStatusBreakdown;

  const AttendanceCard({
    super.key,
    required this.title,
    required this.chart,
    this.present,
    this.absent,
    this.lateCount,
    this.statusBreakdown,
    this.chartHeight = 180,
    this.showStatusBreakdown = false,
  });

  void _openDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.pureWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AttendanceDetailSheet(
        title: title,
        chart: chart,
        present: present,
        absent: absent,
        lateCount: lateCount,
        statusBreakdown: statusBreakdown,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.pureWhite,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetail(context),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.pureWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadowColor,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.neutral800,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _openDetail(context),
                    child: const Text(
                      "View",
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.primaryRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (showStatusBreakdown && statusBreakdown != null) ...[
                // Status breakdown section
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(height: chartHeight, child: chart),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          StatusBreakdownChart(
                            statusData: statusBreakdown!,
                            size: 100,
                          ),
                          const SizedBox(height: 12),
                          StatusLegend(statusData: statusBreakdown!),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Traditional chart only
                SizedBox(height: chartHeight, child: chart),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
