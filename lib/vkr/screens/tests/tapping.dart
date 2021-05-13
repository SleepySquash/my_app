import 'dart:async';
import 'dart:math';
import 'dart:core';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:parkinson/vkr/models/person.dart';
import 'package:parkinson/vkr/screens/_requestSend.dart';
import 'package:parkinson/vkr/ui/awesomeDialog.dart';

import '_common.dart';

class TappingTestScreen extends StatefulWidget {
  final int counts;
  final int milliseconds;

  TappingTestScreen({this.counts = 10, this.milliseconds = 0});

  @override
  _TappingTestScreenState createState() => _TappingTestScreenState();
}

class TappingNode {
  final double accuracy;
  final bool leftHand;
  final DateTime when = DateTime.now();
  TappingNode(this.accuracy, this.leftHand);
}

class _TappingTestScreenState extends State<TappingTestScreen> {
  bool leftOrRight = true;
  bool timeOrTaps = false;
  List<TappingNode> nodes = [];

  bool counting = false;
  DateTime? lastPress;
  DateTime startTime = DateTime.now();
  Duration leftDuration = Duration(), rightDuration = Duration();
  int milliseconds = 0;
  int count = 0, leftCount = 0, rightCount = 0, counts = 0;

  Timer? timer;

  @override
  void dispose() {
    if (timer != null) timer!.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    counts = widget.counts;
    milliseconds = widget.milliseconds;
    timeOrTaps = milliseconds > 0;

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
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
            caption: timeOrTaps
                ? 'Постукивание на время'
                : 'Постукивание на количество',
            description: timeOrTaps
                ? 'Тыкайте по центру крестика как можно больше раз за ${((milliseconds.toDouble()) / 1000).round()} секунд сначала левой, а затем правой рукой!'
                : 'Тыкайте по центру крестика сначала $counts раз левой, а затем правой рукой!',
            icon: Icons.dry,
            onCancel: () {
              dialog?.dissmiss();
              Navigator.of(context).pop();
            },
            onProceed: () {
              dialog?.dissmiss();
              startTime = DateTime.now();
              if (timeOrTaps) {
                counting = true;
                timer = Timer.periodic(Duration(milliseconds: 10), (t) {
                  if (counting &&
                      DateTime.now().difference(startTime).inMilliseconds >
                          milliseconds) {
                    _checkout();
                  }
                  setState(() {});
                });
              }
            },
          ),
        ),
      )..show();
    });
  }

  void _done() {
    double leftAccuracy = 0, rightAccuracy = 0;
    int l = 0, r = 0;
    for (var a in nodes) {
      if (a.leftHand) {
        leftAccuracy += a.accuracy;
        l++;
      } else {
        rightAccuracy += a.accuracy;
        r++;
      }
    }
    if (l != 0) leftAccuracy /= l;
    if (r != 0) rightAccuracy /= r;

    List<double> leftTimes = [];
    for (int i = 0; i < nodes.length; i++) {
      if (!nodes[i].leftHand) break;
      if (i == 0)
        leftTimes.add(0);
      else
        leftTimes.add(nodes[i]
                .when
                .difference(nodes[i - 1].when)
                .inMicroseconds
                .toDouble() /
            1000000);
    }

    List<double> rightTimes = [];
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].leftHand) continue;
      if (i == 0 || nodes[i - 1].leftHand)
        rightTimes.add(0);
      else
        rightTimes.add(nodes[i]
                .when
                .difference(nodes[i - 1].when)
                .inMicroseconds
                .toDouble() /
            1000000);
    }

    var map = {
      'phone': Person.phone ?? '',
      'left': {
        '\"count\"': '$leftCount',
        '\"accuracy\"': '$leftAccuracy',
        '\"duration\"': '${leftDuration.inMilliseconds}',
        '\"times\"': '${leftTimes.toString()}'
      }.toString(),
      'right': {
        '\"count\"': '$rightCount',
        '\"accuracy\"': '$rightAccuracy',
        '\"duration\"': '${rightDuration.inMilliseconds}',
        '\"times\"': '${rightTimes.toString()}'
      }.toString(),
      'date': DateTime.now().toUtc().toString(),
    };
    print(map);

    sendRequestPopup(context,
        map: {
          'phone': Person.phone ?? '',
          'left': {
            '\"count\"': '$leftCount',
            '\"accuracy\"': '$leftAccuracy',
            '\"duration\"': '${leftDuration.inMilliseconds}',
            '\"times\"': '${leftTimes.toString()}'
          }.toString(),
          'right': {
            '\"count\"': '$rightCount',
            '\"accuracy\"': '$rightAccuracy',
            '\"duration\"': '${rightDuration.inMilliseconds}',
            '\"times\"': '${rightTimes.toString()}'
          }.toString(),
          'date': DateTime.now().toUtc().toString(),
        },
        path: 'testtap/phone',
        title: "Отлично!",
        descSaved:
            "Тест пройден, результаты сохранены и будут отправлены при подключении к Wi-Fi!",
        descSent: "Тест пройден, результаты отправлены!", onDismiss: (_) {
      Navigator.of(context).pop();
    });
  }

  void _checkout() {
    if (leftOrRight) {
      leftOrRight = false;
      leftDuration = timeOrTaps
          ? Duration(milliseconds: milliseconds)
          : DateTime.now().difference(startTime);
      leftCount = count;
      count = 0;
      counting = false;
      awesomeDialogInfo(context, "Хорошо!", "Теперь правой рукой!",
          onPress: () {
        startTime = DateTime.now();
        counting = true;
      });
    } else {
      rightDuration = timeOrTaps
          ? Duration(milliseconds: milliseconds)
          : DateTime.now().difference(startTime);
      rightCount = count;
      print("left: $leftDuration, right: $rightDuration");
      counting = false;
      if (timer != null) timer!.cancel();
      _done();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text('Тест'),
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(color: Colors.black),
            textTheme: TextTheme(
              headline6: TextStyle(color: Colors.black, fontSize: 24),
            ),
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: SafeArea(
              child: Container(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        leftOrRight ? "Левой!" : "Правой!",
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(fontSize: 64),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                      Text(
                        timeOrTaps
                            ? (counting
                                ? 'Ещё ${((milliseconds / 1000 - DateTime.now().difference(startTime).inSeconds)).round()} секунд!'
                                : '...')
                            : "Ещё ${counts - count} раз!",
                        style: Theme.of(context)
                            .textTheme
                            .headline4!
                            .copyWith(fontSize: 36),
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            onTapDown: (details) {
              double biggest = sqrt(
                    pow(MediaQuery.of(context).size.width, 2) +
                        pow(MediaQuery.of(context).size.height, 2),
                  ) /
                  2;

              nodes.add(new TappingNode(
                  1.0 -
                      sqrt(
                            pow(
                                    (MediaQuery.of(context).size.width / 2) -
                                        details.globalPosition.dx,
                                    2) +
                                pow(
                                    (MediaQuery.of(context).size.height / 2) -
                                        details.globalPosition.dy,
                                    2),
                          ) /
                          biggest,
                  leftOrRight));
              setState(() {
                count++;
              });

              if (!timeOrTaps && count >= counts) _checkout();
            },
          ),
        ),
        IgnorePointer(
          child: Center(
            child: Icon(Icons.center_focus_weak_sharp, size: 200),
          ),
        )
      ],
    );
  }
}
