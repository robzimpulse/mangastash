import 'package:json_annotation/json_annotation.dart';

import '../common/attribute.dart';

part 'author_data_attributes.g.dart';

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

  const AuthorDataAttributes(
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
