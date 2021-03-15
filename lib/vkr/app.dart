import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:my_app/vkr/models/person.dart' as models;
import 'package:my_app/vkr/screens/home.dart';
import 'package:my_app/vkr/screens/login.dart';

import 'package:my_app/vkr/models/notifications.dart';
import 'package:my_app/vkr/models/bluetooth.dart';
import 'package:my_app/vkr/models/events.dart';

void myMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  Notifications.init();
  Bluetooth.loadFromPrefs();
  Events.loadFromPrefs();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void load() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var string = preferences.getString('person');
    if (string != null) {
      Map map = json.decode(string);
      models.Person.fromJson(map);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      title: "VKR",
      initialRoute: '/home',
      routes: {
        '/home': (context) => HomeScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}
