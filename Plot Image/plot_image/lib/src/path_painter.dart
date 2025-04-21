import 'package:flutter/material.dart';
import 'dart:ui' as img;

class PathPainter extends CustomPainter {
  final List<Offset> path;
  final img.Image image;

  PathPainter({required this.path, required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    // Рисуем исходное изображение
    canvas.drawImage(image, Offset.zero, Paint());

    // Рисуем путь
    final pathPaint =
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final drawingPath = Path();
    if (path.isNotEmpty) {
      drawingPath.moveTo(path[0].dx, path[0].dy);
      for (final point in path.skip(1)) {
        drawingPath.lineTo(point.dx, point.dy);
      }
    }
    canvas.drawPath(drawingPath, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
