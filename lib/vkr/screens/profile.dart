import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:my_app/vkr/models/person.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ProfileScreen.color,
      title: Text('Ваши данные'),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  static Color color = Colors.teal;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10),
            child: Text('Вы можете изменить Ваши данные в полях ниже'),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(30),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.name,
                    initialValue: Person.phone,
                    decoration: InputDecoration(
                      icon: Icon(Icons.phone),
                      labelText: 'Телефон',
                      hintText: 'Телефон',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
