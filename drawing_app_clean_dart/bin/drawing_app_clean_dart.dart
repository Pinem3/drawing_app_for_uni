import 'dart:async';
import 'dart:io';
//import 'dart:convert';
import 'dart:typed_data';
//import 'package:drawing_app_clean_dart/drawing_app_clean_dart.dart';

class Plc {
  bool parkingDone = false;
  List<int> coord = [0, 0];
  bool parking(int value) {
    if (value == 1) {
      parkingDone = true;
      coord = [0, 0];
    }
    return parkingDone;
  }
}

Uint8List int32bytes(int input) {
  return Uint8List(4)..buffer.asInt32List()[0] = input;
}

List<int> doubleToBytes(double value) {
  ByteData bytes = ByteData(8);
  bytes.setFloat64(0, value);
  var response = bytes.buffer.asInt8List().reversed.toList();
  return response;
}

List<int> listDoubleToListInt(List<double> values) {
  Uint8List val = Uint8List(8);
  List<int> iVal = [];
  for (int i = 0; i < values.length; i++) {
    val.buffer.asFloat64List()[0] = values[i];
    iVal += val;
  }
  return iVal;
}

Uint8List writeRext(int command, List<double> coord) {
  List<double> dot1 = coord;
  List<double> dot2 = [0, 0, 0, 0];
  List<double> dot3 = [0, 0, 0, 0];
  List<double> dot4 = [0, 0, 0, 0];
  int size = command;
  dot2[0] = dot1[0] + size;
  dot3[1] = dot1[1] + size;
  dot3[0] = dot1[0] + size;
  dot4[1] = dot4[1] + size;
  Uint8List val = Uint8List(32 * 4);
  List<double> coordinates = dot1 + dot2 + dot3 + dot4;
  for (int i = 0; i < coordinates.length; i++) {
    val.buffer.asFloat64List()[i] = coordinates[i];
  }
  val.reversed.toList();
  return val;
}

Future<void> menu(Socket socket) async {
  while (true) {
    print('*' * 40);
    print('1. Сделать парковку');
    print('2. Ввести соординаты');
    print('3. Выйти');
    print('*' * 40);
    var input = stdin.readLineSync();
    if (input is String) {
      switch (input) {
        case '1':
          print('Выполняется парковка');
          int input = 1;
          var j = int32bytes(input);
          try {
            socket.add(j);
          } catch (e) {
            print('Произошла ошибка:  $e');
          }
        case '2':
          print('Введите список из 2 чисел с точкой через пробел');
          List<String> inputlist = stdin.readLineSync()!.split(' ');
          List<double> list = inputlist.map(double.parse).toList();
          List<int> outList = int32bytes(2);
          outList += (listDoubleToListInt(list));
          try {
            socket.add(outList);
          } catch (e) {
            print('Произошла ошибка:  $e');
          }
        case '3':
          socket.destroy();
          return;
        default:
          print('Некорректный ввод');
      }
    }
    // socket.listen((List<int> data) {
    //   _dataController.add(data);
    //   if (data.length == 1 && data[0] == 1 && !_signalCompleter.isCompleted) {
    //     _signalCompleter.complete();
    //     print('Парковка выполнена');
    //   } else if (data.length == 1 &&
    //       data[0] == 2 &&
    //       !_signalCompleter.isCompleted) {
    //     _dataController.add(data);
    //     print('Подвод выполнен');
    //     _signalCompleter.complete();
    //   } else {
    //     print('Получены неожиданные данные: $data');
    //   }
    // });
    await Future.delayed(const Duration(seconds: 10));
  }
}

void main(List<String> arguments) async {
  var socket = await Socket.connect(
    '10.0.174.50',
    228,
    timeout: Duration(seconds: 1),
  );
  socket.listen((List<int> data) {
    if (data.length == 1 && data[0] == 1) {
      //signalCompleter.complete();
      print('Парковка выполнена');
    } else if (data.length == 1 && data[0] == 2) {
      //signalCompleter.complete();
      print('Подвод выполнен');
    } else {
      //signalCompleter.complete();
      print('Получены неожиданные данные: $data');
    }
  });
  menu(socket);
}
