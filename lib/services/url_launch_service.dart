import 'package:url_launcher/url_launcher.dart';

class UrlLaunchService {
  static Future<void> redirectToBrowser(Uri yuri) async {
    if (await canLaunch(yuri.toString())) {
      await launch(yuri.toString());
    } else {
      throw (new Exception('Can\'t open url'));
    }
  }
}
