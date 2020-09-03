import 'package:fluffernitter/home.dart';
import 'package:fluffernitter/service_locator.dart';
import 'package:flutter/material.dart';

void main() {
  setup();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
