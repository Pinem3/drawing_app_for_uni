import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:io';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String connectivity = 'Ожидание подключения';
  late Socket socket;

  final List<DropItem> _list = [];
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
                padding: EdgeInsetsGeometry.fromSTEB(20, 20, 0, 0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        alignment: AlignmentGeometry.directional(-1, 0),
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
                              onPressed: () {
                                setState(() {
                                  connectivity = 'подключено';
                                });
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
              DropTarget(
                onDragDone: (details) {
                  setState(() {
                    _list.addAll(details.files);
                  });
                },
                child: Container(
                  alignment: AlignmentGeometry.directional(0, 0),
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.inversePrimary),
                  child: Stack(children: [Center(child: Text('Перетащите изображение сюда'))]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
