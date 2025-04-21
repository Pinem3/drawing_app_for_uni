import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class ImageDropRegion extends StatefulWidget {
  const ImageDropRegion({super.key, required this.setExternalData, required this.child});

  final Function(Uint8List, String) setExternalData;
  final Widget child;

  @override
  State<ImageDropRegion> createState() => _ImageDropRegionState();
}

class _ImageDropRegionState extends State<ImageDropRegion> {
  File? dropImage;
  bool _isDragging = false;

  Future<void> _handleDrop(PerformDropEvent event) async {
    final item = event.session.items.firstOrNull;
    if (item == null) return;

    final file = await _getImageFile(item);
    if (file == null) return;

    setState(() {
      dropImage = file;
      _isDragging = false;
    });
  }

  Future<File?> _getImageFile(DropItem item) async {
    // Проверяем тип содержимого
    if (item.dataReader != null) {
      final data = item.dataReader;
      if (data!.canProvide(Formats.png)) {
        data.getFile(Formats.png, (value) async {
          widget.setExternalData(await value.readAll(), 'png');
        });
      } else if (data.canProvide(Formats.jpeg)) {
        data.getFile(Formats.jpeg, (value) async {
          widget.setExternalData(await value.readAll(), 'jpg');
        });
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DropRegion(
          formats: [Formats.png, Formats.jpeg],
          onDropEnter:
              (_) => setState(() {
                _isDragging = true;
              }),
          onDropLeave:
              (_) => setState(() {
                _isDragging = false;
              }),
          onDropOver: (DropOverEvent event) {
            return DropOperation.copy;
          },
          onPerformDrop: _handleDrop,
          child: Container(
            foregroundDecoration: BoxDecoration(
              color: _isDragging ? Colors.blue.withAlpha(51) : null,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Widget child(File? file) {
    if (file == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 50, color: Colors.grey),
            SizedBox(height: 16),
            Text('Перетащите PNG/JPEG сюда', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    } else {
      return Image.file(file);
    }
  }
}
