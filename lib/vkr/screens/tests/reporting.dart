import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:parkinson/vkr/models/person.dart';
import 'package:parkinson/vkr/screens/_requestSend.dart';
import 'package:parkinson/vkr/ui/awesomeDialog.dart';

import '_common.dart';

class ReportTestScreen extends StatefulWidget {
  @override
  _ReportTestScreenState createState() => _ReportTestScreenState();
}

class _ReportTestScreenState extends State<ReportTestScreen> {
  late TextEditingController _controller;

  String lastString = '';
  bool resetTimer = true;
  DateTime time = DateTime.now();
  List<KeyNode> keys = [];
  Map<String, int> backspaces = {};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

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
            caption: 'Отчёт',
            description:
                'Опишите подробно Ваше самочувствие за последнее время',
            icon: Icons.article,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Тест'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        textTheme: TextTheme(
          headline6: TextStyle(color: Colors.black, fontSize: 24),
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            SizedBox(height: 20),
            Text(
              'Опишите подробно Ваше самочувствие',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
            Text(
              'Например, Ваше общее состояние за последнее время, отметьте какие-нибудь события',
              textAlign: TextAlign.center,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _controller,
                onChanged: (String s) {
                  if (resetTimer) {
                    lastString = s;
                    time = DateTime.now();
                    resetTimer = false;
                  } else {
                    if (s.length > lastString.length) {
                      for (int i = lastString.length; i < s.length; i++) {
                        String pair =
                            '${s[i - 1] == '\n' ? '^' : (s[i - 1] == ' ' ? '_' : s[i - 1])}${s[i] == '\n' ? '^' : (s[i] == ' ' ? '_' : s[i])}';
                        keys.add(KeyNode(
                            pair,
                            DateTime.now()
                                    .difference(time)
                                    .inMicroseconds
                                    .toDouble() /
                                1000000));
                      }
                    } else if (s.length < lastString.length) {
                      for (int i = lastString.length - 1; i >= s.length; i--) {
                        backspaces['\"${lastString[i]}\"'] =
                            (backspaces['\"${lastString[i]}\"'] == null)
                                ? 1
                                : backspaces['\"${lastString[i]}\"']! + 1;
                      }
                      if (s.length == 0) {
                        resetTimer = true;
                        backspaces.clear();
                        keys.clear();
                      }
                    }
                    lastString = s;
                    time = DateTime.now();
                  }
                  setState(() => {});
                },
                maxLines: 15,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Опишите Ваше самочувствие',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
              child: Column(
                children: [
                  AnimatedButton(
                    text: _controller.text.isEmpty ? "Отмена" : "Отправить",
                    borderRadius: BorderRadius.circular(10),
                    color: _controller.text.isEmpty ? Colors.red : Colors.blue,
                    width: 250,
                    pressEvent: () {
                      if (_controller.text.isEmpty)
                        Navigator.of(context).pop();
                      else {
                        sendRequestPopup(context,
                            map: {
                              'phone': Person.phone ?? '',
                              'text': _controller.text.toString(),
                              'keys': keys.toString(),
                              'backspaces': backspaces.toString(),
                              'date': DateTime.now().toUtc().toString(),
                            },
                            path: 'testreport/phone',
                            title: "Отлично!",
                            descSaved:
                                "Тест пройден, результаты сохранены и будут отправлены при подключении к Wi-Fi!",
                            descSent: "Тест пройден, результаты отправлены!",
                            onDismiss: (_) {
                          Navigator.of(context).pop();
                        });
                      }
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
