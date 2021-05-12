import 'package:my_app/vkr/models/person.dart';
import 'package:my_app/vkr/models/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

class Mails {
  static List<MailNode> nodes = [];

  static void fromJson(Map json) {
    nodes = (json['nodes'] as List).map((i) => MailNode.fromJson(i)).toList();
  }

  static Map toJson() => {'nodes': nodes};

  static void add(MailNode node) {
    nodes.add(node);
    saveToPrefs();
  }

  static Future<void> trySending() async {
    if (Requests.connected) {}
  }

  static Future<void> loadFromPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var string = preferences.getString('mails');
    if (string != null) fromJson(json.decode(string));
    await trySending();
  }

  static Future<void> saveToPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var string = json.encode(toJson());
    await preferences.setString('mails', string);
  }
}

class MailNode {
  final String flag;
  final DateTime date;

  MailNode({required this.flag, required this.date});

  Map toJson() => {
        'flag': flag,
        'date': date.toString(),
      };
  MailNode.fromJson(Map json)
      : flag = json['flag'],
        date = DateTime.parse(json['date']);
}
