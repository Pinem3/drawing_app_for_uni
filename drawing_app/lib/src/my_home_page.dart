import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'types.dart';
import 'drag_and_drop_widget.dart';
import 'package:image/image.dart' as img;

import 'dart:io';
import 'dart:convert';
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
  img.Image? _image;

  PanelLocation? dragStart;
  PanelLocation? dropPreview;
  String? hoveringData;
  void drop() {}

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
                                  var socket = await Socket.connect(
                                    '174.0.0.1',
                                    228,
                                    timeout: Duration(seconds: 5),
                                  );
                                  setState(() {
                                    connectivity = 'подключено';
                                  });
                                } catch (e) {
                                  setState(() {
                                    connectivity = 'ошибка подключения $e';
                                  });
                                }
                              },
                              icon: Icon(Icons.check),
                            ),
                            Text(connectivity),
                          ],
                        ),
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
      return Image.memory(Uint8List.fromList(img.encodePng(_image!)));
    }
    return Center(child: Text("Перетащите изображение сюда"));
  }
}
