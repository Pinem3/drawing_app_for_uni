import 'dart:io';
import 'package:image/image.dart' as img;

void main(List<String> arguments) async {
  print('Введите путь до изображения');
  String input = stdin.readLineSync()!;
  final path = input;
  final cmd =
      img.Command()
        ..decodeImageFile(path)
        ..copyResize(width: 100)
        ..writeToFile('thubnail.png');
  await cmd.executeThread();
}
