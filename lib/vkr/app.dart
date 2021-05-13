import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:parkinson/vkr/models/person.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:convert';

import 'package:parkinson/vkr/models/person.dart' as models;
import 'package:parkinson/vkr/screens/home.dart';
import 'package:parkinson/vkr/screens/login.dart';

import 'package:parkinson/vkr/models/notifications.dart';
import 'package:parkinson/vkr/models/bluetooth.dart';
import 'package:parkinson/vkr/models/events.dart';
import 'package:parkinson/vkr/models/requests.dart';

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
  await Person.loadFromPrefs();
  Notifications.init();
  Bluetooth.loadFromPrefs();
  Events.loadFromPrefs();
  RequestPreferences.loadFromPrefs();
  Requests.checkConnection();
  Requests.loadFromPrefs();
  Mails.loadFromPrefs();
  Bluetooth.searchAndConnect();

  Timer.periodic(Duration(minutes: 2), (t) {
    if (Requests.connected) {
      Requests.trySending();
      Mails.trySending();
    }
  });

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var subscription;

  @override
  void initState() {
    super.initState();

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
