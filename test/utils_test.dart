// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.
import 'package:fluffernitter/utils.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Utils', () {
    String shortLink = 'https://t.co/aldjaslkdjdkladj';
    Uri shortAsUri = Uri.parse(shortLink);
    Uri topicsUri = Uri.parse(
        'https://twitter.com/i/topics/tweet/1252936339739181057?cn=ZmxleGlibGVfcmVjc18y&refsrc=email');
    Uri twitterAsUri = Uri.parse('https://twitter.com/realgdt');
    Uri twitterMobileAsUri = Uri.parse('https://mobile.twitter.com/realgdt');
    Uri mediaUri = Uri.parse('https://twitter.com/realgdt/media');
    Uri mediaGridUri = Uri.parse('https://twitter.com/realgdt/media/grid');
    //"https://mobile.twitter.com/PhilippeLENOIR2/status/1318621719591092225/photo/4"
    // "https://twitter.com/realgdt/media"
    //https://www.robrhinehart.com/why-i-am-voting-for-kanye-west/ <-- a t.co redirect got to this.
    // from this https://t.co/TlwzNXRTkL?amp=1
    // topics url
    // https://twitter.com/i/topics/tweet/1252936339739181057?cn=ZmxleGlibGVfcmVjc18y&refsrc=email

    test('isShortLink()', () {
      var isShort = Utils.isShortLink(shortAsUri);
      expect(isShort, equals(true));
      var isntShort = Utils.isShortLink(topicsUri);
      expect(isntShort, equals(false));
    });

    test('isTopicsUrl()', () {
      expect(Utils.isTopicsLink(topicsUri), equals(true));
      expect(Utils.isTopicsLink(Uri.parse('https://twitter.com')), equals(false));
    });

    test('getUriFromRedirectBody()', () async {
      var redirectBodyString = await loadMockRedirectBodyHtml();
      var uri = Utils.getUriFromRedirectBody(redirectBodyString);
      expect(
          uri,
          Uri.parse(
              'https://github.blog/2020-10-27-code-scanning-a-github-repository-using-github-advanced-security-within-an-azure-devops-pipeline/'));
    });
  });
}
