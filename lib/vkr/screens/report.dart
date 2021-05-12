import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/vkr/models/mail.dart';
import 'package:my_app/vkr/models/person.dart';
import 'package:my_app/vkr/screens/data.dart';
import 'package:my_app/vkr/ui/awesomeDialog.dart';
import 'package:my_app/vkr/ui/button.dart';
import 'package:my_app/vkr/screens/_requestSend.dart';

class ReportAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ReportScreen.color,
      title: Text('Отчёт'),
      actions: [
        IconButton(
          icon: Icon(
            Icons.web,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => DataScreen()));
          },
        ),
      ],
    );
  }
}

class ReportScreen extends StatefulWidget {
  static Color color = Colors.green;

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  void _diskineiaPopup(BuildContext context) {
    _whenPopup(context, 'Когда Вы испытали дискинезию?', (DateTime when) {
      sendRequestPopup(
        context,
        map: {
          'phone': Person.phone ?? '',
          'date': when.toUtc().toString(),
        },
        path: 'dyskinesia/phone',
      );
      Mails.add(MailNode(flag: 'D', date: when.toUtc()));
    });
  }

  void _medicinePopup(BuildContext context) {
    _whenPopup(context, 'Когда Вы приняли лекарства?', (DateTime when) {
      sendRequestPopup(
        context,
        map: {
          'phone': Person.phone ?? '',
          'date': when.toUtc().toString(),
        },
        path: 'medicine/phone',
      );
      Mails.add(MailNode(flag: 'X', date: when.toUtc()));
    });
  }

