import 'package:json_annotation/json_annotation.dart';

part 'author_info.g.dart';

///@nodoc
@JsonSerializable()
class AuthorInfo {
  final String? result;
  final String? response;
  final AuthorInfoData? data;
  final List<Relationship>? relationships;
  AuthorInfo(this.result, this.response, this.data, this.relationships);
  factory AuthorInfo.fromJson(Map<String, dynamic> json) =>
      _$AuthorInfoFromJson(json);

  Map<String, dynamic> toJson() => _$AuthorInfoToJson(this);
}

///@nodoc
@JsonSerializable()
class AuthorInfoData {
  final String? id;
  final String? type;
  final AuthorInfoAttributes? attributes;
  AuthorInfoData(this.id, this.type, this.attributes);
  factory AuthorInfoData.fromJson(Map<String, dynamic> json) => _$AuthorInfoDataFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorInfoDataToJson(this);
}

///@nodoc
@JsonSerializable()
class AuthorInfoAttributes {
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
  final String? createdAt;
  final String? updateAt;
  final int? version;
  AuthorInfoAttributes(
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
    this.createdAt,
    this.updateAt,
    this.version,
  );

  factory AuthorInfoAttributes.fromJson(Map<String, dynamic> json) =>
      _$AuthorInfoAttributesFromJson(json);
  Map<String, dynamic> toJson() => _$AuthorInfoAttributesToJson(this);
}

///@nodoc
@JsonSerializable()
class Relationship {
  final String? id;
  final String? type;
  Relationship(this.id, this.type);
  factory Relationship.fromJson(Map<String, dynamic> json) =>
      _$RelationshipFromJson(json);
  Map<String, dynamic> toJson() => _$RelationshipToJson(this);
}
