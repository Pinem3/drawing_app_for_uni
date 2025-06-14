import 'package:flutter/material.dart';

List<String> modes = ['Построчно', 'Змейкой', 'Контурно'];

class WorkPage extends StatefulWidget {
  const WorkPage({super.key});

  @override
  State<WorkPage> createState() => _WorkPageState();
}

class _WorkPageState extends State<WorkPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: buildBody());
  }

  Widget buildBody() {
    return Stack(
      children: [
        Row(
          children: [
            LeftMenu(),
            Expanded(child: Container(color: Colors.grey[200])),
          ],
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 480,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}

class LeftMenu extends StatefulWidget {
  const LeftMenu({super.key});

  @override
  State<LeftMenu> createState() => _LeftMenuState();
}

class _LeftMenuState extends State<LeftMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(border: Border(right: BorderSide())),
      child: Column(
        children: [
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                constraints: BoxConstraints(maxHeight: 30),
                border: UnderlineInputBorder(),
                hintText: "IP адрес (127.0.0.1)",
              ),
            ),
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                constraints: BoxConstraints(maxHeight: 30),
                border: UnderlineInputBorder(),
                hintText: "Порт (228)",
              ),
            ),
          ),
          SizedBox(height: 16),
          FilledButton(
            onPressed: () {},
            child: Text('Подключиться', style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 16),
          Container(height: 2, color: Colors.black),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              decoration: InputDecoration(
                constraints: BoxConstraints(maxHeight: 30),
                border: OutlineInputBorder(),
                hintText: "Плотность изображения",
                contentPadding: EdgeInsets.only(bottom: 4, left: 8),
              ),
            ),
          ),
          SizedBox(height: 16),
          DropdownMenu(
            dropdownMenuEntries: <DropdownMenuEntry<String>>[
              DropdownMenuEntry(value: 'Строка', label: 'Построчно'),
              DropdownMenuEntry(value: 'Зиг-загом', label: 'Зиг-загом'),
              DropdownMenuEntry(value: 'Сегментно', label: 'Сегментно'),
              DropdownMenuEntry(
                value: 'Зиг-заг с возвратом',
                label: 'Зиг-заг с возвратом',
              ),
            ],
            width: 260,
          ),
        ],
      ),
    );
  }
}
