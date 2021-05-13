import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:parkinson/vkr/models/mail.dart';
import 'package:parkinson/vkr/models/person.dart';
import 'package:parkinson/vkr/models/requests.dart';
import 'package:parkinson/vkr/screens/_requestSend.dart';
import 'package:parkinson/vkr/screens/mails.dart';
import 'package:parkinson/vkr/screens/requests.dart';
import 'package:parkinson/vkr/ui/awesomeDialog.dart';

import 'package:parkinson/vkr/ui/button.dart';

class DataScreen extends StatefulWidget {
  @override
  _DataScreenState createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  String mailPeriodDropdown = Mails.repeat == MailSendRepeat.bycount
      ? 'по количеству'
      : (Mails.repeat == MailSendRepeat.everyday
          ? 'раз в день'
          : (Mails.repeat == MailSendRepeat.everyweek
              ? 'раз в неделю'
              : 'раз в месяц'));

  @override
  void dispose() {
    Mails.trySending();
    Requests.trySending();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Данные')),
      body: ListView(
        children: [
          SizedBox(height: 15),
          CheckboxListTile(
            title: Text(
              'Передавать данные по сотовой сети',
              style:
                  Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 18),
            ),
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
              else if (b != null) {
                setState(() => RequestPreferences.allowMobile = b);
                RequestPreferences.saveToPrefs();
              }
            },
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    'Отправлять на почту',
                    style: Theme.of(context)
                        .textTheme
                        .subtitle1!
                        .copyWith(fontSize: 18),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: DropdownButton<String>(
                  value: mailPeriodDropdown,
                  icon: const Icon(Icons.calendar_today),
                  iconSize: 24,
                  elevation: 16,
                  style:
                      const TextStyle(color: Colors.deepPurple, fontSize: 18),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue == 'по количеству') {
                      AwesomeDialog? dialog;
                      dialog = AwesomeDialog(
                        context: context,
                        width: 450,
                        headerAnimationLoop: false,
                        dialogType: DialogType.QUESTION,
                        body: MailCountPickerWidget(onClose: (int? i) {
                          if (i != null) {
                            setState(() {
                              mailPeriodDropdown = newValue!;
                            });
                            Mails.repeat = MailSendRepeat.bycount;
                            Mails.byCount = i;
                            Mails.saveToPrefs();
                          }
                          dialog?.dissmiss();
                        }),
                      )..show();
                    } else {
                      setState(() {
                        mailPeriodDropdown = newValue!;
                      });
                      Mails.byCount = 0;
                      switch (mailPeriodDropdown) {
                        case 'раз в день':
                          Mails.repeat = MailSendRepeat.everyday;
                          break;
                        case 'раз в неделю':
                          Mails.repeat = MailSendRepeat.everyweek;
                          break;
                        case 'раз в месяц':
                          Mails.repeat = MailSendRepeat.everymonth;
                          break;
                      }
                      Mails.saveToPrefs();
                    }
                  },
                  items: <String>[
                    'раз в день',
                    'раз в неделю',
                    'раз в месяц',
                    'по количеству'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          if (Mails.repeat == MailSendRepeat.bycount)
            Text(
              '(каждые ${Mails.byCount} отметок)',
              textAlign: TextAlign.center,
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

class MailCountPickerWidget extends StatefulWidget {
  final Function(int?) onClose;

  MailCountPickerWidget({required this.onClose});

  @override
  _MailCountPickerWidgetState createState() => _MailCountPickerWidgetState();
}

class _MailCountPickerWidgetState extends State<MailCountPickerWidget> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            'По количеству',
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            'Пожалуйста, укажите, при каком количестве записей производить отправку',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            onChanged: (s) => setState(() => {}),
          ),
          SizedBox(height: 15),
          AnimatedButton(
            pressEvent: () {
              widget.onClose(_controller.text.isEmpty
                  ? null
                  : int.parse(_controller.text));
            },
            text: _controller.text.isEmpty ? 'Отмена' : 'Принять',
            color: _controller.text.isEmpty ? Colors.red : Colors.green,
          ),
        ],
      ),
    );
  }
}
