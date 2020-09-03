import 'package:fluffernitter/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluffernitter',
      theme: ThemeData(
        primarySwatch: Colors.red,
        accentColor: Color.fromRGBO(255, 108, 96, 1.0),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        brightness: Brightness.dark,
      ),
      home: Home(),
    );
  }
}
