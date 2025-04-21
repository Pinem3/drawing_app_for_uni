import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:plot_image/src/drawing_command.dart';

class PaintWidget extends StatelessWidget {
  final List<DrawingCommand> commands;
  final Size canvasSize;
  final ui.Image? sourceImage;
  final int currentCommandIndex;
  const PaintWidget({
    super.key,
    required this.commands,
    required this.canvasSize,
    this.sourceImage,
    required this.currentCommandIndex,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: canvasSize,
      painter: DrawingPreview(
        commands: commands,
        currentCommandIndex: currentCommandIndex,
        sourceImage: sourceImage,
      ),
    );
  }
}

class DrawingPreview extends CustomPainter {
  final ui.Image? sourceImage; // Исходное изображение (для фона)
  final List<DrawingCommand> commands; // Все команды
  final int currentCommandIndex; // Текущая команда
  Offset _lastPosition = Offset.zero;

  DrawingPreview({this.sourceImage, required this.commands, required this.currentCommandIndex});

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Рисуем исходное изображение (серым)
    if (sourceImage != null) {
      final paint = Paint()..colorFilter = ColorFilter.mode(Colors.white70, BlendMode.screen);
      canvas.drawImageRect(
        sourceImage!,
        Rect.fromLTWH(0, 0, sourceImage!.width.toDouble(), sourceImage!.height.toDouble()),
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );
    }

    // 2. Рисуем выполненные команды (чёрные линии)
    final path = Path();
    final penDownPaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    for (int i = 0; i < currentCommandIndex; i++) {
      final cmd = commands[i];
      _applyCommandToPath(cmd, path);
    }
    canvas.drawPath(path, penDownPaint);

    // 3. Рисуем текущее перемещение (синяя линия)
    if (currentCommandIndex < commands.length) {
      final currentCmd = commands[currentCommandIndex];
      final previewPath = Path();

      // Начинаем с последней позиции!
      previewPath.moveTo(_lastPosition.dx, _lastPosition.dy);

      // Добавляем целевую точку
      switch (currentCmd.mode) {
        case DrawingMode.move:
        case DrawingMode.line:
          previewPath.lineTo(currentCmd.x1, currentCmd.y1);
          break;
        case DrawingMode.arc:
          previewPath.quadraticBezierTo(
            currentCmd.x2!,
            currentCmd.y2!,
            currentCmd.x1,
            currentCmd.y1,
          );
          break;
        case DrawingMode.park:
          previewPath.lineTo(0, 0);
          break;
        case DrawingMode.stop:
          // TODO: Handle this case.
          throw UnimplementedError();
      }

      final previewPaint =
          Paint()
            ..color = Colors.blue
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.0;

      canvas.drawPath(previewPath, previewPaint);
    }

    // 4. Рисуем текущую позицию ручки (красная точка)
    final currentPosition = _getCurrentPosition();
    final dotPaint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(currentPosition.dx, currentPosition.dy), 3.0, dotPaint);
    _lastPosition = _getCurrentPosition();
  }

  // Возвращает текущие координаты ручки
  Offset _getCurrentPosition() {
    if (commands.isEmpty) return Offset.zero;

    double x = 0, y = 0;
    for (int i = 0; i < currentCommandIndex; i++) {
      final cmd = commands[i];
      switch (cmd.mode) {
        case DrawingMode.move:
        case DrawingMode.line:
          x = cmd.x1;
          y = cmd.y1;
          break;
        case DrawingMode.arc:
          x = cmd.x1;
          y = cmd.y1;
          break;
        case DrawingMode.park:
          x = 0;
          y = 0;
          break;
        case DrawingMode.stop:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
    }
    return Offset(x, y);
  }

  // Обновляет Path в зависимости от типа команды
  void _applyCommandToPath(DrawingCommand cmd, Path path) {
    switch (cmd.mode) {
      case DrawingMode.move:
        path.moveTo(cmd.x1, cmd.y1);
        break;
      case DrawingMode.line:
        path.lineTo(cmd.x1, cmd.y1);
        break;
      case DrawingMode.arc:
        // Упрощённая дуга (можно заменить на arcTo)
        path.quadraticBezierTo(cmd.x2!, cmd.y2!, cmd.x1, cmd.y1);
        break;
      case DrawingMode.park:
        path.moveTo(0, 0);
        break;
      case DrawingMode.stop:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPreview oldDelegate) {
    return oldDelegate.currentCommandIndex != currentCommandIndex;
  }
}
