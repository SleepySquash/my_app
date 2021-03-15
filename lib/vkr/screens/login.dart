import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_app/vkr/models/person.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? firstname, lastname, number;
  DateTime? bday;

  TextEditingController fnameController = TextEditingController();
  TextEditingController lnameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool fnameValidated = false,
      lnameValidated = false,
      dateValidated = false,
      phoneValidated = false;

  @override
  Widget build(BuildContext context) {
    if (Person.isLoggedIn()) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/home');
      });
      return Center();
    }

    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(80),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Профиль', style: Theme.of(context).textTheme.headline4),
              SizedBox(height: 6),
              Text('Заполните, пожалуйста, Ваши данные',
                  style: Theme.of(context).textTheme.subtitle1),
              SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.phone,
                controller: phoneController,
                onChanged: (String text) {
                  setState(() {
                    phoneValidated = text.length == 11;
                  });
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.phone),
                  hintText: 'Телефон',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32)),
                ),
              ),
              SizedBox(height: 24),
              Material(
                elevation: 5,
                color: (phoneValidated) ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(32),
                child: MaterialButton(
                  onPressed: (phoneValidated)
                      ? () async {
                          SharedPreferences preferences =
                              await SharedPreferences.getInstance();
                          Person.phone = phoneController.text;
                          var string = json.encode(Person.toJson());
                          await preferences.setString('person', string);

                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      : null,
                  padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                  child: Center(
                    child: Text(
                      'Продолжить',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
