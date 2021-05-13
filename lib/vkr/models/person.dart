import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Person {
  static String? phone;
  static String? fName, mName, lName;

  static Map toJson() => {
        'phone': Person.phone,
        'fName': Person.fName,
        'mName': Person.mName,
        'lName': Person.lName,
      };
  static void fromJson(Map json) {
    phone = json['phone'];
    fName = json['fName'];
    mName = json['mName'];
    lName = json['lName'];
  }

  static bool isLoggedIn() {
    if (Person.phone == null ||
        Person.fName == null ||
        Person.mName == null ||
        Person.lName == null) return false;
    return (Person.phone!.isNotEmpty && Person.phone!.length == 11);
  }

  static Future<void> loadFromPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var string = preferences.getString('person');
    if (string != null) fromJson(json.decode(string));
  }

  static Future<void> saveToPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var string = json.encode(toJson());
    await preferences.setString('person', string);
  }
}
