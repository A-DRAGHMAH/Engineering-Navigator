import 'package:flutter/material.dart';
import 'dart:math' show cos, pi, sin, sqrt;

class ModernGeometricPainter extends CustomPainter {
  final Color color;
  final double spacing;
  final double hexSize;

  ModernGeometricPainter({
    required this.color,
    required this.spacing,
    required this.hexSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw hexagonal pattern
    final double rowHeight = hexSize * 2;
    final double colWidth = hexSize * sqrt(3);

    for (double y = 0; y < size.height + rowHeight; y += spacing) {
      bool oddRow = (y / spacing).round().isOdd;
      double startX = oddRow ? colWidth / 2 : 0;

      for (double x = startX; x < size.width + colWidth; x += spacing) {
        _drawHexagon(canvas, paint, Offset(x, y), hexSize);
      }
    }

    // Draw diagonal lines
    final path = Path();
    for (int i = 0; i < 5; i++) {
      path.moveTo(size.width * (i / 4), 0);
      path.lineTo(size.width * ((i + 1) / 4), size.height);
    }

    // Draw curved lines
    for (int i = 0; i < 3; i++) {
      path.moveTo(0, size.height * (i / 2));
      path.quadraticBezierTo(
        size.width / 2,
        size.height * ((i + 1) / 2),
        size.width,
        size.height * (i / 2),
      );
    }

    canvas.drawPath(path, paint);
  }

  void _drawHexagon(Canvas canvas, Paint paint, Offset center, double size) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (60 * i - 30) * pi / 180;
      double x = center.dx + size * cos(angle);
      double y = center.dy + size * sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
