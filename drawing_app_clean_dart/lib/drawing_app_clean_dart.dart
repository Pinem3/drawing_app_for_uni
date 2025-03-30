import 'dart:typed_data';

class Rectangle {
  List<double> dot1 = [0,0,0,0];
  List<double> dot2 = [0,0,0,0];
  List<double> dot3 = [0,0,0,0];
  List<double> dot4 = [0,0,0,0];
  int size = 0;

  Rectangle(
    this.dot1,
    this.size
  );

  Uint8List drawRect() {
    dot2[0] = dot1[0] + size;
    dot3[1] = dot1[1] + size;
    dot3[0] = dot1[0] + size;
    dot4[1] = dot4[1] + size;
    Uint8List val = Uint8List(32*4);
    List<double> coordinates = dot1 + dot2 + dot3 + dot4;
    for(int i = 0; i < coordinates.length; i++) {
      val.buffer.asFloat64List()[i] = coordinates[i];
    }
    return val;
  }

}