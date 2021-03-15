/*import 'package:flutter/material.dart';

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
                  .headline5
                  .copyWith(color: Colors.black),
            ),
          ),
          SizedBox(height: 6),
          MyStyledButton(
            outerPadding: EdgeInsets.symmetric(horizontal: 20),
            innerPadding: EdgeInsets.fromLTRB(30, 30, 30, 30),
            color: Colors.green,
            callback: null,
            child: Text(
              'Хорошо',
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
          ),
          SizedBox(height: 6),
          MyStyledButton(
            outerPadding: EdgeInsets.symmetric(horizontal: 20),
            innerPadding: EdgeInsets.fromLTRB(30, 30, 30, 30),
            color: Colors.blue,
            callback: null,
            child: Text(
              'Нормально',
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
          ),
          SizedBox(height: 6),
          MyStyledButton(
            outerPadding: EdgeInsets.symmetric(horizontal: 20),
            innerPadding: EdgeInsets.fromLTRB(30, 30, 30, 30),
            color: Colors.red[800],
            callback: null,
            child: Text(
              'Плохо',
              style: TextStyle(fontSize: 28, color: Colors.white),
            ),
          ),
          SizedBox(height: 12),
          SizedBox(height: 6),
          MyStyledButton(
            outerPadding: EdgeInsets.symmetric(horizontal: 20),
            innerPadding: EdgeInsets.fromLTRB(30, 30, 30, 30),
            color: Colors.amber,
            callback: null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    'Лекарства приняты',
                    style: TextStyle(fontSize: 28, color: Colors.white),
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: null,
                )
              ],
            ),
          ),
          SizedBox(height: 6),
          reportButton(
            tapCallback: null,
            color: Colors.blue,
            trailing: true,
            trailingIcon: Icons.calendar_today_rounded,
            trailingOnPressed: null,
          ),
          SizedBox(height: 6),
          MyStyledButton(
            outerPadding: EdgeInsets.symmetric(horizontal: 20),
            innerPadding: EdgeInsets.fromLTRB(30, 30, 30, 30),
            color: Colors.black,
            callback: () {
              print('pressed');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: Text(
                    'Дискинезия              ',
                    style: TextStyle(fontSize: 28, color: Colors.white),
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
                IconButton(
                  padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                  icon: Icon(
                    Icons.calendar_today,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: () {
                    print("pressed icon");
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/
