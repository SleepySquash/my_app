import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:parkinson/vkr/models/person.dart';
import 'package:parkinson/vkr/models/requests.dart';
import 'package:parkinson/vkr/screens/_requestSend.dart';
import 'package:parkinson/vkr/ui/awesomeDialog.dart';

import 'package:parkinson/vkr/ui/button.dart';

class RequestsScreen extends StatefulWidget {
  @override
  _RequestsScreenState createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Реквесты в ожидании')),
      body: Requests.info.isEmpty
          ? Center(child: Text('Пусто'))
          : ListView(
              shrinkWrap: true,
              children: Requests.info
                  .map(
                    (e) => ListTile(
                      title: Text(e.map.toString()),
                      subtitle: Text(e.path),
                      leading: IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () {
                            sendRequestPopup(
                              context,
                              map: e.map,
                              method: e.method,
                              path: e.path,
                              file: e.file,
                              save: false,
                              onDismiss: (sent) {
                                if (sent) {
                                  setState(() {
                                    Requests.info.remove(e);
                                  });
                                  Requests.saveToPrefs();
                                }
                              },
                            );
                          }),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            Requests.info.remove(e);
                          });
                          Requests.saveToPrefs();
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
