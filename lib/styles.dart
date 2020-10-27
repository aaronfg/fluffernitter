import 'package:flutter/material.dart';

/// TextStyle constants used in the app
class Stylez {
  static const TextStyle appTitle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 50);
  static const TextStyle screenTitle =
      TextStyle(fontWeight: FontWeight.bold, fontSize: 20);
  static const TextStyle bold = TextStyle(fontWeight: FontWeight.bold);
  static const TextStyle errorMsg = TextStyle(color: Colors.white);
  static const TextStyle linkUrl = TextStyle(color: Colors.grey);
  static const TextStyle instanceHint =
      TextStyle(color: Colors.white70, fontStyle: FontStyle.italic);

  static forContext(BuildContext context, TextStyle style) =>
      style.copyWith(color: Theme.of(context).accentColor);
}
