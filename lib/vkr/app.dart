import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:convert';

import 'package:my_app/vkr/models/person.dart' as models;
import 'package:my_app/vkr/screens/home.dart';
import 'package:my_app/vkr/screens/login.dart';

import 'package:my_app/vkr/models/notifications.dart';
import 'package:my_app/vkr/models/bluetooth.dart';
import 'package:my_app/vkr/models/events.dart';
import 'package:my_app/vkr/models/requests.dart';

import 'models/mail.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void myMain() async {
  HttpOverrides.global = new MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  Notifications.init();
  Bluetooth.loadFromPrefs();
  Events.loadFromPrefs();
  RequestPreferences.loadFromPrefs();
  Requests.loadFromPrefs();
  Mails.loadFromPrefs();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var subscription;

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

    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      bool prev = Requests.connected;
      Requests.connected = result == ConnectivityResult.wifi ||
          (result == ConnectivityResult.mobile &&
              RequestPreferences.allowMobile);
      if (!prev && Requests.connected) {
        Requests.trySending();
        Mails.trySending();
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    subscription.cancel();
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
