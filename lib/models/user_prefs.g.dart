// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_prefs.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPrefs _$UserPrefsFromJson(Map<String, dynamic> json) {
  return UserPrefs(
    json['alwaysRedirectUnsupportedLinks'] as bool,
    json['nitterInstance'] == null
        ? null
        : Uri.parse(json['nitterInstance'] as String),
  );
}

Map<String, dynamic> _$UserPrefsToJson(UserPrefs instance) => <String, dynamic>{
      'alwaysRedirectUnsupportedLinks': instance.alwaysRedirectUnsupportedLinks,
      'nitterInstance': instance.nitterInstance?.toString(),
    };
