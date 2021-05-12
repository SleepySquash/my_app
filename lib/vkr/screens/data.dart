import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:my_app/vkr/models/mail.dart';
import 'package:my_app/vkr/models/person.dart';
import 'package:my_app/vkr/models/requests.dart';
import 'package:my_app/vkr/screens/_requestSend.dart';
import 'package:my_app/vkr/screens/mails.dart';
import 'package:my_app/vkr/screens/requests.dart';
import 'package:my_app/vkr/ui/awesomeDialog.dart';

import 'package:my_app/vkr/ui/button.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Данные')),
      body: ListView(
        children: [
          SizedBox(height: 15),
          CheckboxListTile(
            title: Text('Передавать данные по сотовой связи'),
            value: RequestPreferences.allowMobile,
            onChanged: (b) async {
              if (b != null && b)
                awesomeDialogQuestion(context, 'Вы уверены?',
                    'Использование сотовой сети может скушать трафик, оплачиваемый в соответствии с Вашим тарифом!',
                    () async {
                  setState(() => RequestPreferences.allowMobile = b);
                  RequestPreferences.saveToPrefs();

                  var connectivityResult =
                      await Connectivity().checkConnectivity();
                  Requests.connected =
                      connectivityResult == ConnectivityResult.wifi ||
                          (connectivityResult == ConnectivityResult.mobile &&
                              RequestPreferences.allowMobile);
                  if (Requests.connected) {
                    Requests.trySending();
                    Mails.trySending();
                  }
                });
              else if (b != null)
                setState(() => RequestPreferences.allowMobile = b);
            },
          ),
          SizedBox(height: 15),
          AnimatedButton(
            text: 'Список отправлений на почту',
            borderRadius: BorderRadius.horizontal(),
            pressEvent: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => MailsScreen()));
            },
          ),
          SizedBox(height: 5),
          AnimatedButton(
            text: 'Список отправлений на сервер',
            borderRadius: BorderRadius.horizontal(),
            pressEvent: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => RequestsScreen()));
            },
          )
        ],
      ),
    );
  }
}
