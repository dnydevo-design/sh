import 'dart:math' as math;

import 'package:flutter/material.dart';

class RadarPainter extends CustomPainter {
  const RadarPainter({
    required this.sweepRadians,
    required this.blips,
  });

  final double sweepRadians;
  final int blips;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFF00E5FF).withValues(alpha: 0.28);
    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * i / 4, ringPaint);
    }

    final axisPaint = Paint()
      ..strokeWidth = 1
      ..color = const Color(0xFFFF2BD6).withValues(alpha: 0.18);
    canvas
      ..drawLine(Offset(center.dx - radius, center.dy), Offset(center.dx + radius, center.dy), axisPaint)
      ..drawLine(Offset(center.dx, center.dy - radius), Offset(center.dx, center.dy + radius), axisPaint);

    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: sweepRadians,
        endAngle: sweepRadians + math.pi / 2,
        colors: [
          const Color(0xFF00E5FF).withValues(alpha: 0),
          const Color(0xFF00E5FF).withValues(alpha: 0.42),
          const Color(0xFFFF2BD6).withValues(alpha: 0.62),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, sweepPaint);

    final blipPaint = Paint()..color = const Color(0xFFFF2BD6);
    for (var i = 0; i < blips.clamp(0, 8); i++) {
      final angle = (i * 1.7 + 0.6) % (math.pi * 2);
      final distance = radius * (0.28 + (i % 4) * 0.16);
      canvas.drawCircle(
        Offset(center.dx + math.cos(angle) * distance, center.dy + math.sin(angle) * distance),
        5,
        blipPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RadarPainter oldDelegate) {
    return oldDelegate.sweepRadians != sweepRadians ||
        oldDelegate.blips != blips;
  }
}

