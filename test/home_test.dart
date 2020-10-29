import 'package:fluffernitter/main.dart';
import 'package:fluffernitter/models/user_prefs.dart';
import 'package:fluffernitter/services/user_prefs_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Home', (WidgetTester tester) async {
    final locator = GetIt.instance;
    locator.registerSingleton<UserPrefsService>(UserPrefsService());

    SharedPreferences.setMockInitialValues(UserPrefs.empty().toJson());

    await tester.pumpWidget(MyApp());
    expect(find.byIcon(Icons.settings), findsOneWidget);

    // // Tap the settings icon and trigger a frame.
    // await tester.tap(find.byIcon(Icons.settings));
    // await tester.pump();

    // // Verify that our counter has incremented.
    // expect(find.text('https://nitter.net'), findsOneWidget);
  });
}
