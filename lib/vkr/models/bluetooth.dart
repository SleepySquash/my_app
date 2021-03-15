import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

class Bluetooth {
  static bool connected = false;
  static ScanResult? result;
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
  BluetoothEvent({this.when, this.repeatedMinutes});

  DateTime? when;
  int? repeatedMinutes;

  Map toJson() => {
        'when': when.toString(),
        'repeatedMinutes': repeatedMinutes,
      };
  BluetoothEvent.fromJson(Map json)
      : when = DateTime.parse(json['when']),
        repeatedMinutes = json['repeatedMinutes'];
}
