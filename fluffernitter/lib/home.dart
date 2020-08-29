import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String tLink = 'You haven\'t tapped any Twitter links yet.';
  String errMsg = '';
  bool loading = false;

  @override
  void initState() {
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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'fluffernitter',
                  style: TextStyle(
                      color: Color.fromRGBO(255, 108, 96, 1.0),
                      fontWeight: FontWeight.bold,
                      fontSize: 50),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 60),
                  child: Text(
                    'You have to tap a Twitter.com link for this app to do anything.',
                    textAlign: TextAlign.center,
                  ),
                ),
                if (loading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                if (errMsg.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text('Error: $errMsg'),
                  ),
                SizedBox(
                  height: 40,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 60),
                  child: Text('Last link:\n$tLink',
                      textAlign: TextAlign.center, style: Theme.of(context).textTheme.caption),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isShortLink(Uri uri) {
    return uri.host == 't.co';
  }

  _handleLinkUpdates(Uri uri) async {
    print(isShortLink(uri));
    if (isShortLink(uri)) {
      try {
        setState(() {
          loading = true;
        });
        var shortLinkResponse = await http.get(uri.toString());
        var twitterUri = _getUriFromRedirectBody(shortLinkResponse.body);
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
        });
        print(err);
      }
    } else {
      setState(() {
        errMsg = '';
      });
      _launchURL(_makeNitterUri(uri));
    }
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
      // Handle exception by warning the user their action did not succeed
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
}