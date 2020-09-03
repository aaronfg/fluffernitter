import 'package:flutter/material.dart';

/// TextStyle constants used in the app
class Stylez {
  static const TextStyle appTitle = TextStyle(fontWeight: FontWeight.bold, fontSize: 50);
  static const TextStyle bold = TextStyle(fontWeight: FontWeight.bold);
  static const TextStyle errorMsg = TextStyle(color: Colors.white);
  static const TextStyle linkUrl = TextStyle(color: Colors.grey);
  static const TextStyle badLink = TextStyle(
    backgroundColor: Color.fromRGBO(255, 108, 96, 1.0),
    color: Colors.white,
  );
}
