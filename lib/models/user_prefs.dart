import 'package:json_annotation/json_annotation.dart';

// Generated file include. Do not delete this.
part 'user_prefs.g.dart';

/// The model for a user's app prefs.
@JsonSerializable()
class UserPrefs {
  /// `true` if we should skip showing an alert dialog when an unsupported
  /// url is shared with the app.
  bool alwaysRedirectUnsupportedLinks;

  /// The Nitter instance to redirect Twitter links to.
  Uri nitterInstance;

  UserPrefs(this.alwaysRedirectUnsupportedLinks, this.nitterInstance);

  /// Creates a new empty UserPrefs instance
  UserPrefs.empty() {
    alwaysRedirectUnsupportedLinks = false;
    nitterInstance = Uri.parse('https://nitter.moomoo.me');
  }

  /// Generate a new UserPrefs instance from Json
  factory UserPrefs.fromJson(Map<String, dynamic> json) => _$UserPrefsFromJson(json);

  /// Serializes this class instance to Json
  Map<String, dynamic> toJson() => _$UserPrefsToJson(this);
}
