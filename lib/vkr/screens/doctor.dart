import 'package:flutter/material.dart';

class DoctorAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: DoctorScreen.color,
      title: Text('Врач'),
    );
  }
}

class DoctorScreen extends StatelessWidget {
  static Color color = Colors.red[800]!;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Связаться с врачом'),
    );
  }
}
