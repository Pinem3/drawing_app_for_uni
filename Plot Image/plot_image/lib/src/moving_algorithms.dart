import 'package:image/image.dart' as img;
import 'package:plot_image/src/drawing_command.dart';
import 'dart:ui';

class MovingAlgorithms {
  final img.Image image;
  MovingAlgorithms({required this.image});

  List<DrawingCommand> vectorizeImage() {
    final commands = <DrawingCommand>[];
    final path = <Offset>[];
    bool isDrawingLine = false;
    int lineStartX = 0;
    double lastY = 0;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; y < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final luminiscence = img.getLuminance(pixel);
        final isBlack = luminiscence < 128;

        if (isBlack) {
          if (!isDrawingLine) {
            lineStartX = x;
            lastY = y.toDouble();
            isDrawingLine = true;
          }
        } else {
          if (isDrawingLine) {
            path.add(Offset(lineStartX.toDouble(), lastY));
            path.add(Offset((x - 1).toDouble(), lastY));
            isDrawingLine = false;
          }
        }
      }
      if (isDrawingLine) {
        path.add(Offset(lineStartX.toDouble(), y.toDouble()));
        path.add(Offset((image.width - 1).toDouble(), y.toDouble()));
        isDrawingLine = false;
      }
    }
    if (path.isEmpty) return commands;

    bool isPenDown = false;

    for (int i = 0; i < path.length; i += 2) {
      if (i + 1 >= path.length) break;

      final start = path[i];
      final end = path[i + 1];

      if (!isPenDown ||
          (i > 0 && start.dx != path[i - 1].dx) ||
          (i > 0 && start.dy != path[i - 1].dy)) {
        commands.add(DrawingCommand.moveTo(start.dx, start.dy));
        isPenDown = false;
      }
      if (!isPenDown) {
        commands.add(DrawingCommand.lineTo(start.dx, start.dy));
      }

      commands.add(DrawingCommand.lineTo(end.dx, end.dy));
    }
    return commands;
  }
}
