import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

class KeyNode {
  final String pair;
  final double elapsed;
  KeyNode(this.pair, this.elapsed);
  @override
  String toString() => '{\"pair\": \"$pair\", \"elapsed\": $elapsed}';
}

class EventStarter extends StatelessWidget {
  final Function? onCancel;
  final Function? onProceed;

  final IconData? icon;
  final String caption, description;

  EventStarter(
      {this.onCancel,
      this.onProceed,
      this.icon,
      this.caption = "Тест",
      this.description = "Описание"});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(height: 5),
        Icon(
          icon ?? Icons.text_snippet,
          size: 64,
        ),
        SizedBox(height: 5),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline5,
          overflow: TextOverflow.fade,
          softWrap: false,
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Описание теста',
              textAlign: TextAlign.left,
              style: Theme.of(context)
                  .textTheme
                  .headline6!
                  .copyWith(decoration: TextDecoration.underline),
            ),
          ],
        ),
        SizedBox(height: 5),
        Text(
          description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.subtitle1!.copyWith(fontSize: 18),
        ),
        SizedBox(height: 20),
        AnimatedButton(
          borderRadius: BorderRadius.circular(10),
          width: 240,
          text: 'Начать',
          color: Colors.green,
          pressEvent: () {
            onProceed!();
          },
        ),
        SizedBox(height: 10),
        AnimatedButton(
          borderRadius: BorderRadius.circular(10),
          width: 240,
          text: 'Назад',
          color: Colors.red,
          pressEvent: () {
            onCancel!();
          },
        )
      ],
    );
  }
}
