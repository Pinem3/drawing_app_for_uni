import 'package:shelf/shelf_io.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'dart:math';

void main() {
  var rnd = Random();
  final handler = webSocketHandler((WebSocketChannel channel) async {
    channel.stream.listen((message) async {
      final number = int.parse(message);
      print("Сервер: Обработка числа $number");

      // Имитация асинхронной обработки
      await Future.delayed(Duration(seconds: rnd.nextInt(10)));

      channel.sink.add('2'); // Сигнал клиенту
    });
  });

  serve(handler, '127.0.0.1', 228).then((server) {
    print('Сервер запущен на ws://localhost:8080');
  });
}
