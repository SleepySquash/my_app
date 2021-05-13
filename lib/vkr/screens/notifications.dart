import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkinson/vkr/models/events.dart';
import 'package:parkinson/vkr/models/placeNotifications.dart';
import 'package:parkinson/vkr/ui/awesomeDialog.dart';
import 'package:numberpicker/numberpicker.dart';

import 'package:parkinson/vkr/models/bluetooth.dart';
import 'bluetooth.dart';

class NotificationsAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: NotificationsScreen.color,
      title: Text('События'),
      actions: [
        IconButton(
          icon: Icon(
            Icons.bluetooth,
            color: Bluetooth.connected ? Colors.green : Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => BluetoothScreen()));
          },
        ),
      ],
    );
  }
}

class NotificationsScreen extends StatefulWidget {
  static Color color = Colors.blue;

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Bluetooth.events.length == 0 && Events.events.length == 0
          ? Center(child: Text('Событий нет'))
          : ListView(
              children: Bluetooth.events
                  .map(
                    (e) => ListTile(
                      title: Text("Приём лекарств",
                          style: TextStyle(fontSize: 20)),
                      subtitle: Text(
                          "Каждый день в ${DateFormat("Hm").format(e.when!)}, '${convertIndexToSector(e.index!)}', открыто ${e.repeatedMinutes} мин",
                          style: TextStyle(fontSize: 16)),
                      leading: Icon(Icons.medical_services, size: 40),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, size: 40),
                        padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                        onPressed: () {
                          awesomeDialogQuestion(
                            context,
                            'Удаление',
                            'Удалить событие?',
                            () {
                              setState(() {
                                Bluetooth.events.remove(e);
                              });
                              Bluetooth.saveToPrefs();
                              placeNotifications();
                              Bluetooth.sendBluetoothEvents();
                            },
                          );
                        },
                      ),
                    ),
                  )
                  .toList()
                    ..addAll(Events.events
                        .map(
                          (e) => ListTile(
                            title: Text(
                              e.type == MyEventType.report
                                  ? 'Проверка состояния'
                                  : (e.type == MyEventType.tests
                                      ? 'Выполнить тесты'
                                      : (e.type == MyEventType.doctor
                                          ? 'Посещение врача'
                                          : 'Событие')),
                              style: TextStyle(
                                fontSize: 20,
                                color: (e.type == MyEventType.doctor
                                    ? (DateTime.now()
                                                .difference(e.time!)
                                                .inMinutes >=
                                            0
                                        ? Colors.red
                                        : Colors.black)
                                    : Colors.black),
                              ),
                            ),
                            subtitle: Text(
                                e.type == MyEventType.report
                                    ? 'Каждый день в ${DateFormat("Hm").format(e.time!)}'
                                    : (e.type == MyEventType.tests
                                        ? 'Каждый день в ${DateFormat("Hm").format(e.time!)}'
                                        : (e.type == MyEventType.doctor
                                            ? '${DateFormat("dd.MM.yyyy").format(e.time!)} в ${DateFormat("Hm").format(e.time!)}'
                                            : 'Неизвестно')),
                                style: TextStyle(fontSize: 16)),
                            leading: Icon(
                              e.type == MyEventType.report
                                  ? Icons.report
                                  : (e.type == MyEventType.tests
                                      ? Icons.add_box
                                      : (e.type == MyEventType.doctor
                                          ? Icons.meeting_room
                                          : Icons.event)),
                              size: 40,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, size: 40),
                              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              onPressed: () {
                                awesomeDialogQuestion(
                                  context,
                                  'Удаление',
                                  'Удалить событие?',
                                  () {
                                    setState(() {
                                      Events.events.remove(e);
                                    });
                                    Events.saveToPrefs();
                                    placeNotifications();
                                  },
                                );
                              },
                            ),
                          ),
                        )
                        .toList()),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
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
              child: EventSelector(
                onClose: () {
                  setState(() {
                    dialog?.dissmiss();
                  });
                },
                onCreate: (String type) {
                  dialog?.dissmiss();
                  AwesomeDialog(
                      context: context,
                      width: 450,
                      dialogType: DialogType.ERROR,
                      headerAnimationLoop: false,
                      title: 'Ошибка',
                      desc: 'Отправка состояния пока что не поддерживается.',
                      btnOkOnPress: () {},
                      btnOkText: 'Понятно',
                      btnOkIcon: Icons.cancel,
                      btnOkColor: Colors.red)
                    ..show();
                },
              ),
            ),
          )..show();
        },
      ),
    );
  }
}

