import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:parkinson/vkr/ui/awesomeDialog.dart';

class DoctorAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: DoctorScreen.color,
      title: Text('Врач'),
    );
  }
}

class DoctorScreen extends StatelessWidget {
  static Color color = Colors.red[800]!;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.mail, size: 40),
          title: Text('Отправить письмо в тех. поддержку',
              style: TextStyle(fontSize: 20)),
          onTap: () async {
            final Email email = Email(
              subject: 'Для тех. поддержки ParkinsonApp',
              recipients: ['etu.parkinsonapp.0@yandex.ru'],
              isHTML: false,
            );

            try {
              await FlutterEmailSender.send(email);
            } catch (e) {
              awesomeDialogInfo(
                  context, 'Не отправлено', 'Произошла ошибка: $e',
                  dialogType: DialogType.ERROR);
            }
          },
        ),
      ],
    );
  }
}
