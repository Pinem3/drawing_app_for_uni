import 'dart:io';
import 'dart:ui';
import 'package:image/image.dart' as img;

void main(List<String> arguments) async {
  String input = stdin.readLineSync()!;
  final path = input.isNotEmpty ? input[0] : 'test.png';
  img.Image myImage = img.decodeImageFile(path) as img.Image;
  convertToBlackAndWhite(myImage);
}

img.Image convertToBlackAndWhite(img.Image image) {
  return img.grayscale(image);
}

List<Offset> generatePath(img.Image image) {
  final path = <Offset>[];
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final luminance = img.getLuminance(pixel);
      if (luminance < 128) {
        path.add(Offset(x.toDouble(), y.toDouble()));
      }
    }
  }
  return path;
}
