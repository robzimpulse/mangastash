import 'package:json_annotation/json_annotation.dart';

import '../common/relationship.dart';
import '../common/response.dart';
import 'author_data.dart';

part 'author_response.g.dart';

@JsonSerializable()
class AuthorResponse extends Response {
  final AuthorData? data;

  AuthorResponse(
    super.result,
    super.response,
    this.data,
  );

  factory AuthorResponse.fromJson(Map<String, dynamic> json) {
    return _$AuthorResponseFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$AuthorResponseToJson(this);
}

