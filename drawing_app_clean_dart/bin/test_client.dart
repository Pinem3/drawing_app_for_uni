import 'package:web_socket_channel/web_socket_channel.dart';

Future<void> main() async {
  final channel = WebSocketChannel.connect(Uri.parse('ws://127.0.0.1:228'));

  final numbers = [1, 2, 3, 4, 5]; // Числа для отправки
  int index = 0;

  void sendNextNumber() {
    if (index >= numbers.length) {
      channel.sink.close();
      return;
    }

    final number = numbers[index];
    print("Клиент: Отправка числа $number");
    channel.sink.add(number.toString());
    index++;
  }

  // Обработка ответов сервера
  channel.stream.listen((response) {
    print("Клиент: Получен сигнал — $response");
    sendNextNumber(); // Отправляем следующее число сразу после ответа
  });

  // Запускаем процесс
  sendNextNumber();

  // Ждём завершения (в реальном приложении можно использовать Completer)
  await Future.delayed(Duration(seconds: 30));
}
