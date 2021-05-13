import 'package:flutter/material.dart';
import 'package:parkinson/vkr/screens/tests/draw.dart';
import 'package:parkinson/vkr/screens/tests/reporting.dart';
import 'package:parkinson/vkr/screens/tests/tapping.dart';
import 'package:parkinson/vkr/screens/tests/textrepeat.dart';
import 'package:parkinson/vkr/screens/tests/voice.dart';

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
          leading: Icon(Icons.article, size: 44.0),
          title: Text('Самочувствие', style: TextStyle(fontSize: 24)),
          subtitle: Text('Напишите подробный отчёт о собственном самочувствии',
              style: TextStyle(fontSize: 16)),
          trailing: Icon(Icons.arrow_forward, size: 44),
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ReportTestScreen())),
        ),
        ListTile(
          leading: Icon(Icons.dry, size: 44.0),
          title: Text('Постукивание на количество',
              style: TextStyle(fontSize: 24)),
          subtitle: Text(
              'Тест на количество постукиваний по экрану правой и левой рукой',
              style: TextStyle(fontSize: 16)),
          trailing: Icon(Icons.arrow_forward, size: 44),
          isThreeLine: true,
          onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => TappingTestScreen())),
        ),
        ListTile(
          leading: Icon(Icons.dry_outlined, size: 44.0),
          title: Text('Постукивание на время', style: TextStyle(fontSize: 24)),
          subtitle: Text(
              'Тест на время постукиваний по экрану правой и левой рукой',
              style: TextStyle(fontSize: 16)),
          trailing: Icon(Icons.arrow_forward, size: 44),
          isThreeLine: true,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => TappingTestScreen(milliseconds: 5000))),
        ),
        ListTile(
          leading: Icon(Icons.line_style, size: 44.0),
          title: Text('Набрать текст', style: TextStyle(fontSize: 24)),
          subtitle: Text(
              'Тест на скорость и точность печати представленного текста',
              style: TextStyle(fontSize: 16)),
          trailing: Icon(Icons.arrow_forward, size: 44),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => TextTestScreen())),
        ),
        ListTile(
          leading: Icon(Icons.circle, size: 44.0),
          title: Text('Фигура', style: TextStyle(fontSize: 24)),
          subtitle: Text('Необходимо обвести изображённую на экране фигуру',
              style: TextStyle(fontSize: 16)),
          trailing: Icon(Icons.arrow_forward, size: 44),
          isThreeLine: true,
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => DrawTestScreen())),
        ),
        ListTile(
          leading: Icon(Icons.mic, size: 44.0),
          title: Text('Голос', style: TextStyle(fontSize: 24)),
          subtitle: Text('Опишите голосом Ваше самочувствие',
              style: TextStyle(fontSize: 16)),
          trailing: Icon(Icons.arrow_forward, size: 44),
          isThreeLine: true,
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => VoiceTestScreen())),
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
