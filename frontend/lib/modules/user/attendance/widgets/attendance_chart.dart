import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class AttendanceChart extends StatelessWidget {
  const AttendanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Attendance Report',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black87,
                ),
              ),
              Icon(
                Icons.more_horiz,
                color: Colors.grey.shade400,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          /// Legend
          _buildLegend(),
          
          const SizedBox(height: 16),
          
          /// Chart Area
          Container(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: MultiLineAttendanceChartPainter(),
            ),
          ),
          
          const SizedBox(height: 10),
          
          /// X-axis labels (Days)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildDayLabel('Mon'),
              _buildDayLabel('Tue'),
              _buildDayLabel('Wed'),
              _buildDayLabel('Thu'),
              _buildDayLabel('Fri'),
              _buildDayLabel('Sat'),
              _buildDayLabel('Sun'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Present', AppColors.primaryGreen),
        _buildLegendItem('Late', AppColors.vibrantOrange),
        _buildLegendItem('Absent', AppColors.errorRed),
        _buildLegendItem('Leave', AppColors.primaryBlue),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDayLabel(String day) {
    return Text(
      day,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade500,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class MultiLineAttendanceChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define colors for each attendance type
    final presentColor = AppColors.primaryGreen;
    final lateColor = AppColors.vibrantOrange;
    final absentColor = AppColors.errorRed;
    final leaveColor = AppColors.primaryBlue;

    // Sample data for 7 days (Monday to Sunday)
    // Values represent count of people in each category per day
    final presentData = [25.0, 28.0, 26.0, 29.0, 27.0, 15.0, 8.0]; // Higher on weekdays
    final lateData = [3.0, 2.0, 4.0, 1.0, 3.0, 1.0, 0.0]; // Occasional lateness
    final absentData = [2.0, 0.0, 1.0, 0.0, 0.0, 2.0, 1.0]; // Minimal absences
    final leaveData = [0.0, 1.0, 0.0, 1.0, 2.0, 12.0, 21.0]; // More leave on weekends

    // Calculate max value for scaling
    final maxValue = 30.0; // Max expected attendance count

    // Calculate positions for 7 days
    final dayWidth = size.width / 6; // 6 intervals for 7 points
    
    // Draw each line
    _drawAttendanceLine(canvas, size, presentData, presentColor, dayWidth, maxValue, 'Present');
    _drawAttendanceLine(canvas, size, lateData, lateColor, dayWidth, maxValue, 'Late');
    _drawAttendanceLine(canvas, size, absentData, absentColor, dayWidth, maxValue, 'Absent');
    _drawAttendanceLine(canvas, size, leaveData, leaveColor, dayWidth, maxValue, 'Leave');
  }

  void _drawAttendanceLine(Canvas canvas, Size size, List<double> data, Color color, 
                          double dayWidth, double maxValue, String type) {
    final points = <Offset>[];
    
    // Calculate points
    for (int i = 0; i < data.length; i++) {
      final x = i * dayWidth;
      final y = size.height - (data[i] / maxValue * size.height);
      points.add(Offset(x, y));
    }

    // Create smooth path
    final path = Path();
    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      
      for (int i = 1; i < points.length; i++) {
        final previous = points[i - 1];
        final current = points[i];
        final controlPoint1 = Offset(
          previous.dx + (current.dx - previous.dx) * 0.3,
          previous.dy,
        );
        final controlPoint2 = Offset(
          current.dx - (current.dx - previous.dx) * 0.3,
          current.dy,
        );
        path.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          current.dx, current.dy,
        );
      }
    }

    // Draw the line
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Draw points
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      
      // Outer circle (glow effect)
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 6, glowPaint);
      
      // Main dot
      final dotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 3, dotPaint);
      
      // White center
      canvas.drawCircle(point, 1.5, Paint()..color = AppColors.pureWhite);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}