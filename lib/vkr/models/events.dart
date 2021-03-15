import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

enum MyEventType {
  report,
  tests,
  doctor,
}

class MyEvent {
  MyEventType type;
  DateTime? time;
  String? remind;

  MyEvent({required this.type, this.time, this.remind});

  static MyEventType getStatusFromString(String statusAsString) {
    for (MyEventType element in MyEventType.values) {
      if (element.toString() == statusAsString) {
        return element;
      }
    }
    return MyEventType.report;
  }

  Map toJson() => {
        'type': type.toString(),
        'time': time.toString(),
        'remind': remind,
      };
  MyEvent.fromJson(Map json)
      : type = getStatusFromString(json['type']),
        time = DateTime.parse(json['time']),
        remind = json['remind'];
}

class Events {
  static List<MyEvent> events = [];

  static void fromJson(Map json) {
    events = (json['events'] as List).map((i) => MyEvent.fromJson(i)).toList();
  }

  static Map toJson() {
    return {'events': events};
  }

  static void loadFromPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var string = preferences.getString('events');
    if (string != null) fromJson(json.decode(string));
  }

  static void saveToPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var string = json.encode(toJson());
    await preferences.setString('events', string);
  }
}
