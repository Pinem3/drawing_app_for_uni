import 'dart:collection';
import 'dart:math';
import 'package:image/image.dart' as img;

import 'package:flutter/material.dart';

class ImageLayer {
  final List<Offset> pixels;
  final Rect boundingBox;

  ImageLayer(this.pixels) : boundingBox = _calculateBoundingBox(pixels);

  static Rect _calculateBoundingBox(List<Offset> pixels) {
    double minX = double.infinity, minY = double.infinity;
    double maxX = -double.infinity, maxY = -double.infinity;

    for (final p in pixels) {
      minX = min(minX, p.dx);
      minY = min(minY, p.dy);
      maxX = max(maxX, p.dx);
      maxY = max(maxY, p.dy);
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

List<ImageLayer> splitIntoLayers(img.Image image) {
  final width = image.width;
  final height = image.height;
  final visited = List.generate(width, (_) => List.filled(height, false));
  final layers = <ImageLayer>[];

  // Направления для 8-связности (диагонали включены)
  const directions = [
    Offset(-1, -1),
    Offset(0, -1),
    Offset(1, -1),
    Offset(-1, 0),
    Offset(1, 0),
    Offset(-1, 1),
    Offset(0, 1),
    Offset(1, 1),
  ];

  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      if (!visited[x][y] && _isBlackPixel(image, x, y)) {
        final layerPixels = <Offset>[];
        final queue = Queue<Offset>();
        queue.add(Offset(x.toDouble(), y.toDouble()));
        visited[x][y] = true;

        // BFS для поиска всех пикселей компоненты
        while (queue.isNotEmpty) {
          final p = queue.removeFirst();
          layerPixels.add(p);

          for (final dir in directions) {
            final nx = (p.dx + dir.dx).toInt();
            final ny = (p.dy + dir.dy).toInt();

            if (nx >= 0 &&
                nx < width &&
                ny >= 0 &&
                ny < height &&
                !visited[nx][ny] &&
                _isBlackPixel(image, nx, ny)) {
              visited[nx][ny] = true;
              queue.add(Offset(nx.toDouble(), ny.toDouble()));
            }
          }
        }

        layers.add(ImageLayer(layerPixels));
      }
    }
  }

  // Сортируем слои по размеру (от крупных к мелким)
  layers.sort((a, b) => b.pixels.length.compareTo(a.pixels.length));
  return layers;
}

bool _isBlackPixel(img.Image image, int x, int y) {
  final pixel = image.getPixel(x, y);
  final luminance = img.getLuminance(pixel);
  if (luminance < 128) {
    return true;
  } else {
    return false;
  }
}
