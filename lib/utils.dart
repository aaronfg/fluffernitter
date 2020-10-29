import 'package:fluffernitter/models/user_prefs.dart';
import 'package:fluffernitter/service_locator.dart';
import 'package:fluffernitter/services/user_prefs_service.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;

class Utils {
  static List<String> whitelistHosts = ['twitter.com', 'mobile.twitter.com', 't.co'];

  static bool isUrl(Uri uri) {
    return uri.hasScheme && (uri.host != null && uri.host.isNotEmpty);
  }

  static bool isValidUri(Uri uri) {
    return uri.hasScheme && whitelistHosts.contains(uri.host);
  }

  static bool isShortLink(Uri uri) {
    return uri.host == 't.co';
  }

  static bool isRedirect(Uri uri) {
    return uri.pathSegments.last == 'redirect';
  }

  static bool isTopicsLink(Uri uri) {
    return uri.path.contains('/i/topics/tweet/');
  }

  static bool isMediaGridLink(Uri uri) {
    return uri.path.endsWith('media/grid');
  }

  static String getUriFromRedirect(Uri redUri) {
    return redUri.queryParameters['url'];
  }

  static Uri getUriFromRedirectBody(String body) {
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

  static Future<Uri> getUriFromShortLinkUri(Uri shortUri) async {
    try {
      var shortLinkResponse = await http.get(shortUri.toString());
      var twitterUri = getUriFromRedirectBody(shortLinkResponse.body);
      return twitterUri;
    } catch (err) {
      throw (err);
    }
  }

  static Uri makeNitterUri(Uri tUri) {
    UserPrefsService prefsSrv = locator.get<UserPrefsService>();
    UserPrefs prefs = prefsSrv.userPrefs;
    final Uri nUri = Uri(
      scheme: 'https',
      host: prefs.nitterInstance.host,
      path: tUri.path,
    );
    return nUri;
  }

  static Uri makeNitterUriFromTopicsUri(Uri topicsUri) {
    UserPrefsService prefsSrv = locator.get<UserPrefsService>();
    UserPrefs prefs = prefsSrv.userPrefs;
    var tweetId = topicsUri.pathSegments.last;
    return Uri(scheme: 'https', host: prefs.nitterInstance.host, path: 'i/status/$tweetId');
  }

  static Uri makeNitterUriFromMediaGridUri(Uri mgUri) {
    UserPrefsService prefsSrv = locator.get<UserPrefsService>();
    UserPrefs prefs = prefsSrv.userPrefs;
    var segs = mgUri.pathSegments.sublist(0, mgUri.pathSegments.length - 1);
    return Uri(scheme: 'https', host: prefs.nitterInstance.host, pathSegments: segs);
  }
}
