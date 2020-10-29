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

    test('isValidUri()', () {
      var badUri = Uri.parse('https://google.com');
      expect(Utils.isValidUri(badUri), equals(false));
      expect(Utils.isValidUri(mediaGridUri), equals(true));
      expect(Utils.isValidUri(mediaUri), equals(true));
      expect(Utils.isValidUri(twitterMobileAsUri), equals(true));
      expect(Utils.isValidUri(twitterAsUri), equals(true));
      expect(Utils.isValidUri(topicsUri), equals(true));
      expect(Utils.isValidUri(shortAsUri), equals(true));
    });

    test('isShortLink()', () {
      var isShort = Utils.isShortLink(shortAsUri);
      expect(isShort, equals(true));
      var isntShort = Utils.isShortLink(topicsUri);
      expect(isntShort, equals(false));
    });

    test('isMediaGridLink()', () {
      var isRedirect = Utils.isMediaGridLink(mediaGridUri);
      expect(isRedirect, equals(true));
      expect(Utils.isMediaGridLink(twitterMobileAsUri), equals(false));
    });

    test('isTopicsLink()', () {
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
