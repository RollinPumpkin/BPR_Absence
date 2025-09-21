import 'package:flutter/material.dart';

class AttendanceChart extends StatelessWidget {
  const AttendanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                'Total Attendance Report',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Icon(
                Icons.more_horiz,
                color: Colors.grey.shade400,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          /// Chart Area
          Container(
            height: 120,
            width: double.infinity,
            child: CustomPaint(
              painter: AttendanceChartPainter(),
            ),
          ),
          
          const SizedBox(height: 10),
          
          /// Y-axis labels (simplified)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '60',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                '70',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                '80',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                '90',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                '100',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AttendanceChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Define modern gradient colors
    final gradientColors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Purple
      const Color(0xFFA855F7), // Purple
    ];

    // Sample data points for the smooth curve
    final points = [
      Offset(0, size.height * 0.7),
      Offset(size.width * 0.15, size.height * 0.5),
      Offset(size.width * 0.3, size.height * 0.8),
      Offset(size.width * 0.45, size.height * 0.3),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.75, size.height * 0.15),
      Offset(size.width * 0.9, size.height * 0.2),
      Offset(size.width, size.height * 0.1),
    ];

    // Create smooth curved path using quadratic Bezier curves
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    
    for (int i = 0; i < points.length - 1; i++) {
      final current = points[i];
      final next = points[i + 1];
      final controlPoint = Offset(
        current.dx + (next.dx - current.dx) * 0.5,
        current.dy,
      );
      path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, next.dx, next.dy);
    }

    // Create gradient fill area
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    // Fill gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          gradientColors[0].withOpacity(0.3),
          gradientColors[1].withOpacity(0.1),
          gradientColors[2].withOpacity(0.05),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Draw the main line with gradient
    final linePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: gradientColors,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);

    // Draw modern dots on the line
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      
      // Outer glow
      final glowPaint = Paint()
        ..color = gradientColors[i % gradientColors.length].withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(point, 8, glowPaint);
      
      // Main dot with gradient
      final dotPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            gradientColors[i % gradientColors.length],
            gradientColors[i % gradientColors.length].withOpacity(0.8),
          ],
        ).createShader(Rect.fromCircle(center: point, radius: 5));
      canvas.drawCircle(point, 5, dotPaint);
      
      // White center highlight
      canvas.drawCircle(point, 2, Paint()..color = Colors.white.withOpacity(0.9));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}