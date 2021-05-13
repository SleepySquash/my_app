import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:parkinson/vkr/models/person.dart';

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
              child: ListView(
                children: [
                  TextFormField(
                    keyboardType: TextInputType.phone,
                    initialValue: Person.phone,
                    onChanged: (s) {
                      if (int.parse(s).toString() == s &&
                          s.length >= 11 &&
                          s.length <= 20) {
                        Person.saveToPrefs();
                      }
                    },
                    decoration: InputDecoration(
                      icon: Icon(Icons.phone),
                      labelText: 'Телефон',
                      hintText: 'Телефон',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    initialValue: Person.lName,
                    onChanged: (s) {
                      if (s.length > 0) {
                        Person.lName = s;
                        Person.saveToPrefs();
                      }
                    },
                    decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: 'Фамилия',
                      hintText: 'Фамилия',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    initialValue: Person.fName,
                    onChanged: (s) {
                      if (s.length > 0) {
                        Person.fName = s;
                        Person.saveToPrefs();
                      }
                    },
                    decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: 'Имя',
                      hintText: 'Имя',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32)),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    keyboardType: TextInputType.name,
                    initialValue: Person.mName,
                    onChanged: (s) {
                      if (s.length > 0) {
                        Person.mName = s;
                        Person.saveToPrefs();
                      }
                    },
                    decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      labelText: 'Отчество',
                      hintText: 'Отчество',
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
