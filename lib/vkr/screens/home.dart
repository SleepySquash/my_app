import 'package:flutter/material.dart';
import 'package:my_app/vkr/models/person.dart';

import 'doctor.dart';
import 'profile.dart';
import 'report.dart';
import 'tests.dart';
import 'notifications.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 2;
  final List<Widget> screens = [
    NotificationsScreen(),
    TestsScreen(),
    ReportScreen(),
    DoctorScreen(),
    ProfileScreen()
  ];

  final List<PreferredSizeWidget> bars = [
    NotificationsAppBar(),
    TestsAppBar(),
    ReportAppBar(),
    DoctorAppBar(),
    ProfileAppBar()
  ];

  final List<Color> colors = [
    NotificationsScreen.color,
    TestsScreen.color,
    ReportScreen.color,
    DoctorScreen.color,
    ProfileScreen.color,
  ];

  @override
  Widget build(BuildContext context) {
    if (!Person.isLoggedIn()) {
      Future.delayed(Duration.zero, () {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return Center();
    }

    return Scaffold(
      appBar: bars[currentIndex],
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        // type: BottomNavigationBarType.fixed,
        iconSize: 40,
        selectedFontSize: 15,
        unselectedFontSize: 15,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            backgroundColor: colors[0],
            label: 'События',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration),
            backgroundColor: colors[1],
            label: 'Тесты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            backgroundColor: colors[2],
            label: 'Отчёт',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            backgroundColor: colors[3],
            label: 'Врач',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            backgroundColor: colors[4],
            label: 'Профиль',
          ),
        ],
        onTap: (int i) => setState(() => currentIndex = i),
      ),
    );
  }
}
