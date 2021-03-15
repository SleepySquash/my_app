import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter/material.dart';

import 'package:my_app/vkr/models/bluetooth.dart';
import 'package:my_app/vkr/models/notifications.dart';

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
  void _connectToDevice(BluetoothDevice device) async {
    // try {
    await device.connect();
    List<BluetoothService> services = await device.discoverServices();
    if (services.length >= 1) {
      Bluetooth.service = services[0];
      if (services[0].characteristics.length >= 1) {
        Bluetooth.characteristic = services[0].characteristics[0];
        await services[0].characteristics[0].setNotifyValue(true);
        services[0].characteristics[0].value.listen((value) {
          print("Value read: $value");
          if (value.length > 0) {
            String string = String.fromCharCodes(value);
            DateTime now = DateTime.now();
            if (!(string == Bluetooth.last &&
                now.millisecondsSinceEpoch -
                        Bluetooth.since!.millisecondsSinceEpoch <
                    1000)) {
              if (string == "h0" || string == "h0\n") {
                setState(() {
                  Bluetooth.hallEffect = false;
                });
                Notifications.fire("Уведомление", "Лекарства приняты");
              } else if (string == "h1" || string == "h1\n") {
                setState(() {
                  Bluetooth.hallEffect = true;
                });
              } else if (string == "e" || string == "e\n")
                sendBluetoothEvents();
              else if (string == "n" || string == "n\n")
                Notifications.fire("title", "plain body");
              else if (string == "s" || string == "s\n")
                Notifications.schedule("test", "test +5 sec",
                    DateTime.now().add(Duration(seconds: 5)));
              Bluetooth.last = string;
              Bluetooth.since = now;
            }
          }
        });
        setState(() {
          Bluetooth.connected = true;
        });

        Future.delayed(Duration(milliseconds: 10), () {
          Bluetooth.characteristic!.write(utf8.encode(
              "t${DateFormat('yyyyMMddHHmmss').format(DateTime.now())}\n"));
        });
      }
    }
    /*} catch (e) {
      print("catched: $e");
      Bluetooth.result = null;
    }*/
  }

  @override
  void initState() {
    super.initState();

    if (!Bluetooth.connected) {
      Future.delayed(Duration.zero, () async {
        List<BluetoothDevice> devices =
            await FlutterBlue.instance.connectedDevices;
        for (BluetoothDevice d in devices) {
          if (d.name == "HMSoft" && Bluetooth.result == null) {
            Bluetooth.result = ScanResult(device: d, rssi: 0);
            FlutterBlue.instance.stopScan();

            print("Already connected!");
            _connectToDevice(d);
            break;
          }
        }
        print("FlutterBlue.instance.connectedDevices done");
      });
      FlutterBlue.instance.startScan(timeout: Duration(seconds: 1));
      FlutterBlue.instance.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.name == "HMSoft" && Bluetooth.result == null) {
            Bluetooth.result = r;
            FlutterBlue.instance.stopScan();

            print('${r.device.name} found! rssi: ${r.rssi}');
            _connectToDevice(r.device);
            break;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    if (!Bluetooth.connected) {
      if (Bluetooth.result != null) Bluetooth.result!.device.disconnect();
      Bluetooth.result = null;
      Bluetooth.service = null;
      Bluetooth.characteristic = null;
      Bluetooth.connected = false;
      Bluetooth.last = null;
      FlutterBlue.BlowItUp();
    }
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
            return Bluetooth.result == null
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
          stream: Bluetooth.result!.device.state,
          initialData: BluetoothDeviceState.connecting,
          builder: (c, snapshot) {
            switch (snapshot.data) {
              case BluetoothDeviceState.connected:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Подключено к HM-10!'),
                    Text('Имя: ${Bluetooth.result!.device.name}'),
                    Text('RSSI: ${Bluetooth.result!.rssi}'),
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
                Bluetooth.result = null;
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

void sendBluetoothEvents() {
  if (!Bluetooth.connected) return;

  String result = "";
  if (Bluetooth.events.length == 0) result = "e";
  for (BluetoothEvent e in Bluetooth.events)
    result +=
        "e${e.when!.hour.toString().padLeft(2, '0')}${e.when!.minute.toString().padLeft(2, '0')}${e.repeatedMinutes.toString().padLeft(2, '0')}";
  result += "\n";
  Bluetooth.characteristic!.write(utf8.encode(result));

  Notifications.cancelAll();
  for (BluetoothEvent e in Bluetooth.events)
    Notifications.schedule("Событие", "Пора принимать лекарства", e.when!);
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
                      title: Text("Событие"),
                      subtitle: Text(
                          "${DateFormat("hh:mm").format(e.when!)} с периодом ${e.repeatedMinutes} мин"),
                      leading: Icon(Icons.event),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            Bluetooth.events.remove(e);
                          });
                          Bluetooth.saveToPrefs();
                          sendBluetoothEvents();
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
              DateTime now = DateTime.now();
              setState(() {
                Bluetooth.events.add(
                  BluetoothEvent(
                    when: DateTime(now.year, now.month, now.day,
                        selectedTime.hour, selectedTime.minute, 0),
                    repeatedMinutes: minutes,
                  ),
                );
              });
              Bluetooth.saveToPrefs();
              sendBluetoothEvents();
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
