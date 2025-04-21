import 'dart:math';
import 'dart:io';
import 'dart:typed_data';

Future<void> startPLCServer() async {
  final server = await ServerSocket.bind('127.0.0.1', 228);
  print('Сервер ПЛК запущен на ${server.address}:${server.port}');

  await for (final clientSocket in server) {
    clientSocket.listen(
      (Uint8List data) async {
        print('Получена команда: ${data.first}');
        if (data.first == 0) {
          print('Выполняется парковка');
          final delay = Random().nextInt(10) + 1;
          await Future.delayed(Duration(milliseconds: delay));
          clientSocket.add(Uint8List.fromList([1]));
        } else {
          print('Координаты ${data.skip(1)}');

          // Имитация задержки ПЛК (1-10 сек)
          final delay = Random().nextInt(10) + 1;
          await Future.delayed(Duration(milliseconds: delay));

          // Отправляем подтверждение (байт `2`)
          clientSocket.add(Uint8List.fromList([2]));
          print('Отправлено подтверждение после $delay сек');
        }
      },
      onError: (e) => print('Ошибка: $e'),
      onDone: () => clientSocket.close(),
    );
  }
}

void main() => startPLCServer();
