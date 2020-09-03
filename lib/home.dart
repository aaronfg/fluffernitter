import 'dart:async';

import 'package:fluffernitter/styles.dart';
import 'package:fluffernitter/widgets/last_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamSubscription _sub;
  String tLink = '';
  String errMsg = '';
  String duh = 'You have to tap a Twitter.com link for this app to do anything.';
  bool loading = false;
  StreamSubscription _intentDataStreamSubscription;
  String _sharedText;

  @override
  void initState() {
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    _initUniLinks();

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen((String value) {
      setState(() {
        _sharedText = value;
      });
    }, onError: (err) {
      print("getLinkStream error: $err");
    });

    // For sharing or opening urls/text coming from outside the app while the app is closed
    ReceiveSharingIntent.getInitialText().then((String value) {
      setState(() {
        _sharedText = value;
      });
    });

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
          builder: (context, orientation) => Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text('fluffernitter',
                      style: Stylez.appTitle.copyWith(color: Theme.of(context).accentColor)),
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
                    Container(
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
                  SizedBox(
                    height: 10,
                  ),
                  if (tLink.isNotEmpty)
                    Container(
                      constraints:
                          BoxConstraints(maxWidth: orientation == Orientation.portrait ? 350 : 400),
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
                  ),
                  Text('Shared Urls'),
                  Text(_sharedText ?? "none yet"),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleLinkUpdates(Uri uri) async {
    if (_isRedirect(uri)) {
      var redirectUrl = _getUriFromRedirect(uri);
      var redUri = Uri.parse(redirectUrl);
      // if this is a 'topics' link, just redirect to the tweet
      if (_isTopicsLink(redUri)) {
        _launchURL(_makeNitterUriFromTopicsUri(redUri));
      } else if (_isMediaGridLink(redUri)) {
        _launchURL(_makeNitterUriFromMediaGridUri(redUri));
      } else {
        _launchURL(_makeNitterUri(redUri));
      }
    } else if (_isShortLink(uri)) {
      try {
        setState(() {
          loading = true;
        });
        var twitterUri = await _getUriFromShortLinkUri(uri);
        setState(() {
          loading = false;
        });
        if (twitterUri != null) {
          _launchURL(_makeNitterUri(twitterUri));
        } else {
          setState(() {
            errMsg = 'Could not get the redirected twitter url from t.co shortlink.';
          });
        }
      } catch (err) {
        setState(() {
          loading = false;
          errMsg = err.toString();
        });
      }
    } else if (_isMediaGridLink(uri)) {
      _launchURL(_makeNitterUriFromMediaGridUri(uri));
    } else {
      setState(() {
        errMsg = '';
      });
      _launchURL(_makeNitterUri(uri));
    }
  }

  bool _isShortLink(Uri uri) {
    return uri.host == 't.co';
  }

  bool _isRedirect(Uri uri) {
    return uri.pathSegments.last == 'redirect';
  }

  bool _isTopicsLink(Uri uri) {
    return uri.path.contains('/i/topics/tweet/');
  }

  bool _isMediaGridLink(Uri uri) {
    return uri.path.endsWith('media/grid');
  }

  String _getUriFromRedirect(Uri redUri) {
    return redUri.queryParameters['url'];
  }

  Uri _getUriFromRedirectBody(String body) {
    var doc = parse(body);
    var linkEl = doc.getElementsByTagName('link');
    for (var link in linkEl) {
      if (link.attributes['rel'] == 'canonical') {
        print('final twitter url:');
        print(link.attributes['href']);
        return Uri.parse(link.attributes['href']);
      }
    }
    return null;
  }

  Future<Uri> _getUriFromShortLinkUri(Uri shortUri) async {
    try {
      var shortLinkResponse = await http.get(shortUri.toString());
      var twitterUri = _getUriFromRedirectBody(shortLinkResponse.body);
      return twitterUri;
    } catch (err) {
      setState(() {
        errMsg = err.toString();
      });
    }
    return null;
  }

  Uri _makeNitterUri(Uri tUri) {
    final Uri nUri = Uri(
      scheme: 'https',
      host: 'nitter.net',
      path: tUri.path,
    );
    return nUri;
  }

  Uri _makeNitterUriFromTopicsUri(Uri topicsUri) {
    var tweetId = topicsUri.pathSegments.last;
    return Uri(scheme: 'https', host: 'nitter.net', path: 'i/status/$tweetId');
  }

  Uri _makeNitterUriFromMediaGridUri(Uri mgUri) {
    var segs = mgUri.pathSegments.sublist(0, mgUri.pathSegments.length - 1);
    return Uri(scheme: 'https', host: 'nitter.net', pathSegments: segs);
  }

  Future<Null> _initUniLinks() async {
    _sub = getUriLinksStream().listen((Uri uri) {
      if (!mounted) return;
      _handleLinkUpdates(uri);
    }, onError: (err) {
      setState(() {
        errMsg = 'Failed to open';
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
      });
    }
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
      });
    }
  }

  void _onAboutTapped() {
    showAboutDialog(
      context: context,
      applicationName: 'fluffernitter',
      applicationVersion: '1.0.5',
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
}
