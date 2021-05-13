import 'dart:math';
import 'dart:ui';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:parkinson/vkr/models/person.dart';
import 'package:parkinson/vkr/screens/_requestSend.dart';
import 'package:parkinson/vkr/ui/awesomeDialog.dart';

import '_common.dart';

class DrawTestScreen extends StatefulWidget {
  @override
  _DrawTestScreenState createState() => _DrawTestScreenState();
}

enum MyFigureType { circle, square, triangle, ovalh, ovalv }

class _DrawTestScreenState extends State<DrawTestScreen> {
  MyFigureType figureType = MyFigureType.circle;

  var _offsets = <Offset?>[];
  int _offsetsStart = 0;

  double w = 0;
  double h = 0;
  double r = 0;
  double maxr = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      figureType =
          MyFigureType.values[Random().nextInt(MyFigureType.values.length)];
      // figureType = MyFigureType.triangle;
      w = MediaQuery.of(context).size.width;
      h = MediaQuery.of(context).size.height;
      r = w > h ? h / 3 : w / 3;
      maxr = r / 2;
      switch (figureType) {
        case MyFigureType.circle:
          double step = 2 * pi / 80;
          for (double theta = 0; theta < 2 * pi; theta += step) {
            var x = w / 2 + r * cos(theta);
            var y = h / 2 - r * sin(theta);
            _offsets.add(Offset(x, y));
          }
          _offsets.add(_offsets.first);
          break;

        case MyFigureType.ovalh:
          double step = 2 * pi / 80;
          for (double theta = 0; theta < 2 * pi; theta += step) {
            var x = w / 2 + 0.5 * r * cos(theta);
            var y = h / 2 - r * sin(theta);
            _offsets.add(Offset(x, y));
          }
          _offsets.add(_offsets.first);
          break;

        case MyFigureType.ovalv:
          double step = 2 * pi / 80;
          for (double theta = 0; theta < 2 * pi; theta += step) {
            var x = w / 2 + r * cos(theta);
            var y = h / 2 - 0.5 * r * sin(theta);
            _offsets.add(Offset(x, y));
          }
          _offsets.add(_offsets.first);
          break;

        case MyFigureType.square:
          _offsets.add(Offset(w / 2 - r, h / 2 - r));
          _offsets.add(Offset(w / 2 + r, h / 2 - r));
          _offsets.add(Offset(w / 2 + r, h / 2 + r));
          _offsets.add(Offset(w / 2 - r, h / 2 + r));
          _offsets.add(Offset(w / 2 - r, h / 2 - r));
          break;

        case MyFigureType.triangle:
          _offsets.add(Offset(w / 2 - r, h / 2 + r));
          _offsets.add(Offset(w / 2 + r, h / 2 + r));
          _offsets.add(Offset(w / 2, h / 2 - r));
          _offsets.add(Offset(w / 2 - r, h / 2 + r));
          _offsets.add(_offsets.first);
          break;
      }
      _offsets.add(null);
      setState(() {
        _offsetsStart = _offsets.length;
      });

      AwesomeDialog? dialog;
      dialog = AwesomeDialog(
        context: context,
        width: 650,
        animType: AnimType.RIGHSLIDE,
        dialogType: DialogType.NO_HEADER,
        headerAnimationLoop: false,
        keyboardAware: true,
        dismissOnTouchOutside: false,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: EventStarter(
            caption: 'Фигура',
            description: 'Обведите пальцем изображённую на экране фигуру',
            icon: Icons.circle,
            onCancel: () {
              dialog?.dissmiss();
              Navigator.of(context).pop();
            },
            onProceed: () {
              dialog?.dissmiss();
            },
          ),
        ),
      )..show();
    });
  }

  double calculateAccuracy() {
    if (_offsets.length - _offsetsStart <= 0) return 0;

    int points = 0;
    double accuracy = 0;

    for (int i = _offsetsStart; i < _offsets.length; i++) {
      if (_offsets[i] != null) {
        points++;

        Offset? closest;
        double closestDistance = double.maxFinite;
        for (int j = 1; j < _offsetsStart; j++) {
          if (_offsets[j - 1] != null && _offsets[j] != null) {
            double x1 = min(_offsets[j]!.dx, _offsets[j - 1]!.dx);
            double x2 = max(_offsets[j]!.dx, _offsets[j - 1]!.dx);
            double y1 = min(_offsets[j]!.dy, _offsets[j - 1]!.dy);
            double y2 = max(_offsets[j]!.dy, _offsets[j - 1]!.dy);
            double dx = x2 - x1;
            double dy = y2 - y1;

            double steps = (dx.abs() > dy.abs()) ? dx.abs() : dy.abs();
            double xinc = dx / steps;
            double yinc = dy / steps;

            double x = x1, y = y1;
            for (double s = 0; s < steps; s += 1) {
              double distance = sqrt(
                  pow(_offsets[i]!.dx - x, 2) + pow(_offsets[i]!.dy - y, 2));
              if (closestDistance > distance) {
                closestDistance = distance;
                closest = Offset(x, y);
              }
              x += xinc;
              y += yinc;
            }
          }
        }

        if (closest != null) {
          accuracy += 1.0 - closestDistance / maxr;
        }
      }
    }

    if (points == 0) return 0;
    return accuracy / points;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: (details) {
        setState(() {
          _offsets.add(details.localPosition);
        });
      },
      onPanUpdate: (details) {
        setState(() {
          _offsets.add(details.localPosition);
        });
      },
      onPanEnd: (details) {
        setState(() {
          _offsets.add(null);
        });
      },
      child: CustomPaint(
        foregroundPainter: MyPainter(_offsets, _offsetsStart),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Тест'),
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            textTheme: TextTheme(
              headline6: TextStyle(color: Colors.black, fontSize: 24),
            ),
          ),
          body: Center(
            child: Column(
              children: [
                Expanded(child: Text('')),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                  child: Column(
                    children: [
                      AnimatedButton(
                        text: "Готово",
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.green,
                        width: 250,
                        pressEvent: () {
                          sendRequestPopup(context,
                              map: {
                                'phone': Person.phone ?? '',
                                'accuracy': calculateAccuracy().toString(),
                                'figure': figureType
                                    .toString()
                                    .substring(
                                        figureType.toString().lastIndexOf('.'))
                                    .substring(1),
                                'date': DateTime.now().toUtc().toString(),
                              },
                              path: 'testfigure/phone',
                              title: "Отлично!",
                              descSaved:
                                  "Тест пройден, результаты сохранены и будут отправлены при подключении к Wi-Fi!",
                              descSent: "Тест пройден, результаты отправлены!",
                              onDismiss: (_) {
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final offsets;
  final offsetsStart;
  final paintobj = Paint()
    ..color = Colors.green
    ..isAntiAlias = true
    ..strokeWidth = 5.0;
  final beforeobj = Paint()
    ..color = Colors.grey.shade400
    ..isAntiAlias = true
    ..strokeWidth = 3.0;

  MyPainter(this.offsets, this.offsetsStart) : super();

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < offsets.length - 1; i++) {
      if (offsets[i] != null) {
        offsets[i + 1] == null
            ? canvas.drawPoints(PointMode.points, [offsets[i]],
                i >= offsetsStart ? paintobj : beforeobj)
            : canvas.drawLine(offsets[i], offsets[i + 1],
                i >= offsetsStart ? paintobj : beforeobj);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
