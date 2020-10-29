import 'package:flutter/services.dart';

Future<String> loadMockRedirectBodyHtml() async {
  return await rootBundle.loadString('assets/mock_redirect_body.html');
}
