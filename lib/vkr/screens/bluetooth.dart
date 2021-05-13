import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:parkinson/vkr/models/mail.dart';
import 'package:parkinson/vkr/models/person.dart';
import 'package:parkinson/vkr/models/placeNotifications.dart';
import 'package:parkinson/vkr/models/requests.dart';
import 'package:parkinson/vkr/screens/_requestSend.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';

import 'package:parkinson/vkr/models/bluetooth.dart';
import 'package:parkinson/vkr/models/notifications.dart';

class BluetoothScreen extends StatelessWidget {
  const BluetoothScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bluetooth")),
      body: Center(
        child: StreamBuilder<BluetoothState>(
          stream: FlutterBlue.instance.state,
          initialData: BluetoothState.unknown,
          builder: (c, snapshot) {
            final state = snapshot.data;
            if (state == BluetoothState.on) return BluetoothDeviceScreen();
            return BluetoothOffScreen(state: state!);
          },
        ),
      ),
    );
  }
}

class BluetoothDeviceScreen extends StatefulWidget {
  @override
  _BluetoothDeviceScreenState createState() => _BluetoothDeviceScreenState();
}

class _BluetoothDeviceScreenState extends State<BluetoothDeviceScreen> {
  @override
  void initState() {
    super.initState();
    Bluetooth.searchAndConnect();
  }

  @override
  void dispose() {
    super.dispose();
    Bluetooth.disposeIfNotConnected();
  }

  @override
  Widget build(BuildContext context) {
    if (!Bluetooth.isConnected()) {
      return StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: true,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return CircularProgressIndicator();
          } else {
            return Bluetooth.device == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Устройство HM-10 не найдено!'),
                      SizedBox(height: 6),
                      ElevatedButton(
                        child: Text('Повторить поиск'),
                        onPressed: () => FlutterBlue.instance
                            .startScan(timeout: Duration(seconds: 4)),
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Connecting...')
                    ],
                  );
          }
        },
      );
    } else
      return Center(
        child: StreamBuilder<BluetoothDeviceState>(
          stream: Bluetooth.device!.state,
          initialData: BluetoothDeviceState.connecting,
          builder: (c, snapshot) {
            switch (snapshot.data) {
              case BluetoothDeviceState.connected:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Подключено к HM-10!'),
                    Text('Имя: ${Bluetooth.device!.name}'),
                    SizedBox(height: 6),
                    Text("Отсек ${Bluetooth.hallEffect ? 'открыт' : 'закрыт'}"),
                    ElevatedButton(
                      onPressed: () async =>
                          await Bluetooth.characteristic!.write([87, 10]),
                      child: Text('Открыть'),
                    ),
                    ElevatedButton(
                      onPressed: () async =>
                          await Bluetooth.characteristic!.write([83, 10]),
                      child: Text('Закрыть'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (context) => EventsScreen())),
                      child: Text('Открыть события'),
                    ),
                  ],
                );
              case BluetoothDeviceState.connecting:
                return CircularProgressIndicator();
              default:
                Bluetooth.device = null;
                Bluetooth.service = null;
                Bluetooth.characteristic = null;
                Bluetooth.connected = false;
                Future.delayed(Duration.zero, () {
                  setState(() {});
                });
                return CircularProgressIndicator();
            }
          },
        ),
      );
  }
}

class EventsScreen extends StatefulWidget {
  @override
  _EventsScreenState createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Bluetooth.events.length == 0
          ? Center(child: Text('Событий нет'))
          : ListView(
              children: Bluetooth.events
                  .map(
                    (e) => ListTile(
                      title: Text("Событие на отсек №${e.index}"),
                      subtitle: Text(
                          "${DateFormat("hh:mm").format(e.when!)} с периодом ${e.repeatedMinutes} мин"),
                      leading: Icon(Icons.event),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            Bluetooth.events.remove(e);
                          });
                          placeNotifications();
                          Bluetooth.saveToPrefs();
                          Bluetooth.sendBluetoothEvents();
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          TimeOfDay? selectedTime = await showTimePicker(
            initialTime: TimeOfDay.now(),
            context: context,
          );
          if (selectedTime != null) {
            int? minutes = await showDialog<int>(
              context: context,
              builder: (BuildContext context) {
                return new NumberPickerDialog.integer(
                  minValue: 1,
                  maxValue: 60,
                  title: new Text("Продолжительность"),
                  initialIntegerValue: 30,
                );
              },
            );
            if (minutes != null) {
              int? index = await showDialog<int>(
                context: context,
                builder: (BuildContext context) {
                  return new NumberPickerDialog.integer(
                    minValue: 0,
                    maxValue: 3,
                    title: new Text("Индекс"),
                    initialIntegerValue: 0,
                  );
                },
              );
              if (index != null) {
                DateTime now = DateTime.now();
                setState(() {
                  Bluetooth.events.add(
                    BluetoothEvent(
                      when: DateTime(now.year, now.month, now.day,
                          selectedTime.hour, selectedTime.minute, 0),
                      repeatedMinutes: minutes,
                      index: index,
                    ),
                  );
                });
                placeNotifications();
                Bluetooth.saveToPrefs();
                Bluetooth.sendBluetoothEvents();
              }
            }
          }
        },
      ),
    );
  }
}

class BluetoothOffScreen extends StatelessWidget {
  const BluetoothOffScreen({Key? key, this.state}) : super(key: key);
  final BluetoothState? state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.bluetooth_disabled,
              size: 200.0,
              color: Colors.white54,
            ),
            Text(
              'Устройство Bluetooth ${state != null ? state.toString().substring(15) : 'недоступно'}.',
              style: Theme.of(context)
                  .primaryTextTheme
                  .subhead!
                  .copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
