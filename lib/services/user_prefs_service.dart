import 'dart:convert';

import 'package:fluffernitter/models/exceptions.dart';
import 'package:fluffernitter/models/user_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsKeys {
  static const String UserPrefs = 'UserPrefs';
}

class UserPrefsService {
  UserPrefs userPrefs;

  init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userPrefsAsString = prefs.getString(PrefsKeys.UserPrefs);
    if (userPrefsAsString == null) {
      print('no user prefs found. Creating defaults.');
      userPrefs = UserPrefs.empty();
    } else {
      userPrefs = UserPrefs.fromJson(json.decode(userPrefsAsString));
      print('loaded user prefs!');
    }
  }

  Future<void> clearSettings() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (err) {
      print('clearSettings() error: ${err.toString()}');
    }
  }

  void updateAlwaysRedirect(bool value) async {
    assert(userPrefs != null);
    userPrefs.alwaysRedirectUnsupportedLinks = value;
    await savePrefs();
    print('updated alwaysRedirectUnsupportedLinks: $value');
  }

  void updateNitterInstance(String newInstance) async {
    assert(userPrefs != null);
    Uri newUri;
    if (newInstance.contains('https://')) {
      newUri = Uri.parse(newInstance);
    } else {
      throw Exception('No https in new url');
    }

    userPrefs.nitterInstance = newUri;
    await savePrefs();
    print('updated nitterInstance: $newInstance');
  }

  void savePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var saved = await prefs.setString(
        PrefsKeys.UserPrefs, json.encode(userPrefs.toJson()));
    if (!saved) {
      throw (Exception(ExceptionMessage.FailedToSavePreference));
    }
    print('saved prefs');
  }
}
