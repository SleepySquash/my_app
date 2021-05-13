import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parkinson/vkr/models/bluetooth.dart';
import 'package:parkinson/vkr/models/events.dart';

import 'notifications.dart';

Future<void> placeNotifications() async {
  await Notifications.cancelAll();
  int i = 0;
  for (BluetoothEvent e in Bluetooth.events)
    Notifications.schedule(
      i++,
      "Пора принимать лекарства",
      "Отсек '${convertIndexToSector(e.index!)}', у вас ${e.repeatedMinutes} минут!",
      e.when!,
    );
  for (MyEvent e in Events.events) {
    switch (e.type) {
      case MyEventType.report:
        await Notifications.schedule(i++, "Напоминание отметить самочувствие",
            "Зайдите во вкладку 'Отчёт'", e.time!);
        break;
      case MyEventType.tests:
        await Notifications.schedule(i++, "Напоминание пройти тесты",
            "Зайдите во вкладку 'Тесты'", e.time!);
        break;
      case MyEventType.doctor:
        String when = 'Сейчас';
        DateTime time = e.time!;
        if (e.remind != null) {
          switch (e.remind) {
            case 'За 0.5 часа до':
              time = e.time!.subtract(Duration(minutes: 30));
              when = 'Через полчаса,';
              break;
            case 'За 1 час до':
              time = e.time!.subtract(Duration(hours: 1));
              when = 'Через час,';
              break;
            case 'За 2 часа до':
              time = e.time!.subtract(Duration(hours: 2));
              when = 'Через 2 часа,';
              break;
            case 'За 3 часа до':
              time = e.time!.subtract(Duration(hours: 3));
              when = 'Через 3 часа,';
              break;
            case 'За 4 часа до':
              time = e.time!.subtract(Duration(hours: 4));
              when = 'Через 4 часа,';
              break;
            case 'За 5 часов до':
              time = e.time!.subtract(Duration(hours: 5));
              when = 'Через 5 часов,';
              break;
            case 'За 6 часов до':
              time = e.time!.subtract(Duration(hours: 6));
              when = 'Через 6 часов,';
              break;
            case 'За сутки до':
              time = e.time!.subtract(Duration(days: 1));
              when = 'Завтра';
              break;
          }
          when += ' в ${DateFormat('HH:mm').format(e.time!)}';
        }
        await Notifications.once(
            i++, "Напоминание о походе к врачу", when, time);
        break;
    }
  }
}
