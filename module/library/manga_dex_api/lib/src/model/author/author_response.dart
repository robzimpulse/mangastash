import 'package:json_annotation/json_annotation.dart';

import '../common/attribute.dart';
import '../common/identifier.dart';
import '../common/relationship.dart';
import '../common/response.dart';

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

@JsonSerializable()
class AuthorData extends Identifier {
  final AuthorDataAttributes? attributes;
  final List<Relationship>? relationships;
  AuthorData(super.id, super.type, this.attributes, this.relationships);
  factory AuthorData.fromJson(Map<String, dynamic> json) {
    return _$AuthorDataFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$AuthorDataToJson(this);
}

@JsonSerializable()
class AuthorDataAttributes extends Attribute {
  final String? name;
  final String? imageUrl;
  final String? twitter;
  final String? pixiv;
  final String? melonBook;
  final String? fanBox;
  final String? booth;
  final String? nicoVideo;
  final String? skeb;
  final String? fantia;
  final String? tumblr;
  final String? youtube;
  final String? weibo;
  final String? naver;
  final String? website;

  AuthorDataAttributes(
    super.createdAt,
    super.updatedAt,
    super.version,
    this.name,
    this.imageUrl,
    this.twitter,
    this.pixiv,
    this.melonBook,
    this.fanBox,
    this.booth,
    this.nicoVideo,
    this.skeb,
    this.fantia,
    this.tumblr,
    this.youtube,
    this.weibo,
    this.naver,
    this.website,
  );
  factory AuthorDataAttributes.fromJson(Map<String, dynamic> json) {
    return _$AuthorDataAttributesFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$AuthorDataAttributesToJson(this);
}
