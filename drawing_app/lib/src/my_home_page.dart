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
  late Socket socket;
  String? _error;
  String inputPath = '';
  img.Image? _image;
  bool isGray = false;
  bool isScaled = false;
  bool isParked = false;
  bool endLine = false;
  List<Offset> generatedPath = <Offset>[];
  PanelLocation? dragStart;
  PanelLocation? dropPreview;
  String? hoveringData;
  String parkingText = 'Вфполнить парковку';

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
                                  socket = await Socket.connect(
                                    '10.0.174.50',
                                    228,
                                    timeout: Duration(seconds: 5),
                                  );

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
                                    generatedPath = generatePath(_image!);
                                  });
                                },
                                child: Text('Сгенерировать путь'),
                              ),
                              SizedBox(height: 20.0),
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
                                      socket.add(j);
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
                                    for (
                                      int i = 0;
                                      i < generatedPath.length;
                                      i++
                                    ) {
                                      putPath(
                                        socket,
                                        generatedPath,
                                        endLine,
                                        i,
                                      );
                                    }
                                    socket.listen((List<int> data) {
                                      if (data[0] == 1) {
                                        setState(() {
                                          isParked = true;
                                          parkingText = 'Парковка выполнена';
                                        });
                                        if (data[0] == 2) {
                                          setState(() {
                                            endLine = false;
                                          });
                                        } else {
                                          endLine = true;
                                        }
                                      }
                                    });
                                  });
                                },
                                child: Text('Выполнить путь'),
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
                  if (reader!.canProvide(Formats.png) ||
                      reader.canProvide(Formats.jpeg)) {
                    reader.getFile(Formats.png, (value) async {
                      final Stream<Uint8List> stream = value.getStream();
                      _image = Image.memory(await stream.first) as img.Image?;
                    });
                  }
                },
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[300],
                  ),
                  child: _buildContent(),
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
    if (_image != null) {
      // Отображаем декодированное изображение
      return Image.memory(
        Uint8List.fromList(img.encodePng(_image!)),
        scale: 0.5,
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
      width: (image.width > image.height) ? 200 : null,
      height: (image.height > image.width) ? 200 : null,
      maintainAspect: true,
    );
  }

  List<Offset> generatePath(img.Image image) {
    final path = <Offset>[];
    double linesize = 1.0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        final luminance = img.getLuminance(pixel);
        if (luminance < 128) {
          path.add(Offset(x.toDouble(), y.toDouble()));
        }
      }
    }
    for (int i = 1; i < path.length - 1; i++) {
      if (path[i].dx - linesize == path[i - 1].dx &&
          path[i].dy == path[i + 1].dy) {
        path.removeAt(i);
        linesize++;
        i--;
      } else {
        linesize = 1;
      }
    }
    return path;
  }

  void putPath(Socket socket, List<Offset> path, bool endLine, int coord) {
    List<int> outList = [];
    List<double> coords = [];
    Uint8List val = Uint8List(8);
    List<int> iVal = [];
    endLine = false;
    if (endLine == false) {
      if (coord % 2 == 0) {
        outList = int32bytes(256);
      } else {
        outList = int32bytes(255);
      }
      coords = [path[coord].dx, path[coord].dy];
      for (int j = 0; j < coords.length; j++) {
        val.buffer.asFloat64List()[0] = coords[j];
        iVal += val;
      }
      outList += iVal;
      endLine = true;
      socket.add(outList);
    }
  }
}
