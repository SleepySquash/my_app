import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:parkinson/vkr/models/person.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? fName, lName, mName, phone;

  bool fnameValidated = false,
      lnameValidated = false,
      mnameValidated = false,
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
          padding: EdgeInsets.all(4.0),
          child: ListView(
            children: [
              Text(
                'Профиль',
                style: Theme.of(context).textTheme.headline4,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6),
              Text(
                'Заполните, пожалуйста, Ваши данные',
                style: Theme.of(context).textTheme.subtitle1,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.phone,
                onChanged: (String text) {
                  setState(() {
                    phoneValidated = text.length == 11;
                    phone = text;
                  });
                },
                decoration: InputDecoration(
                  icon: Icon(Icons.phone),
                  hintText: 'Телефон',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32)),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                onChanged: (String text) {
                  setState(() {
                    lnameValidated = text.length != 0;
                    lName = text;
                  });
                },
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Фамилия',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32)),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                onChanged: (String text) {
                  setState(() {
                    fnameValidated = text.length != 0;
                    fName = text;
                  });
                },
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Имя',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32)),
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                onChanged: (String text) {
                  setState(() {
                    mnameValidated = text.length != 0;
                    mName = text;
                  });
                },
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  icon: Icon(Icons.person),
                  hintText: 'Отчество',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32)),
                ),
              ),
              SizedBox(height: 24),
              Material(
                elevation: 5,
                color: (phoneValidated &&
                        fnameValidated &&
                        mnameValidated &&
                        lnameValidated)
                    ? Colors.blue
                    : Colors.grey,
                borderRadius: BorderRadius.circular(32),
                child: MaterialButton(
                  onPressed: (phoneValidated &&
                          fnameValidated &&
                          mnameValidated &&
                          lnameValidated)
                      ? () async {
                          Person.phone = phone;
                          Person.fName = fName;
                          Person.mName = mName;
                          Person.lName = lName;
                          await Person.saveToPrefs();
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
