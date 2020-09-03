import 'package:fluffernitter/models/exceptions.dart';
import 'package:fluffernitter/models/user_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrefsKeys {
  static const String UserPrefs = 'UserPrefs';
}

class UserPrefsService {
  UserPrefs userPrefs;

  init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var userPrefsAsString = prefs.getString(PrefsKeys.UserPrefs);
    if (userPrefsAsString == null) {
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
    var saved = await savePrefs();
    if (!saved) {
      throw (Exception(ExceptionMessage.FailedToSavePreference));
    }
  }

  Future<bool> savePrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var saved = await prefs.setString(PrefsKeys.UserPrefs, json.encode(userPrefs.toJson()));
    return saved;
  }
}
