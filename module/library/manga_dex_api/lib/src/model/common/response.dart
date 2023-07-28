import 'package:json_annotation/json_annotation.dart';

part 'response.g.dart';

@JsonSerializable()
class Response {
  final String? result;
  final String? response;

  Response(
    this.result,
    this.response,
  );

  factory Response.fromJson(Map<String, dynamic> json) {
    return _$ResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$ResponseToJson(this);
}
