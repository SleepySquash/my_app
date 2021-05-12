import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:my_app/vkr/models/mail.dart';
import 'package:my_app/vkr/models/person.dart';
import 'package:my_app/vkr/models/requests.dart';
import 'package:my_app/vkr/screens/_requestSend.dart';
import 'package:my_app/vkr/ui/awesomeDialog.dart';

import 'package:my_app/vkr/ui/button.dart';

class MailsScreen extends StatefulWidget {
  @override
  _MailsScreenState createState() => _MailsScreenState();
}

class _MailsScreenState extends State<MailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Состояния в ожидании')),
      body: Mails.nodes.isEmpty
          ? Center(child: Text('Пусто'))
          : ListView(
              shrinkWrap: true,
              children: Mails.nodes
                  .map(
                    (e) => ListTile(
                      title: Text(e.date.toString()),
                      subtitle: Text(e.flag),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            Mails.nodes.remove(e);
                          });
                          Mails.saveToPrefs();
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
