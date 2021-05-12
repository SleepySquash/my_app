import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

void awesomeDialogQuestion(
    BuildContext context, String title, String description, Function? onOk,
    {Function? onClose}) {
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
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
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
              if (onClose != null) onClose();
            },
            text: 'Нет',
            color: Colors.red,
          ),
        ],
      ),
    ),
  )..show();
}

void awesomeDialogError(
    BuildContext context, String title, String description) {
  AwesomeDialog? dialog;
  dialog = AwesomeDialog(
    context: context,
    width: 450,
    headerAnimationLoop: false,
    dialogType: DialogType.ERROR,
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          AnimatedButton(
            pressEvent: () {
              dialog?.dissmiss();
            },
            text: 'Понятно',
            color: Colors.red,
          ),
        ],
      ),
    ),
  )..show();
}

void awesomeDialogInfo(BuildContext context, String title, String description,
    {Function? onPress, DialogType? dialogType}) {
  AwesomeDialog? dialog;
  dialog = AwesomeDialog(
    context: context,
    width: 450,
    headerAnimationLoop: false,
    dialogType: dialogType ?? DialogType.INFO,
    onDissmissCallback: () {
      onPress?.call();
    },
    body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline4,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            description,
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 15),
          AnimatedButton(
            pressEvent: () {
              dialog?.dissmiss();
            },
            text: 'Понятно',
            color: Colors.green,
          ),
        ],
      ),
    ),
  )..show();
}
