// import 'package:flutter/material.dart';
// import 'package:super_drag_and_drop/super_drag_and_drop.dart';
// import 'package:image/image.dart' as img;
// import 'dart:io';
// import 'dart:typed_data';

// class DragAndDropImageWidget extends StatefulWidget {
//   const DragAndDropImageWidget({super.key});

//   @override
//   DragAndDropImageWidgetState createState() => DragAndDropImageWidgetState();
// }

// class DragAndDropImageWidgetState extends State<DragAndDropImageWidget> {
//   img.Image? _image;
//   String? _error;

//   @override
//   Widget build(BuildContext context) {
//     return DropRegion(
//       // Указываем, какие типы данных принимаем (файлы с изображениями)
//       formats: [Formats.png, Formats.jpeg],
//       onDropOver: (event) {
//         // Проверяем, есть ли среди данных файлы
//         final hasFiles = event.session.items.any(
//           (item) => item.canProvide(DataFormats.files),
//         );
//         return hasFiles ? DropOperation.copy : DropOperation.none;
//       },
//       onPerformDrop: (event) async {
//         try {
//           // Ищем первый элемент с файлами
//           final fileItem = event.session.items.firstWhere(
//             (item) => item.canProvide(DataFormats.files),
//             orElse:
//                 () => throw Exception("Нет файлов в перетаскиваемых данных"),
//           );

//           // Получаем файл
//           final file = await fileItem.getFile();
//           if (file == null) throw Exception("Не удалось получить файл");

//           // Читаем изображение
//           final bytes = await File(file.path).readAsBytes();
//           final image = img.decodeImage(bytes);
//           if (image == null) throw Exception("Неверный формат изображения");

//           setState(() {
//             _image = image;
//             _error = null;
//           });
//         } catch (e) {
//           setState(() => _error = "Ошибка: ${e.toString()}");
//         }
//       },
//       child: Container(
//         width: 300,
//         height: 300,
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: _buildContent(),
//       ),
//     );
//   }

//   Widget _buildContent() {
//     if (_error != null) {
//       return Center(child: Text(_error!, style: TextStyle(color: Colors.red)));
//     }
//     if (_image != null) {
//       // Отображаем декодированное изображение
//       return Image.memory(Uint8List.fromList(img.encodePng(_image!)));
//     }
//     return Center(child: Text("Перетащите изображение сюда"));
//   }
// }
