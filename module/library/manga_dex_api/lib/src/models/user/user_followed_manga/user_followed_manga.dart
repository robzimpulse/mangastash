///@nodoc
import 'package:json_annotation/json_annotation.dart';
import '../../common/attributes.dart';
import '../../common/data.dart';
import '../../common/relationships.dart';
part 'user_followed_manga.g.dart';

///@nodoc
@JsonSerializable()
class UserFollowedManga {
  final List<UserFollowedMangaData>? data;
  final int? limit;
  final int? offset;
  final int? total;
  UserFollowedManga(this.data, this.limit, this.offset, this.total);
  factory UserFollowedManga.fromJson(Map<String, dynamic> json) =>
      _$UserFollowedMangaFromJson(json);
  Map<String, dynamic> toJson() => _$UserFollowedMangaToJson(this);
}

@JsonSerializable()
class UserFollowedMangaData extends Data {
  final Attributes? attributes;
  final List<Relationship>? relationships;
  UserFollowedMangaData(
    super.id,
    super.type,
    this.attributes,
    this.relationships,
  );
  factory UserFollowedMangaData.fromJson(Map<String, dynamic> json) =>
      _$UserFollowedMangaDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$UserFollowedMangaDataToJson(this);
}
