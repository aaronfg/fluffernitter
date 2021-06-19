import 'package:fluffernitter/services/url_launch_service.dart';
import 'package:fluffernitter/services/user_prefs_service.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

void setup() {
  locator.registerSingleton<UserPrefsService>(UserPrefsService());
  locator.registerSingleton<UrlLaunchService>(UrlLaunchService());
}
