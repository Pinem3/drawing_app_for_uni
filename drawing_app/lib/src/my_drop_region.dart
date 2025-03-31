import 'package:flutter/material.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'types.dart';
import 'dart:convert';

class MyDropRegion extends StatefulWidget {
  const MyDropRegion({
    super.key,
    required this.childSize,
    required this.columns,
    required this.panel,
    required this.updateDropPreview,
    required this.child,
    required this.onDrop,
    required this.setExternalData,
  });

  final Size childSize;
  final int columns;
  final Panel panel;
  final void Function(PanelLocation) updateDropPreview;
  final Widget child;
  final VoidCallback onDrop;
  final void Function(String) setExternalData;

  @override
  State<MyDropRegion> createState() => _MyDropRegionState();
}

class _MyDropRegionState extends State<MyDropRegion> {
  int? dropIndex;
  @override
  Widget build(BuildContext context) {
    return DropRegion(
      formats: [Formats.png, Formats.jpeg],
      onDropOver: (DropOverEvent event) {
        _updatePreview(event.position.local);
        return DropOperation.copy;
      },
      onPerformDrop: (PerformDropEvent event) async {
        widget.onDrop;
      },
      onDropEnter: (DropEvent event) {
        if (event.session.items.first.dataReader != null) {
          final dataReader = event.session.items.first.dataReader!;
          if (!dataReader.canProvide(Formats.plainTextFile)) {
            return;
          }
          dataReader.getFile(Formats.png, (value) async {
            widget.setExternalData(utf8.decode(await value.readAll()));
          });
        }
      },
      child: widget.child,
    );
  }

  void _updatePreview(Offset hoverPosition) {
    final int row = hoverPosition.dy ~/ widget.childSize.height;
    final int column =
        (hoverPosition.dx - (widget.childSize.width / 2)) ~/
        widget.childSize.width;
    int newDropIndex = (row * widget.columns) + column;

    if (newDropIndex != dropIndex) {
      dropIndex = newDropIndex;
      widget.updateDropPreview((dropIndex!, widget.panel));
    }
  }
}
