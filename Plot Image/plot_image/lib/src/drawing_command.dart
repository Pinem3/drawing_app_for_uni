import 'dart:typed_data';

enum DrawingMode { park, move, line, arc, stop }

class DrawingCommand {
  final DrawingMode mode;
  final double x1, y1;
  final double? x2, y2;
  DrawingCommand(this.mode, this.x1, this.y1, [this.x2, this.y2]);

  Uint8List toBytes() {
    final bytes = ByteData(1 + 16 + (mode == DrawingMode.arc ? 16 : 0));
    bytes.setUint8(0, mode.index);
    bytes.setFloat64(1, x1, Endian.little);
    bytes.setFloat64(9, y1, Endian.little);

    if (mode == DrawingMode.arc) {
      bytes.setFloat64(17, x2!, Endian.little);
      bytes.setFloat64(25, y2!, Endian.little);
    }

    return bytes.buffer.asUint8List();
  }

  static DrawingCommand park() => DrawingCommand(DrawingMode.park, 0, 0);
  static DrawingCommand moveTo(double x, double y) => DrawingCommand(DrawingMode.move, x, y);
  static DrawingCommand lineTo(double x, double y) => DrawingCommand(DrawingMode.line, x, y);
  static DrawingCommand arcTo(double x, double y, double cx, double cy) =>
      DrawingCommand(DrawingMode.arc, x, y, cx, cy);
  static DrawingCommand stop() => DrawingCommand(DrawingMode.stop, 0, 0);
  @override
  String toString() {
    return '$mode, $x1, $y1';
  }
}
