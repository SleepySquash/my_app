import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:intl/intl.dart';
import 'package:parkinson/vkr/models/mail.dart';
import 'package:parkinson/vkr/models/notifications.dart';
import 'package:parkinson/vkr/models/person.dart';
import 'package:parkinson/vkr/models/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

class Bluetooth {
  static bool connected = false;
  static BluetoothDevice? device;
  static BluetoothService? service;
  static BluetoothCharacteristic? characteristic;

  static String? last;
  static DateTime? since;

  static bool hallEffect = false;
  static List<BluetoothEvent> events = [];

  static bool isConnected() {
    return connected;
  }

  static void fromJson(Map json) {
    events = (json['events'] as List)
        .map((i) => BluetoothEvent.fromJson(i))
        .toList();
  }

  static Map toJson() {
    return {'events': Bluetooth.events};
  }

  static void loadFromPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var string = preferences.getString('bluetooth');
    if (string != null) fromJson(json.decode(string));
  }

  static void saveToPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var string = json.encode(toJson());
    await preferences.setString('bluetooth', string);
  }

  static Future<void> searchAndConnect() async {
    await disposeIfNotConnected();
    if (!Bluetooth.connected) {
      Future.delayed(Duration.zero, () async {
        List<BluetoothDevice> devices =
            await FlutterBlue.instance.connectedDevices;
        for (BluetoothDevice d in devices) {
          if (d.name == "HMSoft" && Bluetooth.device == null) {
            Bluetooth.device = d;
            FlutterBlue.instance.stopScan();

            print("Already connected!");
            connectToDevice(d);
            break;
          }
        }
        print("FlutterBlue.instance.connectedDevices done");
      });
      FlutterBlue.instance.startScan(timeout: Duration(seconds: 1));
      FlutterBlue.instance.scanResults.listen((results) {
        for (ScanResult r in results) {
          if (r.device.name == "HMSoft" && Bluetooth.device == null) {
            Bluetooth.device = r.device;
            FlutterBlue.instance.stopScan();

            print('${r.device.name} found! rssi: ${r.rssi}');
            connectToDevice(r.device);
            break;
          }
        }
      });
    }
  }

  static void sendBluetoothEvents() {
    if (!Bluetooth.connected) return;
    String result = "";
    if (Bluetooth.events.length == 0) result = "e";
    for (BluetoothEvent e in Bluetooth.events)
      result +=
          "e${e.index}${e.when!.hour.toString().padLeft(2, '0')}${e.when!.minute.toString().padLeft(2, '0')}${e.repeatedMinutes.toString().padLeft(2, '0')}";
    result += "\n";
    Bluetooth.characteristic!.write(utf8.encode(result));
  }

  static Future<void> connectToDevice(BluetoothDevice device) async {
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
              if (string.startsWith("h0")) {
                Notifications.fire(
                  "Отсек '${convertIndexToSector(0)}'",
                  "Лекарства приняты",
                );
                Mails.add(MailNode(flag: 'X', date: DateTime.now()));
                Requests.send(new Request(
                  map: {
                    'phone': Person.phone ?? '',
                    'automated': 'true',
                    'sector': convertIndexToSector(0),
                    'date': DateTime.now().toUtc().toString(),
                  },
                  path: 'medicine/phone',
                ));
              } else if (string.startsWith("h1")) {
                Notifications.fire(
                  "Отсек '${convertIndexToSector(1)}'",
                  "Лекарства приняты",
                );
                Mails.add(MailNode(flag: 'X', date: DateTime.now()));
                Requests.send(new Request(
                  map: {
                    'phone': Person.phone ?? '',
                    'automated': 'true',
                    'sector': convertIndexToSector(1),
                    'date': DateTime.now().toUtc().toString(),
                  },
                  path: 'medicine/phone',
                ));
              } else if (string.startsWith("h2")) {
                Notifications.fire(
                  "Отсек '${convertIndexToSector(2)}'",
                  "Лекарства приняты",
                );
                Mails.add(MailNode(flag: 'X', date: DateTime.now()));
                Requests.send(new Request(
                  map: {
                    'phone': Person.phone ?? '',
                    'automated': 'true',
                    'sector': convertIndexToSector(2),
                    'date': DateTime.now().toUtc().toString(),
                  },
                  path: 'medicine/phone',
                ));
              } else if (string.startsWith("h3")) {
                Notifications.fire(
                  "Отсек '${convertIndexToSector(3)}'",
                  "Лекарства приняты",
                );
                Mails.add(MailNode(flag: 'X', date: DateTime.now()));
                Requests.send(new Request(
                  map: {
                    'phone': Person.phone ?? '',
                    'automated': 'true',
                    'sector': convertIndexToSector(3),
                    'date': DateTime.now().toUtc().toString(),
                  },
                  path: 'medicine/phone',
                ));
              } else if (string == "h1" || string == "h1\n") {
                Bluetooth.hallEffect = true;
              } else if (string == "e" || string == "e\n")
                sendBluetoothEvents();
              else if (string == "n" || string == "n\n")
                Notifications.fire("title", "plain body");
              else if (string == "s" || string == "s\n")
                Notifications.schedule(0, "test", "test +5 sec",
                    DateTime.now().add(Duration(seconds: 5)));
              Bluetooth.last = string;
              Bluetooth.since = now;
            }
          }
        });
        Bluetooth.connected = true;

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

  static Future<void> disposeIfNotConnected() async {
    if (!Bluetooth.connected) {
      if (Bluetooth.device != null) await Bluetooth.device!.disconnect();
      Bluetooth.device = null;
      Bluetooth.service = null;
      Bluetooth.characteristic = null;
      Bluetooth.connected = false;
      Bluetooth.last = null;
      FlutterBlue.BlowItUp();
    }
  }
}

class BluetoothEvent {
  BluetoothEvent({this.when, this.repeatedMinutes, this.index});

  DateTime? when;
  int? repeatedMinutes;
  int? index;

  Map toJson() => {
        'when': when.toString(),
        'repeatedMinutes': repeatedMinutes,
        'index': index,
      };
  BluetoothEvent.fromJson(Map json)
      : when = DateTime.parse(json['when']),
        repeatedMinutes = json['repeatedMinutes'],
        index = json['index'];
}

int convertSectorToIndex(String sector) {
  switch (sector) {
    case "Утро":
      return 0;
    case "Вечер":
      return 1;
    case "День":
      return 2;
    case "Ночь":
      return 3;
    default:
      return 0;
  }
}

String convertIndexToSector(int index) {
  switch (index) {
    case 0:
      return "Утро";
    case 1:
      return "Вечер";
    case 2:
      return "День";
    case 3:
      return "Ночь";
    default:
      return "Утро";
  }
}
