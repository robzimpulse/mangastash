import 'package:json_annotation/json_annotation.dart';

import '../common/identifier.dart';
import '../common/response.dart';

part 'author_response.g.dart';

@JsonSerializable()
class AuthorResponse extends Response {
  final List<AuthorData>? data;
  final int? limit;
  final int? offset;
  final int? total;
  AuthorResponse(
    super.result,
    super.response,
    this.data,
    this.limit,
    this.offset,
    this.total,
  );
  factory AuthorResponse.fromJson(Map<String, dynamic> json) {
    return _$AuthorResponseFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$AuthorResponseToJson(this);
}

@JsonSerializable()
class AuthorData extends Identifier {
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
  final int? version;
  final String? createdAt;
  final String? updatedAt;
  final AuthorDataAttributes? attributes;
  final List<AuthorDataRelationship> relationships;
  AuthorData(
    super.id,
    super.type,
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
    this.version,
    this.createdAt,
    this.updatedAt,
    this.attributes,
    this.relationships,
  );
  factory AuthorData.fromJson(Map<String, dynamic> json) {
    return _$AuthorDataFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$AuthorDataToJson(this);
}

@JsonSerializable()
class AuthorDataAttributes {
  final String? name;
  final String? imageUrl;
  // TODO: map author biography
  // final AuthorDataAttributesBiography biography;
  AuthorDataAttributes({this.name, this.imageUrl});
  factory AuthorDataAttributes.fromJson(Map<String, dynamic> json) {
    return _$AuthorDataAttributesFromJson(json);
  }
  Map<String, dynamic> toJson() => _$AuthorDataAttributesToJson(this);
}

@JsonSerializable()
class AuthorDataRelationship extends Identifier {
  final String? related;
  AuthorDataRelationship(super.id, super.type, this.related);
  factory AuthorDataRelationship.fromJson(Map<String, dynamic> json) {
    return _$AuthorDataRelationshipFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$AuthorDataRelationshipToJson(this);
}
