import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_link_preview/flutter_link_preview.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StreamSubscription _sub;
  TextStyle linkTitle;
  TextStyle linkUrl;
  TextStyle appTitle;
  String tLink = '';
  String errMsg = '';
  String duh = 'You have to tap a Twitter.com link for this app to do anything.';
  bool loading = false;

  @override
  void initState() {
    FlutterStatusbarcolor.setStatusBarWhiteForeground(true);
    _setupStyles();
    _initUniLinks();
    super.initState();
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(tLink.isNotEmpty);
    return Scaffold(
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) => Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text('fluffernitter',
                      style: appTitle.copyWith(color: Theme.of(context).accentColor)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 60),
                    child: Text(
                      duh,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (loading)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.black.withOpacity(.4),
                      ),
                    ),
                  if (errMsg.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text('Error: $errMsg'),
                    ),
                  SizedBox(
                    height: 30,
                  ),
                  if (tLink.isNotEmpty)
                    Container(
                      constraints:
                          BoxConstraints(maxWidth: orientation == Orientation.portrait ? 350 : 400),
                      child: InkWell(
                        onTap: () => _launchURL(Uri.parse(tLink)),
                        child: Card(
                          elevation: 5,
                          color: Color.fromRGBO(0, 0, 0, .8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18.0,
                              vertical: 12.0,
                            ),
                            child: Column(
                              children: [
                                FlutterLinkPreview(
                                  key: ValueKey("${tLink}211"),
                                  url: tLink,
                                  titleStyle: linkTitle,
                                  useMultithread: true,
                                ),
                                FractionallySizedBox(
                                  widthFactor: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      tLink,
                                      style: linkUrl,
                                      textAlign: TextAlign.start,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
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
        ),
      ),
    );
  }

  _setupStyles() {
    linkTitle = TextStyle(fontWeight: FontWeight.bold);
    linkUrl = TextStyle(color: Colors.grey);
    appTitle = TextStyle(fontWeight: FontWeight.bold, fontSize: 50);
  }

  bool _isShortLink(Uri uri) {
    return uri.host == 't.co';
  }

  _handleLinkUpdates(Uri uri) async {
    print(_isShortLink(uri));
    Uri twitterUri;
    if (_isRedirect(uri)) {
      var redirectUrl = _getUriFromRedirect(uri);
      var redUri = Uri.parse(redirectUrl);
      // if this is a 'topics' link, just redirect to the tweet
      if (_isTopicsLink(redUri)) {
        _launchURL(_makeNitterUriFromTopicsUri(redUri));
      } else {
        twitterUri = Uri.parse(redirectUrl);
        _launchURL(_makeNitterUri(twitterUri));
      }
    } else if (_isShortLink(uri)) {
      try {
        setState(() {
          loading = true;
        });
        twitterUri = await _getUriFromShortLinkUri(uri);
        setState(() {
          loading = false;
        });
        if (twitterUri != null) {
          _launchURL(_makeNitterUri(uri));
        } else {
          setState(() {
            errMsg = 'Could not get the redirected twitter url from t.co shortlink.';
          });
        }
      } catch (err) {
        setState(() {
          loading = false;
        });
        print(err);
      }
    } else {
      setState(() {
        errMsg = '';
      });
    }
    // if (twitterUri != null) {
    //   _launchURL(_makeNitterUri(twitterUri));
    // } else {
    //   _launchURL(_makeNitterUri(uri));
    // }
  }

  bool _isRedirect(Uri uri) {
    return uri.pathSegments.last == 'redirect';
  }

  String _getUriFromRedirect(Uri redUri) {
    return redUri.queryParameters['url'];
  }

  bool _isTopicsLink(Uri uri) {
    return uri.path.contains('/i/topics/tweet/');
  }

  Uri _makeNitterUriFromTopicsUri(Uri topicsUri) {
    var tweetId = topicsUri.pathSegments.last;
    return Uri(scheme: 'https', host: 'nitter.net', path: 'i/status/$tweetId');
  }

  Future<Uri> _getUriFromShortLinkUri(Uri shortUri) async {
    try {
      var shortLinkResponse = await http.get(shortUri.toString());
      var twitterUri = _getUriFromRedirectBody(shortLinkResponse.body);
      return twitterUri;
    } catch (err) {
      print(err);
    }
    return null;
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
      } else {
        print('null!!!!!');
      }
    } on PlatformException {
      setState(() {
        errMsg = 'Something was busted getting the url. Sorry.';
      });
    }
  }

  _makeNitterUri(Uri tUri) {
    final Uri nUri = Uri(
      scheme: 'https',
      host: 'nitter.net',
      path: tUri.path,
    );
    return nUri;
  }

  _launchURL(Uri yuri) async {
    if (await canLaunch(yuri.toString())) {
      setState(() {
        tLink = yuri.toString();
        errMsg = '';
      });
      await launch(yuri.toString());
    } else {
      setState(() {
        errMsg = 'Could not launch ${yuri.toString()}';
      });
    }
  }

  _onAboutTapped() {
    showAboutDialog(
        context: context,
        applicationVersion: '1.0.2',
        applicationIcon: Container(
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: CircleAvatar(
            backgroundImage: AssetImage("assets/fluffernitter_logo_icon_alpha.png"),
            backgroundColor: Colors.transparent,
          ),
        ),
        children: [Text('\u00a9 ${DateTime.now().year.toString()} Aaron F. Gonzalez')]);
  }
}
