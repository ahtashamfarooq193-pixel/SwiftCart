import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CircularOrderTracker extends StatelessWidget {
  final String status;

  const CircularOrderTracker({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // Determine progress and color based on status
    double progress = 0.33;
    Color color = AppTheme.warningColor; // Processing
    IconData icon = Icons.cached;
    String statusText = 'Processing';

    if (status == 'Payment Verified' || status == 'Verified' || status == 'Shipped') {
      progress = 0.66;
      color = AppTheme.accentColor;
      icon = Icons.check_circle_outline;
      statusText = 'Verified';
    } else if (status == 'Delivered') {
      progress = 1.0;
      color = AppTheme.successColor;
      icon = Icons.local_shipping_outlined;
      statusText = 'Delivered';
    } else if (status == 'Cancelled') {
      progress = 0.0;
      color = AppTheme.errorColor;
      icon = Icons.cancel_outlined;
      statusText = 'Cancelled';
    }

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Circle (faded)
          SizedBox(
            width: 200,
            height: 200,
            child: CustomPaint(
              painter: _CircularTrackPainter(
                progress: 1.0,
                color: AppTheme.darkGrey.withOpacity(0.3),
                width: 15,
              ),
            ),
          ),
          // Progress Circle (Animated)
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress),
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: _CircularTrackPainter(
                    progress: value,
                    color: color,
                    width: 15,
                  ),
                ),
              );
            },
          ),
          // Center Content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                statusText,
                style: AppTheme.headline3.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircularTrackPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double width;

  _CircularTrackPainter({
    required this.progress,
    required this.color,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2) - width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = color;

    // Draw 3 segments with gaps
    final double gap = 0.1; // radian gap
    final double segmentAngle = (2 * pi - (3 * gap)) / 3;

    // We can draw the full progress as a single arc for simplicity in animation,
    // or simulate segments. For this design, let's draw a continuous arc that stops at segment boundaries.
    
    // Rotate to start from top
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-pi / 2);

    final sweepAngle = 2 * pi * progress;
    
    // Draw background/foreground arc
    if (progress > 0) {
       canvas.drawArc(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        0,
        sweepAngle,
        false,
        paint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