  DateTime? selectedDatetime;
  String selectedDropdown = '5 минут назад';
  void _whenPopup(
      BuildContext context, String question, Function(DateTime when)? onOk) {
    AwesomeDialog? dialog;
    dialog = AwesomeDialog(
        context: context,
        width: 450,
        animType: AnimType.SCALE,
        dialogType: DialogType.INFO,
        headerAnimationLoop: false,
        keyboardAware: true,
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: <Widget>[
                  Text(
                    question,
                    style: Theme.of(context).textTheme.headline5,
                    textAlign: TextAlign.center,
                  ),
                  DropdownButton<String>(
                    value: selectedDropdown,
                    icon: const Icon(Icons.calendar_today),
                    iconSize: 24,
                    elevation: 16,
                    style:
                        const TextStyle(color: Colors.deepPurple, fontSize: 20),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDropdown = newValue!;
                        selectedDatetime = null;
                      });
                    },
                    items: <String>[
                      'сейчас',
                      '5 минут назад',
                      '10 минут назад',
                      '15 минут назад',
                      '20 минут назад',
                      '25 минут назад',
                      '30 минут назад',
                      '40 минут назад',
                      '50 минут назад',
                      '1 час назад',
                      '1.5 часа назад',
                      '2 часа назад',
                      '3 часа назад',
                      '4 часа назад',
                      '5 часов назад',
                      '6 часов назад',
                      '7 часов назад',
                      '8 часов назад',
                      '9 часов назад',
                      '10 часов назад',
                      '11 часов назад',
                      '12 часов назад',
                      '18 часов назад',
                      '1 день назад',
                      '2 дня назад',
                      '3 дня назад',
                      '4 дня назад',
                      '5 дней назад',
                      '6 дней назад',
                      '7 дней назад',
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 5),
                  AnimatedButton(
                    text: selectedDatetime == null
                        ? 'Выбрать точные дату и время'
                        : '${DateFormat("dd.MM.yyyy").format(selectedDatetime!)} в ${DateFormat("Hm").format(selectedDatetime!)}',
                    width: 250,
                    color: Colors.cyan,
                    pressEvent: () async {
                      DateTime? selectedDate = await showDatePicker(
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2021),
                        lastDate: DateTime.now(),
                        context: context,
                      );
                      if (selectedDate != null) {
                        TimeOfDay? selectedTime = await showTimePicker(
                          initialTime: TimeOfDay.now(),
                          context: context,
                        );
                        if (selectedTime != null) {
                          setState(() {
                            selectedDatetime = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                selectedTime.hour,
                                selectedTime.minute,
                                0);
                          });
                        }
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  SizedBox(
                    height: 20,
                  ),
                  AnimatedButton(
                    text: 'Подтвердить',
                    pressEvent: () {
                      dialog?.dissmiss();

                      DateTime when;
                      if (selectedDatetime != null)
                        when = selectedDatetime!;
                      else {
                        switch (selectedDropdown) {
                          case '5 минут назад':
                            when =
                                DateTime.now().subtract(Duration(minutes: 5));
                            break;
                          case '10 минут назад':
                            when =
                                DateTime.now().subtract(Duration(minutes: 10));
                            break;
                          case '15 минут назад':
                            when =
                                DateTime.now().subtract(Duration(minutes: 15));
                            break;
                          case '20 минут назад':
                            when =
                                DateTime.now().subtract(Duration(minutes: 20));
                            break;
                          case '25 минут назад':
                            when =
                                DateTime.now().subtract(Duration(minutes: 25));
                            break;
                          case '30 минут назад':
                            when =
                                DateTime.now().subtract(Duration(minutes: 30));
                            break;
                          case '40 минут назад':
                            when =
                                DateTime.now().subtract(Duration(minutes: 40));
                            break;
                          case '50 минут назад':
                            when =
                                DateTime.now().subtract(Duration(minutes: 50));
                            break;
                          case '1 час назад':
                            when = DateTime.now().subtract(Duration(hours: 1));
                            break;
                          case '1.5 часа назад':
                            when = DateTime.now()
                                .subtract(Duration(hours: 1, minutes: 30));
                            break;
                          case '2 часа назад':
                            when = DateTime.now().subtract(Duration(hours: 2));
                            break;
                          case '3 часа назад':
                            when = DateTime.now().subtract(Duration(hours: 3));
                            break;
                          case '4 часа назад':
                            when = DateTime.now().subtract(Duration(hours: 4));
                            break;
                          case '5 часов назад':
                            when = DateTime.now().subtract(Duration(hours: 5));
                            break;
                          case '6 часов назад':
                            when = DateTime.now().subtract(Duration(hours: 6));
                            break;
                          case '7 часов назад':
                            when = DateTime.now().subtract(Duration(hours: 7));
                            break;
                          case '8 часов назад':
                            when = DateTime.now().subtract(Duration(hours: 8));
                            break;
                          case '9 часов назад':
                            when = DateTime.now().subtract(Duration(hours: 9));
                            break;
                          case '10 часов назад':
                            when = DateTime.now().subtract(Duration(hours: 10));
                            break;
                          case '11 часов назад':
                            when = DateTime.now().subtract(Duration(hours: 11));
                            break;
                          case '12 часов назад':
                            when = DateTime.now().subtract(Duration(hours: 12));
                            break;
                          case '18 часов назад':
                            when = DateTime.now().subtract(Duration(hours: 18));
                            break;
                          case '1 день назад':
                            when = DateTime.now().subtract(Duration(days: 1));
                            break;
                          case '2 дня назад':
                            when = DateTime.now().subtract(Duration(days: 2));
                            break;
                          case '3 дня назад':
                            when = DateTime.now().subtract(Duration(days: 3));
                            break;
                          case '4 дня назад':
                            when = DateTime.now().subtract(Duration(days: 4));
                            break;
                          case '5 дней назад':
                            when = DateTime.now().subtract(Duration(days: 5));
                            break;
                          case '6 дней назад':
                            when = DateTime.now().subtract(Duration(days: 6));
                            break;
                          case '7 дней назад':
                            when = DateTime.now().subtract(Duration(days: 7));
                            break;
                          default:
                            when = DateTime.now();
                        }
                      }
                      onOk!(when);
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  AnimatedButton(
                    text: 'Отмена',
                    color: Colors.red,
                    pressEvent: () {
                      dialog?.dissmiss();
                    },
                  ),
                ],
              );
            },
          ),
        ),
        onDissmissCallback: () {
          selectedDatetime = null;
          selectedDropdown = '5 минут назад';
        })
      ..show();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(height: 12),
          Center(
            child: Text(
              'Как Вы себя чувствуете?',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headline5!
                  .copyWith(color: Colors.black),
            ),
          ),
          SizedBox(height: 6),
          reportButton(
            color: Colors.green,
            text: 'Хорошо',
            tapCallback: () {
              sendRequestPopup(
                context,
                map: {
                  'phone': Person.phone ?? '',
                  'state': '+',
                  'date': DateTime.now().toUtc().toString(),
                },
                path: 'conditions/phone',
              );
              Mails.add(MailNode(flag: '+', date: DateTime.now().toUtc()));
            },
          ),
          SizedBox(height: 6),
          reportButton(
            color: Colors.blue,
            text: 'Нормально',
            tapCallback: () {
              sendRequestPopup(
                context,
                map: {
                  'phone': Person.phone ?? '',
                  'state': '~',
                  'date': DateTime.now().toUtc().toString(),
                },
                path: 'conditions/phone',
              );
              Mails.add(MailNode(flag: '~', date: DateTime.now().toUtc()));
            },
          ),
          SizedBox(height: 6),
          reportButton(
            color: Colors.red,
            text: 'Плохо',
            tapCallback: () {
              sendRequestPopup(
                context,
                map: {
                  'phone': Person.phone ?? '',
                  'state': '-',
                  'date': DateTime.now().toUtc().toString(),
                },
                path: 'conditions/phone',
              );
              Mails.add(MailNode(flag: '-', date: DateTime.now().toUtc()));
            },
          ),
          SizedBox(height: 12),
          SizedBox(height: 6),
          reportButton(
            color: Colors.orange,
            text: 'Лекарства приняты',
            tapCallback: () {
              awesomeDialogQuestion(
                  context, 'Лекарства', 'Вы приняли лекарства сейчас?', () {
                sendRequestPopup(
                  context,
                  map: {
                    'phone': Person.phone ?? '',
                    'date': DateTime.now().toUtc().toString(),
                  },
                  path: 'medicine/phone',
                );
                Mails.add(MailNode(flag: 'X', date: DateTime.now().toUtc()));
              }, onClose: () {
                _medicinePopup(context);
              });
            },
            trailing: true,
            trailingIcon: Icons.calendar_today_rounded,
            trailingOnPressed: () {
              _medicinePopup(context);
            },
          ),
          SizedBox(height: 6),
          reportButton(
            color: Colors.black,
            text: 'Дискинезия',
            tapCallback: () {
              awesomeDialogQuestion(
                  context, 'Дискинезия', 'Вы испытали дискинезию сейчас?', () {
                sendRequestPopup(
                  context,
                  map: {
                    'phone': Person.phone ?? '',
                    'date': DateTime.now().toUtc().toString(),
                  },
                  path: 'dyskinesia/phone',
                );
                Mails.add(MailNode(flag: 'D', date: DateTime.now().toUtc()));
              }, onClose: () {
                _diskineiaPopup(context);
              });
            },
            trailing: true,
            trailingIcon: Icons.calendar_today_rounded,
            trailingOnPressed: () {
              _diskineiaPopup(context);
            },
          ),
          SizedBox(height: 6),
        ],
      ),
    );
  }
}

class WhenHappenedWidget extends StatefulWidget {
  @override
  _WhenHappenedWidgetState createState() => _WhenHappenedWidgetState();
}

class _WhenHappenedWidgetState extends State<WhenHappenedWidget> {
  String dropdownValue = '5 минут назад';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.calendar_today),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple, fontSize: 20),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: <String>[
        'сейчас',
        '5 минут назад',
        '10 минут назад',
        '15 минут назад',
        '20 минут назад',
        '25 минут назад',
        '30 минут назад',
        '40 минут назад',
        '50 минут назад',
        '1 час назад',
        '1.5 часа назад',
        '2 часа назад',
        '3 часа назад',
        '4 часа назад',
        '5 часов назад',
        '6 часов назад',
        '7 часов назад',
        '8 часов назад',
        '9 часов назад',
        '10 часов назад',
        '11 часов назад',
        '12 часов назад',
        '18 часов назад',
        '1 день назад',
        '2 дня назад',
        '3 дня назад',
        '4 дня назад',
        '5 дней назад',
        '6 дней назад',
        '7 дней назад',
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
