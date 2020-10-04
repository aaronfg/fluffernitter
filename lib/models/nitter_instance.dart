import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

// Generated file include. Do not delete this.
part 'nitter_instance.g.dart';

/// A descriptor for an instance of Nitter
@JsonSerializable()
class NitterInstance {
  final Uri uri;
  // Constructor
  const NitterInstance({@required this.uri});

  /// Generate a new NitterInstance instance from Json
  factory NitterInstance.fromJson(Map<String, dynamic> json) => _$NitterInstanceFromJson(json);

  /// Serializes this class instance to Json
  Map<String, dynamic> toJson() => _$NitterInstanceToJson(this);
}
