import 'package:flutter/material.dart';

class TestsAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: TestsScreen.color,
      title: Text('Тесты'),
    );
  }
}

class TestsScreen extends StatelessWidget {
  static Color color = Colors.cyan;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.looks, size: 44.0),
          title: Text('Постукивание', style: TextStyle(fontSize: 24)),
          subtitle: Text(
              'Тест на скорость постукивания по экрану правой и левой рукой',
              style: TextStyle(fontSize: 16)),
          trailing: Icon(Icons.arrow_right, size: 44),
          isThreeLine: true,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TestScreen(name: 'Постукивание'))),
        ),
        ListTile(
          leading: Icon(Icons.line_style, size: 44.0),
          title: Text('Текст', style: TextStyle(fontSize: 24)),
          subtitle: Text(
              'Тест скорость и точность печати текста на клавиатуре телефона',
              style: TextStyle(fontSize: 16)),
          trailing: Icon(Icons.arrow_right, size: 44),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TestScreen(name: 'Текст'))),
        ),
      ],
    );
  }
}

class TestScreen extends StatelessWidget {
  final String name;

  TestScreen({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(name),
      ),
    );
  }
}
