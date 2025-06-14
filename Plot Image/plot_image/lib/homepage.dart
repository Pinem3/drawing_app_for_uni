import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_converter/flutter_image_converter.dart';
import 'package:image/image.dart' as img;
import 'package:plot_image/src/drawing_command.dart';
import 'package:plot_image/src/image_drop_region.dart';
import 'package:plot_image/src/paint.dart';

// ignore: must_be_immutable
class Homepage extends StatefulWidget {
  List<DrawingCommand> commands = [];
  final String title;
  List<String> logLost = [];
  Socket? socket;
  bool isParked = false;
  bool stopped = false;

  Homepage({super.key, required this.title});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int currentCommandIndex = 0;
  String host = '127.0.0.1';
  int port = 228;
  String connectivity = 'Ожидание подключения';
  img.Image? image;
  String inputPath = '';
  bool normImage = false;
  late ui.Image uiImage;
  ButtonStyle buttonStyle = ButtonStyle(
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
  );

  void setExternalData(Uint8List data, String type) {
    if (type == 'png') {
      setState(() {
        image = img.decodePng(data);
        normImage = true;
      });
    } else {
      setState(() {
        image = img.decodeJpg(data);
        normImage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title, style: TextStyle(color: Colors.white)),
      ),
      body: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
        ),
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                spacing: 20,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 20, bottom: 5),
                    child: Row(
                      spacing: 20,
                      children: [
                        Text('IP-адрес'),
                        SizedBox(
                          width: 300,
                          child: TextField(
                            decoration: InputDecoration(
                              constraints: BoxConstraints(maxHeight: 30),
                              border: UnderlineInputBorder(),
                              hintText: 'Введите IP-адрес',
                            ),
                            onSubmitted: (value) {
                              setState(() {
                                host = value;
                              });
                            },
                            onChanged: (value) {
                              setState(() {
                                host = value;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 20, bottom: 5),
                    child: Row(
                      spacing: 20,
                      children: [
                        Text('Порт'),
                        SizedBox(
                          width: 200,
                          child: TextField(
                            decoration: InputDecoration(
                              constraints: BoxConstraints(maxHeight: 30),
                              border: UnderlineInputBorder(),
                              hintText: 'Введите Порт',
                            ),
                            onChanged: (value) {
                              setState(() {
                                port = int.parse(value);
                              });
                            },
                            onSubmitted: (value) {
                              setState(() {
                                port = int.parse(value);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    spacing: 20,
                    children: [
                      SizedBox(),
                      SizedBox(
                        width: 150,
                        child: FilledButton(
                          style: buttonStyle,
                          onPressed: () {
                            setState(() {
                              connection(host, port);
                            });
                          },
                          child: Text('Подключиться'),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.3,
                        child: SelectableText(connectivity, maxLines: 3),
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.grey[100],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Введите путь к файлу',
                      ),
                      onSubmitted: (value) async {
                        setState(() {
                          if (value.isNotEmpty) {
                            inputPath = value;
                            if (inputPath.contains('"')) {
                              inputPath = inputPath.replaceFirst('"', '');
                              inputPath = inputPath.replaceFirst(
                                '"',
                                '',
                                inputPath.length - 2,
                              );
                            }
                            File file = File(inputPath);
                            var bytes = file.readAsBytesSync();
                            if (inputPath.contains('.jpg')) {
                              image = img.decodeJpg(bytes);
                            } else if (inputPath.contains('.png')) {
                              image = img.decodePng(bytes);
                            }
                          }
                          normImage = true;
                          image == null;
                        });
                      },
                    ),
                  ),
                  Row(
                    spacing: 20,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 10,
                        children: [
                          FilledButton(
                            style: buttonStyle,
                            onPressed:
                                image == null
                                    ? null
                                    : () {
                                      setState(() {
                                        convertToBlackAndWhite(image!);
                                      });
                                    },
                            child: Text('Преобразовать в серое'),
                          ),
                          FilledButton(
                            style: buttonStyle,
                            onPressed:
                                image == null
                                    ? null
                                    : () async {
                                      setState(() {
                                        scaleImage(image!);
                                      });
                                      uiImage = await image!.uiImage;
                                    },
                            child: Text('Изменить размер изображения'),
                          ),
                          FilledButton(
                            style: buttonStyle,
                            onPressed:
                                image == null
                                    ? null
                                    : () {
                                      setState(() {
                                        widget.commands = generateSnakePath(
                                          image!,
                                        );
                                        normImage = false;
                                      });
                                    },
                            child: Text('Сгенерировать путь'),
                          ),
                        ],
                      ),
                      Column(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FilledButton(
                            style: buttonStyle,
                            onPressed:
                                (widget.socket == null &&
                                        widget.isParked == false)
                                    ? null
                                    : () async {
                                      setState(() {
                                        widget.socket!.add(
                                          DrawingCommand.park().toBytes(),
                                        );
                                      });
                                      final stream =
                                          widget.socket!.asBroadcastStream();
                                      await stream.firstWhere(
                                        (data) =>
                                            data.isNotEmpty && data.first == 1,
                                      );
                                      setState(() {
                                        widget.isParked == true;
                                        widget.logLost.add(
                                          'Парковка выполнена',
                                        );
                                      });
                                    },
                            child: Text('Выполнить парковку'),
                          ),
                          FilledButton(
                            style: buttonStyle,
                            onPressed:
                                (image != null &&
                                        normImage == false &&
                                        widget.socket != null)
                                    ? () {
                                      sendCommandsWithAck(
                                        widget.commands,
                                        widget.socket,
                                      );
                                    }
                                    : null,
                            child: Text('Отправить путь'),
                          ),
                          FilledButton(
                            style: buttonStyle,
                            onPressed:
                                (image != null &&
                                        normImage == false &&
                                        widget.socket != null)
                                    ? () {
                                      setState(() {
                                        widget.stopped = true;
                                      });
                                    }
                                    : null,
                            child: Text("Завершить"),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: 200,
                    color: Colors.white,
                    padding: EdgeInsets.all(10),
                    child: ListView.builder(
                      itemCount: widget.logLost.length,
                      itemBuilder: (_, index) {
                        return ListTile(title: Text(widget.logLost[index]));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            child: ImageDropRegion(
              setExternalData: setExternalData,
              child: imageContainer(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> connection(String? host, int port) async {
    host ??= '127.0.0.1';
    host.isEmpty ? host = '127.0.0.1' : host;
    if (widget.socket != null) {
      widget.socket!.close();
    }
    try {
      setState(() {
        connectivity = 'Подключаемся по $host:$port';
      });
      widget.socket = await Socket.connect(
        host,
        port,
        timeout: Duration(seconds: 5),
      );
    } catch (e) {
      setState(() {
        connectivity = 'Ошибка подключения: $e';
      });
      return;
    }
    setState(() {
      connectivity = 'Подключено';
    });
  }

  img.Image convertToBlackAndWhite(img.Image image) {
    return img.grayscale(image);
  }

  List<DrawingCommand> vectorizeImage(img.Image image) {
    final commands = <DrawingCommand>[];
    final path = <Offset>[];
    bool isDrawingLine = false;
    int lineStartX = 0;
    double lastY = 0;

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final luminance = img.getLuminance(pixel);
        final isBlack = luminance < 128;

        if (isBlack) {
          if (!isDrawingLine) {
            // Начало новой линии
            lineStartX = x;
            lastY = y.toDouble();
            isDrawingLine = true;
          }
        } else {
          if (isDrawingLine) {
            // Конец линии - добавляем начало и конец
            path.add(Offset(lineStartX.toDouble(), lastY));
            path.add(Offset((x - 1).toDouble(), lastY));
            isDrawingLine = false;
          }
        }
      }

      // Завершаем линию если достигли конца строки
      if (isDrawingLine) {
        path.add(Offset(lineStartX.toDouble(), y.toDouble()));
        path.add(Offset((image.width - 1).toDouble(), y.toDouble()));
        isDrawingLine = false;
      }
    }
    if (path.isEmpty) return commands;

    bool isPenDown = false;

    for (int i = 0; i < path.length; i += 2) {
      if (i + 1 >= path.length) break; // Непарная точка в конце

      final start = path[i];
      final end = path[i + 1];

      // Если это начало новой линии (не продолжение предыдущей)
      if (!isPenDown ||
          (i > 0 && start.dx != path[i - 1].dx) ||
          (i > 0 && start.dy != path[i - 1].dy)) {
        commands.add(
          DrawingCommand.moveTo(start.dx, start.dy),
        ); // Поднять ручку
        isPenDown = false;
      }

      // Опустить ручку и рисовать
      if (!isPenDown) {
        commands.add(DrawingCommand.lineTo(start.dx, start.dy)); // Начало линии
        isPenDown = true;
      }

      commands.add(DrawingCommand.lineTo(end.dx, end.dy)); // Конец линии
    }
    return commands;
  }

  Widget imageContainer() {
    if (image == null) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 50, color: Colors.grey),
              SizedBox(height: 16),
              Text('Перетащите PNG/JPEG сюда', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    } else if (normImage) {
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width * 0.5,
        child: Image.memory(Uint8List.fromList(img.encodePng(image!))),
      );
    } else {
      return SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width * 0.5,
        child: Center(
          child: SizedBox(
            height: image!.height.toDouble(),
            width: image!.width.toDouble(),
            child: PaintWidget(
              commands: widget.commands,
              currentCommandIndex: currentCommandIndex,
              sourceImage: uiImage,
              canvasSize: ui.Size(
                image!.width.toDouble(),
                image!.height.toDouble(),
              ),
            ),
          ),
        ),
      );
    }
  }

  List<DrawingCommand> generateSnakePath(img.Image image) {
    final commands = <DrawingCommand>[];
    final width = image.width;
    final height = image.height;
    bool movingRight = true;
    bool isPenDown = false;
    int? lastX, lastY;

    for (int y = 0; y < height; y++) {
      // Быстрая проверка строки на наличие черных пикселей
      if (!_hasBlackPixelsInRow(image, y)) {
        movingRight =
            !movingRight; // Инвертируем направление для следующей строки
        continue;
      }

      int x = movingRight ? 0 : width - 1;
      int? lineStartX;

      while (movingRight ? x < width : x >= 0) {
        bool shouldDraw = _shouldDrawPixel(image, x, y);

        if (shouldDraw) {
          // Находим конец непрерывного отрезка
          int segmentEnd = x;
          while (movingRight ? segmentEnd < width : segmentEnd >= 0) {
            if (!_shouldDrawPixel(image, segmentEnd, y)) break;
            movingRight ? segmentEnd++ : segmentEnd--;
          }
          movingRight ? segmentEnd-- : segmentEnd++;

          // Добавляем команды для отрезка
          _addOptimizedSegment(
            commands: commands,
            x1: x,
            x2: segmentEnd,
            y: y,
            isPenDown: isPenDown,
            lastX: lastX,
            lastY: lastY,
          );

          // Обновляем позиции
          lastX = segmentEnd;
          lastY = y;
          isPenDown = true;
          x = segmentEnd; // Пропускаем обработанные пиксели
        }

        movingRight ? x++ : x--;
      }

      // Находим следующую строку с черными пикселями
      int nextY = y + 1;
      while (nextY < height && !_hasBlackPixelsInRow(image, nextY)) {
        nextY++;
      }

      if (nextY < height) {
        int targetX = movingRight ? width - 1 : 0;
        bool shouldConnect = _shouldDrawPixel(image, targetX, nextY);

        if (shouldConnect) {
          commands.add(
            DrawingCommand.lineTo(targetX.toDouble(), nextY.toDouble()),
          );
        } else {
          commands.add(
            DrawingCommand.moveTo(targetX.toDouble(), nextY.toDouble()),
          );
          isPenDown = false;
        }
        lastX = targetX;
        lastY = nextY;
      }

      movingRight = !movingRight;
      y = nextY - 1; // -1 потому что цикл for сделает y++
    }

    return commands;
  }

  bool _hasBlackPixelsInRow(img.Image image, int y) {
    for (int x = 0; x < image.width; x++) {
      if (_shouldDrawPixel(image, x, y)) return true;
    }
    return false;
  }

  void _addOptimizedSegment({
    required List<DrawingCommand> commands,
    required int x1,
    required int x2,
    required int y,
    required bool isPenDown,
    required int? lastX,
    required int? lastY,
  }) {
    if (!isPenDown || lastX != x1 || lastY != y) {
      commands.add(DrawingCommand.moveTo(x1.toDouble(), y.toDouble()));
      commands.add(DrawingCommand.lineTo(x1.toDouble(), y.toDouble()));
    }
    commands.add(DrawingCommand.lineTo(x2.toDouble(), y.toDouble()));
  }

  bool _shouldDrawPixel(img.Image image, int x, int y) {
    return img.getLuminance(image.getPixel(x, y)) < 128;
  }

  img.Image scaleImage(img.Image image) {
    int scale = 200;
    return img.resize(
      image,
      width: (image.width >= image.height) ? scale : null,
      height: (image.height > image.width) ? scale : null,
      maintainAspect: true,
    );
  }

  Future<void> sendCommandsWithAck(
    List<DrawingCommand> commands,
    Socket? socket,
  ) async {
    if (socket == null) {
      connection(host, 228);
    }

    final stream = socket!.asBroadcastStream(); // Для чтения ответов
    try {
      for (int i = 0; i < commands.length; i++) {
        if (widget.stopped == true) {
          widget.stopped = false;
          break;
        }
        setState(() {
          widget.logLost.add('Отправка команды: ${commands[i].mode}');
        });
        socket.add(commands[i].toBytes());

        // Ждём подтверждения (байт `2`)
        await stream.firstWhere((data) => data.isNotEmpty && data.first == 2);
        setState(() {
          currentCommandIndex = i + 1;
          widget.logLost.add(
            'Подтверждение получено. Отправляю следующую команду...',
          );
        });
      }
      widget.logLost.add('Рисование завершено');
    } catch (e) {
      widget.logLost.add('Ошибка:');
    }
    socket.close();
  }
}