class EventSelector extends StatefulWidget {
  final Function? onClose;
  final Function(String type)? onCreate;
  EventSelector({this.onClose, this.onCreate});

  @override
  _EventSelectorState createState() => _EventSelectorState();
}

class _EventSelectorState extends State<EventSelector> {
  String dropdownValue = 'Приём лекарств';
  bool dataValidated = false;

  DateTime? medicineTime;
  int? medicineRepeat;
  String sectorDropdown = "День";

  DateTime? reportTime;
  DateTime? testsTime;

  String doctorRemind = 'За 2 часа до';
  DateTime? doctorTime;

  void validateData() {
    if (dropdownValue == 'Приём лекарств')
      dataValidated = medicineTime != null && medicineRepeat != null;
    else if (dropdownValue == 'Проверка состояния')
      dataValidated = reportTime != null;
    else if (dropdownValue == 'Выполнить тесты')
      dataValidated = testsTime != null;
    else if (dropdownValue == 'Посещение врача')
      dataValidated = doctorTime != null;
  }

  @override
  Widget build(BuildContext context) {
    Widget _medicineLayout = Column(
      children: [
        SizedBox(height: 10),
        Text(
          'Время приёма лекарства',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 5),
        AnimatedButton(
          text: medicineTime == null
              ? 'Выбрать время'
              : 'Каждый день в ${DateFormat("Hm").format(medicineTime!)}',
          width: 250,
          color: Colors.cyan,
          pressEvent: () async {
            TimeOfDay? selectedTime = await showTimePicker(
              initialTime: TimeOfDay.now(),
              context: context,
            );
            if (selectedTime != null) {
              DateTime now = DateTime.now();
              setState(() {
                medicineTime = DateTime(now.year, now.month, now.day,
                    selectedTime.hour, selectedTime.minute, 0);
              });
              validateData();
            }
          },
        ),
        SizedBox(height: 10),
        Text(
          'Допустимая длительность приёма*',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 5),
        AnimatedButton(
          text: medicineRepeat == null
              ? 'Выбрать время'
              : '$medicineRepeat минут(ы)',
          width: 250,
          color: Colors.cyan,
          pressEvent: () async {
            int? minutes = await showDialog<int>(
              context: context,
              builder: (BuildContext context) {
                return new NumberPickerDialog.integer(
                  minValue: 1,
                  maxValue: 60,
                  title: new Text("Допустимая длительность приёма (мин)"),
                  initialIntegerValue: 30,
                );
              },
            );
            if (minutes != null) {
              setState(() {
                medicineRepeat = minutes;
              });
              validateData();
            }
          },
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Отсек*    ',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
            DropdownButton<String>(
              value: sectorDropdown,
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
                  sectorDropdown = newValue!;
                });
              },
              items: <String>[
                'Утро',
                'День',
                'Вечер',
                'Ночь',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ],
        ),
        SizedBox(height: 5),
        Text('* - при наличии Bluetooth модуля'),
      ],
    );
    Widget _reportLayout = Column(
      children: [
        SizedBox(height: 10),
        Text(
          'Время повторения события',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 5),
        AnimatedButton(
          text: reportTime == null
              ? 'Выбрать время'
              : 'Каждый день в ${DateFormat("Hm").format(reportTime!)}',
          width: 250,
          color: Colors.cyan,
          pressEvent: () async {
            TimeOfDay? selectedTime = await showTimePicker(
              initialTime: TimeOfDay.now(),
              context: context,
            );
            if (selectedTime != null) {
              DateTime now = DateTime.now();
              setState(() {
                reportTime = DateTime(now.year, now.month, now.day,
                    selectedTime.hour, selectedTime.minute, 0);
              });
              validateData();
            }
          },
        ),
      ],
    );
    Widget _testsLayout = Column(
      children: [
        SizedBox(height: 10),
        Text(
          'Время повторения события',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 5),
        AnimatedButton(
          text: testsTime == null
              ? 'Выбрать время'
              : 'Каждый день в ${DateFormat("Hm").format(testsTime!)}',
          width: 250,
          color: Colors.cyan,
          pressEvent: () async {
            TimeOfDay? selectedTime = await showTimePicker(
              initialTime: TimeOfDay.now(),
              context: context,
            );
            if (selectedTime != null) {
              DateTime now = DateTime.now();
              setState(() {
                testsTime = DateTime(now.year, now.month, now.day,
                    selectedTime.hour, selectedTime.minute, 0);
              });
              validateData();
            }
          },
        ),
      ],
    );
    Widget _doctorLayout = Column(
      children: [
        SizedBox(height: 10),
        Text(
          'Дата и время посещения',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
        SizedBox(height: 5),
        AnimatedButton(
          text: doctorTime == null
              ? 'Выбрать дату и время'
              : '${DateFormat("dd.MM.yyyy").format(doctorTime!)} в ${DateFormat("Hm").format(doctorTime!)}',
          width: 250,
          color: Colors.cyan,
          pressEvent: () async {
            DateTime? selectedDate = await showDatePicker(
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2050),
              context: context,
            );
            if (selectedDate != null) {
              TimeOfDay? selectedTime = await showTimePicker(
                initialTime: TimeOfDay.now(),
                context: context,
              );
              if (selectedTime != null) {
                setState(() {
                  doctorTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                      0);
                });
                validateData();
              }
            }
          },
        ),
        SizedBox(height: 10),
        Text(
          'Когда напомнить',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
        ),
        DropdownButton<String>(
          value: doctorRemind,
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
              doctorRemind = newValue!;
            });
          },
          items: <String>[
            'Во время события',
            'За 0.5 часа до',
            'За 1 час до',
            'За 2 часа до',
            'За 3 часа до',
            'За 4 часа до',
            'За 5 часов до',
            'За 6 часов до',
            'За сутки до',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );

    Widget _buildLayout() {
      if (dropdownValue == 'Приём лекарств')
        return _medicineLayout;
      else if (dropdownValue == 'Проверка состояния')
        return _reportLayout;
      else if (dropdownValue == 'Выполнить тесты')
        return _testsLayout;
      else if (dropdownValue == 'Посещение врача')
        return _doctorLayout;
      else
        return Center();
    }

    return Column(
      children: <Widget>[
        Text(
          'Тип события',
          textAlign: TextAlign.start,
          style: Theme.of(context).textTheme.headline6,
        ),
        DropdownButton<String>(
          value: dropdownValue,
          icon: const Icon(Icons.notification_important),
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
            validateData();
          },
          items: <String>[
            'Приём лекарств',
            'Проверка состояния',
            'Выполнить тесты',
            'Посещение врача',
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        _buildLayout(),
        SizedBox(height: 20),
        AnimatedButton(
          text: 'Создать',
          color: dataValidated ? Colors.green : Colors.grey,
          pressEvent: () {
            if (dataValidated) {
              if (dropdownValue == 'Приём лекарств') {
                DateTime now = DateTime.now();
                Bluetooth.events.add(
                  BluetoothEvent(
                    when: DateTime(now.year, now.month, now.day,
                        medicineTime!.hour, medicineTime!.minute, 0),
                    repeatedMinutes: medicineRepeat,
                    index: convertSectorToIndex(sectorDropdown),
                  ),
                );
                Bluetooth.saveToPrefs();
                Bluetooth.sendBluetoothEvents();
                placeNotifications();
              } else if (dropdownValue == 'Проверка состояния') {
                Events.events
                    .add(MyEvent(type: MyEventType.report, time: reportTime));
                Events.saveToPrefs();
                placeNotifications();
              } else if (dropdownValue == 'Выполнить тесты') {
                Events.events
                    .add(MyEvent(type: MyEventType.tests, time: testsTime));
                Events.saveToPrefs();
                placeNotifications();
              } else if (dropdownValue == 'Посещение врача') {
                Events.events.add(MyEvent(
                    type: MyEventType.doctor,
                    time: doctorTime,
                    remind: doctorRemind));
                Events.saveToPrefs();
                placeNotifications();
              }
              widget.onClose!();
            }
          },
        ),
        SizedBox(height: 10),
        AnimatedButton(
          text: 'Отмена',
          color: Colors.red,
          pressEvent: () {
            widget.onClose!();
          },
        )
      ],
    );
  }
}
