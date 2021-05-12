import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
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
