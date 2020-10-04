// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nitter_instance.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NitterInstance _$NitterInstanceFromJson(Map<String, dynamic> json) {
  return NitterInstance(
    uri: json['uri'] == null ? null : Uri.parse(json['uri'] as String),
  );
}

Map<String, dynamic> _$NitterInstanceToJson(NitterInstance instance) =>
    <String, dynamic>{
      'uri': instance.uri?.toString(),
    };
