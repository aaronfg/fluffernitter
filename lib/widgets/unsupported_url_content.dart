import 'package:flutter/material.dart';

class UnsupportedUrlContent extends StatelessWidget {
  final String badUrl;
  final bool alwaysRedirectOtherUrls;
  final Function(bool value) onAlwaysRedirectPrefChange;

  UnsupportedUrlContent(
      {@required this.badUrl,
      @required this.alwaysRedirectOtherUrls,
      @required this.onAlwaysRedirectPrefChange});

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
              badUrl,
            ),
          ),
        ),
        LimitedBox(
            child: CheckboxListTile(
          value: alwaysRedirectOtherUrls,
          onChanged: onAlwaysRedirectPrefChange,
          title: Text('Always redirect non-Twitter links back to browser.'),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.symmetric(vertical: 8),
        )),
      ],
    );
  }
}
