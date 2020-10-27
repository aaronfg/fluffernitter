import 'package:flutter/material.dart';

class UnsupportedTextContent extends StatelessWidget {
  final String text;
  UnsupportedTextContent({@required this.text});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('The text you shared is not a valid Twitter url: \n'),
        Container(
          color: Theme.of(context).accentColor,
          width: MediaQuery.of(context).size.width,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              text,
            ),
          ),
        ),
      ],
    );
  }
}
