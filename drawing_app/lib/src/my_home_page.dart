import 'dart:ui';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'types.dart';
import 'package:image/image.dart' as img;
import 'dart:io';
import 'dart:typed_data';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String connectivity = 'Ожидание подключения';
  WebSocketChannel? socket;
  String? _error;
  String inputPath = '';
  img.Image? _image;
  bool normImage = false;
  bool isGray = false;
  bool isScaled = false;
  bool isParked = false;
  bool endLine = false;
  bool _isPainting = false;
  List<Offset> generatedPath = <Offset>[];
  PanelLocation? dragStart;
  PanelLocation? dropPreview;
  String? hoveringData;
  String parkingText = 'Выполнить парковку';
  int coord = 0;

  Uint8List int32bytes(int input) {
    return Uint8List(4)..buffer.asInt32List()[0] = input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: SafeArea(
        top: true,
        child: Align(
          alignment: AlignmentDirectional(0, 0),
          child: GridView(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            scrollDirection: Axis.vertical,
            children: [
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(20, 20, 0, 0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: AlignmentDirectional(-1, 0),
                        width: 400,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 20,
                          children: [
                            IconButton(
                              onPressed: () async {
                                try {
                                  setState(() {
                                    connectivity = 'ожидание подключения';
                                  });
                                  if (socket != null) {
                                    socket!.sink.close();
                                  }
                                  socket = WebSocketChannel.connect(
                                    Uri.parse('ws://127.0.0.1:228'),
                                  );
                                  socket!.stream.listen((response) {
                                    if (response[0] == 2) {
                                      endLine = false;
                                      coord++;
                                      putPath(socket!, generatedPath, coord);
                                    }
                                  });
                                  setState(() {
                                    connectivity = 'подключено';
                                  });
                                } catch (e) {
                                  setState(() {
                                    connectivity = 'ошибка подключения';
                                  });
                                }
                              },
                              icon: Icon(Icons.check),
                            ),
                            Text(connectivity),
                          ],
                        ),
                      ),
                      TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Введите путь к файлу',
                        ),
                        onSubmitted: (value) {
                          setState(() {
                            if (value.isNotEmpty) {
                              inputPath = value;
                              File file = File(inputPath);
                              var bytes = file.readAsBytesSync();
                              if (inputPath.contains('.jpg')) {
                                _image = img.decodeJpg(bytes);
                              } else if (inputPath.contains('.png')) {
                                _image = img.decodePng(bytes);
                              }
                            }
                            normImage = true;
                            isGray = false;
                            isScaled = false;
                          });
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            children: [
                              SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    convertToBlackAndWhite(_image!);
                                    isGray = true;
                                  });
                                },
                                child: Text('Преобразовать в серое'),
                              ),
                              SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    scaleImage(_image!);
                                  });
                                },
                                child: Text('Изменить разрмер изображения'),
                              ),
                              SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    coord++;
                                    generatedPath = generatePath(_image!);
                                  });
                                },
                                child: Text('Сгенерировать путь'),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: () {
                                  int input = 1;
                                  var j = int32bytes(input);
                                  try {
                                    setState(() {
                                      socket!.sink.add(j);
                                    });
                                  } catch (e) {
                                    setState(() {
                                      connectivity = 'Произошла ошибка:  $e';
                                    });
                                  }
                                },
                                child: Text(parkingText),
                              ),
                              SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    coord = 0;
                                    putPath(socket!, generatedPath, coord);
                                  });
                                },
                                child: Text('Выполнить путь'),
                              ),
                              SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    _isPainting = true;
                                    normImage = false;
                                  });
                                },
                                child: Text('Показать путь'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        color: Colors.grey[300],
                        child: Text(generatedPath.toString(), softWrap: true),
                      ),
                    ],
                  ),
                ),
              ),
              DropRegion(
                formats: Formats.standardFormats,
                onDropOver: (DropOverEvent event) {
                  return DropOperation.copy;
                },
                onPerformDrop: (PerformDropEvent event) async {
                  final item = event.session.items.first;

                  final reader = item.dataReader;
                  if (reader!.canProvide(Formats.png) || reader.canProvide(Formats.jpeg)) {
                    reader.getFile(Formats.png, (value) async {
                      final Stream<Uint8List> stream = value.getStream();
                      _image = Image.memory(await stream.first) as img.Image?;
                    });
                  }
                },
                child: Align(
                  alignment: AlignmentGeometry.directional(0, 0),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    child: _buildContent(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return Center(child: Text(_error!, style: TextStyle(color: Colors.red)));
    }
    if (normImage == true) {
      // Отображаем декодированное изображение
      return Image.memory(Uint8List.fromList(img.encodePng(_image!)), scale: 0.5);
    }
    if (_isPainting == true) {
      return CustomPainting(
        path: generatedPath,
        size: Size(_image!.width.toDouble(), _image!.height.toDouble()),
      );
    }
    return Center(child: Text("Перетащите изображение сюда"));
  }

  img.Image convertToBlackAndWhite(img.Image image) {
    return img.grayscale(image);
  }

  img.Image scaleImage(img.Image image) {
    return img.resize(
      image,
      width: (image.width >= image.height) ? 200 : null,
      height: (image.height > image.width) ? 200 : null,
      maintainAspect: true,
    );
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
    int left = 0;
    List<Offset> finalPath = [];
    for (int right = 1; right <= path.length - 1; right++) {
      if (right == path.length || path[right].dx - path[right - 1].dx != 1) {
        if (left == right - 1) {
          finalPath.add(path[left]);
          finalPath.add(path[left]);
        } else {
          finalPath.add(path[left]);
          finalPath.add(path[right - 1]);
        }
        left = right;
      }
    }
    return finalPath;
  }

  void putPath(WebSocketChannel socket, List<Offset> path, int coord) async {
    List<int> outList = [];
    List<double> coords = [];
    Uint8List val = Uint8List(8);
    if (coord < path.length) {
      if (coord % 2 == 0) {
        outList = int32bytes(256);
      } else {
        outList = int32bytes(255);
      }
      List<int> iVal = [];
      coords = [path[coord].dx, path[coord].dy];
      for (int j = 0; j < coords.length; j++) {
        val.buffer.asFloat64List()[0] = coords[j];
        iVal += val;
      }
      outList += iVal;
      socket.sink.add(outList.toString());
    } else {
      coord = 0;
      return;
    }
  }
}

// ignore: must_be_immutable
class CustomPainting extends StatelessWidget {
  List<Offset> path;
  Size size;
  CustomPainting({super.key, required this.path, required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: BWPicture(path: path, canvasSize: size));
  }
}

class BWPicture extends CustomPainter {
  List<Offset> path;
  Size canvasSize;
  BWPicture({required this.path, required this.canvasSize});
  final myPaint =
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = Colors.black;
  @override
  void paint(Canvas canvas, Size size) {
    size = canvasSize;
    canvas.drawRect(
      Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
      Paint()..color = Colors.white,
    );
    canvas.drawPoints(PointMode.points, path, myPaint);
    for (int i = 0; i < path.length; i += 2) {
      if (path[i].dy == path[i + 1].dy) {
        canvas.drawLine(path[i], path[i + 1], myPaint);
      } else {
        canvas.drawLine(path[i], Offset(canvasSize.width, path[i].dy), myPaint);
        i--;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) =>
      path != oldDelegate.path || size != oldDelegate.size;
}

extension on CustomPainter {
  Object get path => [];

  Object get size => Size.zero;
}
