import 'package:web_socket_channel/web_socket_channel.dart';

void main() async {
  final channel = WebSocketChannel.connect(Uri.parse('ws://127.0.0.1:228'));

  // Отправка чисел
  for (int i = 1; i <= 5; i++) {
    print("Клиент: Отправка числа $i");
    channel.sink.add(i.toString());
    await Future.delayed(Duration(seconds: 10));
  }

  // Получение ответов
  channel.stream.listen((response) {
    print("Клиент: $response");
  });

  // Закрытие соединения (по необходимости)
  await Future.delayed(Duration(seconds: 10));
  channel.sink.close();
}
