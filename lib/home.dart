import 'dart:async';

import 'package:fluffernitter/service_locator.dart';
import 'package:fluffernitter/services/user_prefs_service.dart';
import 'package:fluffernitter/styles.dart';
import 'package:fluffernitter/utils.dart';
import 'package:fluffernitter/widgets/last_link_preview.dart';
import 'package:fluffernitter/widgets/settings.dart';
import 'package:fluffernitter/widgets/unsupported_url_content.dart';
import 'package:fluffernitter/widgets/unuspported_text_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamSubscription _sub;
  StreamSubscription _intentDataStreamSubscription;
  String tLink = '';
  String errMsg = '';
  String duh = 'You have to tap a Twitter.com link for this app to do anything.';
  bool loading = false;
  bool _alwaysRedirectOtherUrls = false;

  @override
  void initState() {
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    _initPrefs();
    _initUniLinks();
    _initShareIntentHandling();
    super.initState();
  }

  @override
  void dispose() {
    _sub.cancel();
    _intentDataStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) => Stack(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text('fluffernitter', style: Stylez.forContext(context, Stylez.appTitle)),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 60),
                        child: Text(
                          duh,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (loading)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 16),
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.black.withOpacity(.4),
                          ),
                        ),
                      if (errMsg.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: Container(
                            color: Colors.red,
                            width: MediaQuery.of(context).size.width,
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 60),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Error:', style: Stylez.bold),
                                  Text(
                                    errMsg,
                                    style: Stylez.errorMsg,
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      SizedBox(
                        height: 10,
                      ),
                      if (tLink.isNotEmpty)
                        Container(
                          constraints: BoxConstraints(
                              maxWidth: orientation == Orientation.portrait ? 350 : 400),
                          child: LastLinkPreview(
                            linkUrl: tLink,
                            onTap: () => _launchURL(Uri.parse(tLink)),
                          ),
                        ),
                      Center(
                        child: IconButton(
                          icon: Icon(Icons.info_outline),
                          onPressed: () => _onAboutTapped(),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Positioned(
                child: IconButton(
                  icon: Icon(Icons.settings),
                  color: Colors.grey,
                  onPressed: _onSettingsPressed,
                ),
                bottom: 20,
                right: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _initPrefs() {
    UserPrefsService prefsSrv = locator.get<UserPrefsService>();
    prefsSrv.init();
  }

  void _handleLinkUpdates(Uri uri) async {
    if (Utils.isRedirect(uri)) {
      var redirectUrl = Utils.getUriFromRedirect(uri);
      var redUri = Uri.parse(redirectUrl);
      // if this is a 'topics' link, just redirect to the tweet
      if (Utils.isTopicsLink(redUri)) {
        _launchURL(Utils.makeNitterUriFromTopicsUri(redUri));
      } else if (Utils.isMediaGridLink(redUri)) {
        _launchURL(Utils.makeNitterUriFromMediaGridUri(redUri));
      } else {
        _launchURL(Utils.makeNitterUri(redUri));
      }
    } else if (Utils.isShortLink(uri)) {
      Uri resolvedUri;
      try {
        setState(() {
          loading = true;
        });
        resolvedUri = await Utils.getUriFromShortLinkUri(uri);
        setState(() {
          loading = false;
        });
      } catch (err) {
        setState(() {
          loading = false;
          errMsg = err.toString();
          tLink = '';
        });
      }
      // Now that we have the fully resolved Uri, also
      // test if this is a twitter url
      try {
        if (Utils.isValidUri(resolvedUri)) {
          _launchURL(Utils.makeNitterUri(resolvedUri));
        } else {}
      } catch (err) {
        print('error: $err');
        setState(() {
          errMsg = 'Could not get the redirected twitter url from t.co shortlink.';
          tLink = '';
        });
      }
    } else if (Utils.isMediaGridLink(uri)) {
      _launchURL(Utils.makeNitterUriFromMediaGridUri(uri));
    } else {
      setState(() {
        errMsg = '';
      });
      _launchURL(Utils.makeNitterUri(uri));
    }
  }

  Future<Null> _initUniLinks() async {
    _sub = getUriLinksStream().listen((Uri uri) {
      if (!mounted) return;
      _handleLinkUpdates(uri);
    }, onError: (err) {
      setState(() {
        errMsg = 'Failed to open';
        tLink = '';
      });
    });
    try {
      Uri initialUri = await getInitialUri();
      if (initialUri != null) {
        _handleLinkUpdates(initialUri);
      }
    } on PlatformException {
      setState(() {
        errMsg = 'Something was busted getting the url. Sorry.';
        tLink = '';
      });
    }
  }

  _initShareIntentHandling() {
    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String value) {
      print('app already open, received text: $value');
      setState(() {
        _parseSharedText(value);
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      print('app closed, received text: $value');
      setState(() {
        _parseSharedText(value);
      });
    });
  }

  void _parseSharedText(String txt) {
    try {
      Uri uri = Uri.parse(txt);
      // twitter domains we're looking for?
      if (Utils.isValidUri(uri)) {
        _handleLinkUpdates(uri);
      } else if (Utils.isUrl(uri)) {
        // this is not a url
        _showUnsupportedUrlContentAlert(txt, uri);
      } else {
        // this has to just be text. no bueno.
        _showUnsupportedTextContent(txt, uri);
      }
    } catch (err) {
      if (err is FormatException) {
        print('EXCEPTION!!');
      }
    }
  }

  void _showUnsupportedUrlContentAlert(String txt, Uri uri) {
    print('-----> Not a twitter link! redirect to browser');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Oops'),
        content: SingleChildScrollView(
          child: UnsupportedUrlContent(
            badUrl: txt,
            alwaysRedirectOtherUrls: _alwaysRedirectOtherUrls,
            onAlwaysRedirectPrefChange: _onAlwaysRedirectPrefChange,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Close')),
          TextButton(
              onPressed: () => _launchURL(uri, updateTLink: false), child: Text('Open in browser'))
        ],
      ),
    );
  }

  void _showUnsupportedTextContent(String txt, Uri uri) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Oops'),
        content: SingleChildScrollView(
          child: UnsupportedTextContent(
            text: txt,
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('Ok'))],
      ),
    );
  }

  void _launchURL(Uri yuri, {bool updateTLink = true}) async {
    if (await canLaunch(yuri.toString())) {
      setState(() {
        if (updateTLink) {
          tLink = yuri.toString();
        }
        errMsg = '';
      });
      await launch(yuri.toString());
    } else {
      setState(() {
        errMsg = 'Could not launch ${yuri.toString()}';
        tLink = '';
      });
    }
  }

  void _onAlwaysRedirectPrefChange(bool value) {
    setState(() {
      _alwaysRedirectOtherUrls = value;
    });
  }

  void _onAboutTapped() {
    showAboutDialog(
      context: context,
      applicationName: 'fluffernitter',
      applicationVersion: '1.0.61',
      applicationIcon: Container(
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: CircleAvatar(
          backgroundImage: AssetImage("assets/fluffernitter_logo_icon_alpha.png"),
          backgroundColor: Colors.transparent,
        ),
      ),
      children: [
        Text('\u00a9 ${DateTime.now().year.toString()} Aaron F. Gonzalez'),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(
              'Disclaimer: Nitter.net doesn\'t support every thing Twitter does (Articles and Moments for example).\n\nHowever, if a link doesn\'t work in this app but works in the browser on nitter.net, please let me know.'),
        ),
        RaisedButton(
            onPressed: () => _launchURL(
                Uri.parse('https://github.com/aaronfg/fluffernitter/issues'),
                updateTLink: false),
            child: Text('Open issue on Github'))
      ],
    );
  }

  void _onSettingsPressed() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Settings()),
    );
  }
}
