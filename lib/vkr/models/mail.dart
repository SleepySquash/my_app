import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/yandex.dart';
import 'package:parkinson/vkr/models/person.dart';
import 'package:parkinson/vkr/models/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:convert';

enum MailSendRepeat { everyday, everyweek, everymonth, bycount }

class Mails {
  static List<MailNode> nodes = [];
  static DateTime lastSend = DateTime.now();
  static int byCount = 0;
  static MailSendRepeat repeat = MailSendRepeat.everyweek;

  static Map toJson() => {
        'nodes': nodes,
        'lastsend': lastSend.toString(),
        'repeat': repeat.index,
        'bycount': byCount
      };
  static void fromJson(Map json) {
    nodes = (json['nodes'] as List).map((i) => MailNode.fromJson(i)).toList();
    lastSend = json['lastsend'] == null
        ? DateTime.now()
        : DateTime.parse(json['lastsend']);
    repeat = json['repeat'] == null
        ? MailSendRepeat.everyweek
        : MailSendRepeat.values.elementAt(json['repeat'] as int);
    byCount = json['bycount'] as int;
  }

  static void add(MailNode node) {
    nodes.add(node);
    saveToPrefs();
  }

  static Future<void> trySending() async {
    if (Requests.connected) {
      bool weNeedToSend = (byCount != 0 && nodes.length >= byCount) ||
          (DateTime.now().difference(lastSend).inDays >= 1 &&
              repeat == MailSendRepeat.everyday) ||
          (DateTime.now().difference(lastSend).inDays >= 7 &&
              repeat == MailSendRepeat.everyweek) ||
          (DateTime.now().difference(lastSend).inDays >= 30 &&
              repeat == MailSendRepeat.everymonth);
      if (weNeedToSend) {
        print('we need to send');
        if (nodes.length == 0) return;

        String csv = 'Date,dayWeek,Time,Flag,Pill,Diskinezia\n';
        nodes.sort((a, b) => a.date.compareTo(b.date));
        for (var i = 0; i < nodes.length;) {
          String? state;
          bool pill = false;
          bool dis = false;
          int next = i + 1;

          bool done = false;
          for (int j = i; j < nodes.length && !done; j++) {
            if (nodes[j].flag == '+' ||
                nodes[j].flag == '~' ||
                nodes[j].flag == '-')
              state = nodes[j].flag;
            else if (nodes[j].flag == 'X')
              pill = true;
            else if (nodes[j].flag == 'D') dis = true;

            if (j + 1 < nodes.length) {
              done = DateFormat('dd.MM.yyyy H').format(nodes[j + 1].date) !=
                  DateFormat('dd.MM.yyyy H').format(nodes[i].date);
              if (done) next = j + 1;
            } else
              next = j + 1;
          }

          csv += '${DateFormat('dd.MM.yyyy').format(nodes[i].date)},';
          csv += '${DateFormat('EEEE').format(nodes[i].date)},';
          csv += '${DateFormat('H').format(nodes[i].date)},';
          csv += '${state != null ? state : ''},';
          csv += '${pill ? 'X' : ''},';
          csv += '${dis ? 'D' : ''}';
          csv += '\n';

          i = next;
        }
        print(csv);

        final path = (await getTemporaryDirectory()).path;
        String filename =
            '$path/${DateFormat('ddMMyy').format(DateTime.now())}.csv';
        var file = await File(filename).writeAsString(csv);

        final smtpServer = yandex('etu.parkinsonapp.0', 'caofjshdqyloulob');
        final message = Message()
          ..from = Address(
              'etu.parkinsonapp.0@yandex.ru', 'Бот из приложения ParkinsonApp')
          ..recipients.add('isaenko.nikita.7305@gmail.com')
          ..subject =
              'IDD ${Person.lName}${Person.fName![0]}${Person.mName![0]}'
          ..text = 'Отправлено из ParkinsonApp v0'
          ..attachments = [
            FileAttachment(file)..location = Location.attachment
          ];

        try {
          final sendReport = await send(message, smtpServer);
          print('Message sent: ' + sendReport.toString());
          lastSend = DateTime.now();
          nodes.clear();
          await saveToPrefs();
        } on MailerException catch (e) {
          print('Message not sent: $e');
        }
      }
    }
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
