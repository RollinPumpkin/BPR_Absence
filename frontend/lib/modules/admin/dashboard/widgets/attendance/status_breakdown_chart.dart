import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class StatusBreakdownChart extends StatelessWidget {
  final Map<String, int> statusData;
  final double size;

  const StatusBreakdownChart({
    super.key,
    required this.statusData,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final total = statusData.values.fold(0, (sum, value) => sum + value);
    
    if (total == 0) {
      return SizedBox(
        width: size,
        height: size,
        child: const Center(
          child: Text(
            'No Data',
            style: TextStyle(
              color: AppColors.neutral400,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    }

    final sections = _generatePieChartSections();
    
    return SizedBox(
      width: size,
      height: size,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 2,
          centerSpaceRadius: 25,
          startDegreeOffset: -90,
          pieTouchData: PieTouchData(
            enabled: true,
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              // Handle touch interactions if needed
            },
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _generatePieChartSections() {
    final total = statusData.values.fold(0, (sum, value) => sum + value);
    final sections = <PieChartSectionData>[];
    
    statusData.forEach((status, count) {
      if (count > 0) {
        final percentage = (count / total) * 100;
        sections.add(
          PieChartSectionData(
            color: _getStatusColor(status),
            value: count.toDouble(),
            title: count > 0 ? '${percentage.toStringAsFixed(0)}%' : '',
            radius: 35,
            titleStyle: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: count > 0 ? _buildBadge(status, count) : null,
            badgePositionPercentageOffset: 1.3,
          ),
        );
      }
    });
    
    return sections;
  }

  Widget _buildBadge(String status, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor(status),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Text(
        count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AppColors.primaryGreen;
      case 'late':
        return AppColors.primaryRed;
      case 'sick':
      case 'sick_leave':
        return AppColors.primaryYellow;
      case 'leave':
        return AppColors.primaryBlue;
      case 'absent':
        return AppColors.neutral400;
      default:
        return AppColors.neutral500;
    }
  }
}

class StatusLegend extends StatelessWidget {
  final Map<String, int> statusData;

  const StatusLegend({
    super.key,
    required this.statusData,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: statusData.entries.map((entry) {
        if (entry.value == 0) return const SizedBox.shrink();
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStatusColor(entry.key),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${_getStatusLabel(entry.key)}: ${entry.value}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral800,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Present';
      case 'late':
        return 'Late';
      case 'sick':
      case 'sick_leave':
        return 'Sick';
      case 'leave':
        return 'Leave';
      case 'absent':
        return 'Absent';
      default:
        return status.toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AppColors.primaryGreen;
      case 'late':
        return AppColors.primaryRed;
      case 'sick':
      case 'sick_leave':
        return AppColors.primaryYellow;
      case 'leave':
        return AppColors.primaryBlue;
      case 'absent':
        return AppColors.neutral400;
      default:
        return AppColors.neutral500;
    }
  }
}