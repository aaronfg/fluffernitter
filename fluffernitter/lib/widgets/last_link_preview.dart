import 'package:fluffernitter/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';

/// Displays a preview for the nitter link
class LastLinkPreview extends StatelessWidget {
  /// Tap handler
  final Function onTap;

  /// The url to show the preview for
  final String linkUrl;

  LastLinkPreview({@required this.linkUrl, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 5,
        color: Color.fromRGBO(0, 0, 0, .8),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 18.0,
            vertical: 12.0,
          ),
          child: Column(
            children: [
              FlutterLinkPreview(
                key: ValueKey("${linkUrl}211"),
                url: linkUrl,
                titleStyle: Stylez.bold,
                useMultithread: true,
              ),
              FractionallySizedBox(
                widthFactor: 1,
                child: Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    linkUrl,
                    style: Stylez.linkUrl,
                    textAlign: TextAlign.start,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
