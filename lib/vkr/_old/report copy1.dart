/*import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:my_app/vkr/ui/button.dart';

class ReportAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ReportScreen.color,
      title: Text('Отчёт'),
    );
  }
}

void awesomeDialogQuestion(BuildContext context, String title, Function? onOk) {
  AwesomeDialog? dialog;
  dialog = AwesomeDialog(
    context: context,
    width: 450,
    headerAnimationLoop: false,
    dialogType: DialogType.QUESTION,
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline5,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          AnimatedButton(
            pressEvent: () {
              dialog?.dissmiss();
              onOk!();
            },
            text: 'Да',
            color: Colors.green,
          ),
          SizedBox(height: 10),
          AnimatedButton(
            pressEvent: () {
              dialog?.dissmiss();
            },
            text: 'Нет',
            color: Colors.red,
          ),
        ],
      ),
    ),
  )..show();
}

class ReportScreen extends StatelessWidget {
  static Color color = Colors.green;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: [
          SizedBox(height: 12),
          Center(
            child: Text(
              'Как Вы себя чувствуете?',
              style: Theme.of(context)
                  .primaryTextTheme
                  .headline5!
                  .copyWith(color: Colors.black),
            ),
          ),
          SizedBox(height: 6),
          reportButton(
            color: Colors.green,
            text: 'Хорошо',
            tapCallback: () {
              AwesomeDialog(
                  context: context,
                  width: 450,
                  dialogType: DialogType.ERROR,
                  headerAnimationLoop: false,
                  title: 'Ошибка',
                  desc: 'Отправка состояния пока что не поддерживается.',
                  btnOkOnPress: () {},
                  btnOkText: 'Понятно',
                  btnOkIcon: Icons.cancel,
                  btnOkColor: Colors.red)
                ..show();
            },
          ),
          SizedBox(height: 6),
          reportButton(
            color: Colors.blue,
            text: 'Нормально',
            tapCallback: () {
              AwesomeDialog(
                  context: context,
                  width: 450,
                  dialogType: DialogType.ERROR,
                  headerAnimationLoop: false,
                  title: 'Ошибка',
                  desc: 'Отправка состояния пока что не поддерживается.',
                  btnOkOnPress: () {},
                  btnOkText: 'Понятно',
                  btnOkIcon: Icons.cancel,
                  btnOkColor: Colors.red)
                ..show();
            },
          ),
          SizedBox(height: 6),
          reportButton(
            color: Colors.red,
            text: 'Плохо',
            tapCallback: () {
              AwesomeDialog(
                  context: context,
                  width: 450,
                  dialogType: DialogType.ERROR,
                  headerAnimationLoop: false,
                  title: 'Ошибка',
                  desc: 'Отправка состояния пока что не поддерживается.',
                  btnOkOnPress: () {},
                  btnOkText: 'Понятно',
                  btnOkIcon: Icons.cancel,
                  btnOkColor: Colors.red)
                ..show();
            },
          ),
          SizedBox(height: 12),
          SizedBox(height: 6),
          reportButton(
            color: Colors.orange,
            text: 'Лекарства приняты',
            tapCallback: () {
              awesomeDialogQuestion(context, 'Вы приняли лекарства сейчас?',
                  () {
                AwesomeDialog(
                    context: context,
                    width: 450,
                    dialogType: DialogType.ERROR,
                    headerAnimationLoop: false,
                    title: 'Ошибка',
                    desc: 'Отправка состояния пока что не поддерживается.',
                    btnOkOnPress: () {},
                    btnOkText: 'Понятно',
                    btnOkIcon: Icons.cancel,
                    btnOkColor: Colors.red)
                  ..show();
              });
              /*AwesomeDialog(
                context: context,
                width: 450,
                headerAnimationLoop: false,
                dialogType: DialogType.QUESTION,
                title: 'Лекарства',
                desc: 'Вы приняли лекарства сейчас?',
                btnCancelText: 'Нет',
                btnCancelOnPress: () {},
                btnOkText: 'Да',
                btnOkOnPress: () {
                  AwesomeDialog(
                      context: context,
                      width: 450,
                      dialogType: DialogType.ERROR,
                      headerAnimationLoop: false,
                      title: 'Ошибка',
                      desc: 'Отправка состояния пока что не поддерживается.',
                      btnOkOnPress: () {},
                      btnOkText: 'Понятно',
                      btnOkIcon: Icons.cancel,
                      btnOkColor: Colors.red)
                    ..show();
                },
              )..show();*/
            },
            trailing: true,
            trailingIcon: Icons.calendar_today_rounded,
            trailingOnPressed: () {
              AwesomeDialog? dialog;
              dialog = AwesomeDialog(
                context: context,
                width: 450,
                animType: AnimType.SCALE,
                headerAnimationLoop: false,
                dialogType: DialogType.INFO,
                keyboardAware: true,
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Когда Вы приняли лекарства?',
                        style: Theme.of(context).textTheme.headline5,
                        textAlign: TextAlign.center,
                      ),
                      WhenHappenedWidget(),
                      SizedBox(
                        height: 20,
                      ),
                      AnimatedButton(
                        text: 'Подтвердить',
                        pressEvent: () {
                          dialog?.dissmiss();
                          AwesomeDialog(
                              context: context,
                              width: 450,
                              dialogType: DialogType.ERROR,
                              headerAnimationLoop: false,
                              title: 'Ошибка',
                              desc:
                                  'Отправка состояния пока что не поддерживается.',
                              btnOkOnPress: () {},
                              btnOkText: 'Понятно',
                              btnOkIcon: Icons.cancel,
                              btnOkColor: Colors.red)
                            ..show();
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      AnimatedButton(
                        text: 'Отмена',
                        color: Colors.red,
                        pressEvent: () {
                          dialog?.dissmiss();
                        },
                      ),
                    ],
                  ),
                ),
              )..show();
            },
          ),
          SizedBox(height: 6),
          reportButton(
            color: Colors.black,
            text: 'Дискинезия',
            tapCallback: () {
              AwesomeDialog(
                context: context,
                width: 450,
                headerAnimationLoop: false,
                dialogType: DialogType.QUESTION,
                title: 'Дискинезия',
                desc: 'Вы испытали дискинезию сейчас?',
                btnCancelText: 'Нет',
                btnCancelOnPress: () {},
                btnOkText: 'Да',
                btnOkOnPress: () {
                  AwesomeDialog(
                      context: context,
                      dialogType: DialogType.ERROR,
                      width: 450,
                      headerAnimationLoop: false,
                      title: 'Ошибка',
                      desc: 'Отправка состояния пока что не поддерживается.',
                      btnOkOnPress: () {},
                      btnOkText: 'Понятно',
                      btnOkIcon: Icons.cancel,
                      btnOkColor: Colors.red)
                    ..show();
                },
              )..show();
            },
            trailing: true,
            trailingIcon: Icons.calendar_today_rounded,
            trailingOnPressed: () {
              AwesomeDialog? dialog;
              dialog = AwesomeDialog(
                context: context,
                width: 450,
                animType: AnimType.SCALE,
                dialogType: DialogType.INFO,
                headerAnimationLoop: false,
                keyboardAware: true,
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Когда Вы испытали дискинезию?',
                        style: Theme.of(context).textTheme.headline5,
                        textAlign: TextAlign.center,
                      ),
                      WhenHappenedWidget(),
                      SizedBox(
                        height: 20,
                      ),
                      AnimatedButton(
                        text: 'Подтвердить',
                        pressEvent: () {
                          dialog?.dissmiss();
                          AwesomeDialog(
                              context: context,
                              width: 450,
                              dialogType: DialogType.ERROR,
                              headerAnimationLoop: false,
                              title: 'Ошибка',
                              desc:
                                  'Отправка состояния пока что не поддерживается.',
                              btnOkOnPress: () {},
                              btnOkText: 'Понятно',
                              btnOkIcon: Icons.cancel,
                              btnOkColor: Colors.red)
                            ..show();
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      AnimatedButton(
                        text: 'Отмена',
                        color: Colors.red,
                        pressEvent: () {
                          dialog?.dissmiss();
                        },
                      ),
                    ],
                  ),
                ),
              )..show();
            },
          ),
          SizedBox(height: 6),
        ],
      ),
    );
  }
}

class WhenHappenedWidget extends StatefulWidget {
  @override
  _WhenHappenedWidgetState createState() => _WhenHappenedWidgetState();
}

class _WhenHappenedWidgetState extends State<WhenHappenedWidget> {
  String dropdownValue = '5 минут назад';

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.calendar_today),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple, fontSize: 20),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? newValue) {
        setState(() {
          dropdownValue = newValue!;
        });
      },
      items: <String>[
        'сейчас',
        '5 минут назад',
        '10 минут назад',
        '15 минут назад',
        '20 минут назад',
        '25 минут назад',
        '30 минут назад',
        '40 минут назад',
        '50 минут назад',
        '1 час назад',
        '1.5 часа назад',
        '2 часа назад',
        '3 часа назад',
        '4 часа назад',
        '5 часов назад',
        '6 часов назад',
        '7 часов назад',
        '8 часов назад',
        '9 часов назад',
        '10 часов назад',
        '11 часов назад',
        '12 часов назад',
        '18 часов назад',
        '1 день назад',
        '2 дня назад',
        '3 дня назад',
        '4 дня назад',
        '5 дней назад',
        '6 дней назад',
        '7 дней назад',
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
*/
