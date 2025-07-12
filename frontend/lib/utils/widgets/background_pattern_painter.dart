import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../theme/app_color.dart';

/// A custom painter that draws a subtle geometric background pattern.
class BackgroundPatternPainter extends CustomPainter {
  const BackgroundPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.textWhite.withOpacity(0.1)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const spacing = 40.0;
    final rows = (size.height / spacing).ceil();
    final cols = (size.width / spacing).ceil();

    for (int i = 0; i < rows; i++) {
      for (int j = 0; j < cols; j++) {
        final x = j * spacing;
        final y = i * spacing;

        // Circle opacity based on a sine-cosine pattern
        final opacity = (math.sin(i * 0.5) * math.cos(j * 0.5)).abs() * 0.3;
        paint.color = AppColors.textWhite.withOpacity(opacity * 0.2);

        canvas.drawCircle(
          Offset(x, y),
          8.0,
          paint,
        );

        // Draw horizontal connector lines
        if (j < cols - 1) {
          paint.color = AppColors.textWhite.withOpacity(0.05);
          canvas.drawLine(
            Offset(x + 8, y),
            Offset(x + spacing - 8, y),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant BackgroundPatternPainter oldDelegate) => false;
}
