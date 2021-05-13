import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:parkinson/vkr/models/person.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;

import 'dart:convert';

class RequestPreferences {
  static bool allowMobile = false;
  static Map toJson() => {'allowMobile': allowMobile};
  static void fromJson(Map json) {
    allowMobile = json['allowMobile'] as bool;
  }

  static Future<void> loadFromPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var string = preferences.getString('requestpreferences');
    if (string != null) fromJson(json.decode(string));
  }

  static Future<void> saveToPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var string = json.encode(toJson());
    await preferences.setString('requestpreferences', string);
  }
}

class Requests {
  static final String url = '192.168.0.104:3001';

  static List<Request> info = [];
  static bool connected = false;

  static Map toJson() => {'info': Requests.info};
  static void fromJson(Map json) {
    info = (json['info'] as List).map((i) => Request.fromJson(i)).toList();
  }

  static void addAndSave(Request req) {
    info.add(req);
    saveToPrefs();
  }

  static void showSnackBar(BuildContext context, String title) {
    final snackBar = SnackBar(content: Text(title));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Future<bool> send(Request req, {bool save = true}) async {
    try {
      if (!connected) {
        if (save) addAndSave(req);
      } else {
        var response = await http
            .post(
              Uri.https(url, req.path),
              headers: <String, String>{
                'Content-Type': 'application/json; charset=UTF-8',
              },
              body: utf8.encode(json.encode(req.map)),
            )
            .timeout(Duration(seconds: 3));
        print(response.statusCode);
        print(response.body);
        if (response.statusCode == 200)
          return true;
        else if (response.statusCode == 400)
          return false;
        else if (save) addAndSave(req);
      }
    } catch (e) {
      if (save) addAndSave(req);
      print(e);
      return false;
    }

    return false;
  }

  static Future<bool> sendFile(Request req, {bool save = true}) async {
    try {
      if (!connected) {
        if (save) addAndSave(req);
      } else {
        var request = http.MultipartRequest(
            'POST', Uri.parse('https://' + url + '/' + req.path));
        request.files.add(http.MultipartFile.fromBytes('file', req.file!,
            filename: Person.phone! +
                ' ' +
                DateTime.now().toUtc().toString() +
                '.wav'));
        request.fields.addAll(req.map!);

        var response = await request.send().timeout(Duration(seconds: 4));
        if (response.statusCode == 200)
          return true;
        else if (response.statusCode == 400)
          return false;
        else if (save) addAndSave(req);
      }
    } catch (_) {
      if (save) addAndSave(req);
      return false;
    }

    return false;
  }

  static Future<void> sendAll() async {
    List<MappedListReturn> mappedList = await Future.wait(info.map((e) async =>
        MappedListReturn(
            e.file == null
                ? await send(e, save: false)
                : await sendFile(e, save: false),
            e)));
    for (final e in mappedList) if (e.boolean) info.remove(e.object);
  }

  static Future<String?> getPersonId(String phone) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    connected = connectivityResult == ConnectivityResult.wifi ||
        (connectivityResult == ConnectivityResult.mobile &&
            RequestPreferences.allowMobile);
    if (connected) {
      try {
        var response =
            await http.get(Uri.https(url, 'users/phone?phone=$phone'));
        if (response.statusCode == 200) {
          return jsonDecode(response.body)['_id'];
        }
      } catch (_) {}
    }
    return null;
  }

  static void checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    connected = connectivityResult == ConnectivityResult.wifi ||
        (connectivityResult == ConnectivityResult.mobile &&
            RequestPreferences.allowMobile);
  }

  static void trySending() async {
    if (connected) {
      try {
        var response = await http.get(Uri.https(url, 'ping'));
        if (response.statusCode == 200) {
          print('cnt before: ${info.length}');
          await sendAll();
          print('cnt after: ${info.length}');
          await saveToPrefs();
        }
      } catch (_) {}
    }
  }

  static Future<void> loadFromPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var string = preferences.getString('requests');
    if (string != null) fromJson(json.decode(string));
    trySending();
  }

  static Future<void> saveToPrefs() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var string = json.encode(toJson());
    await preferences.setString('requests', string);
  }
}

class MappedListReturn {
  final bool boolean;
  final Request object;
  MappedListReturn(this.boolean, this.object);
}

enum MethodType { gett, post, put, delete }

class Request {
  Map<String, String>? map;
  List<int>? file;
  MethodType method;
  String path;

  Request(
      {this.map, this.file, this.method = MethodType.gett, this.path = 'post'});

  static MethodType getStatusFromString(String statusAsString) {
    for (MethodType element in MethodType.values) {
      if (element.toString() == statusAsString) {
        return element;
      }
    }
    return MethodType.gett;
  }

  Map toJson() => {
        'map': map!,
        'method': method.toString(),
        'path': path,
        'file': file,
      };
  Request.fromJson(Map json)
      : map = Map<String, String>.from(json['map']),
        method = getStatusFromString(json['method']),
        path = json['path'],
        file = json['file'] == null
            ? null
            : (json['file'] as List<dynamic>).cast<int>();
}
