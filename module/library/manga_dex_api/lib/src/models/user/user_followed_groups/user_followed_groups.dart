import 'package:json_annotation/json_annotation.dart';
import '../../common/relationships.dart';
part 'user_followed_groups.g.dart';

///@nodoc
@JsonSerializable()
class UserFollowedGroups {
  final List<UserFollowedGroupsData>? data;
  final int? limit;
  final int? offset;
  final int? total;
  UserFollowedGroups(this.data, this.limit, this.offset, this.total);
  factory UserFollowedGroups.fromJson(Map<String, dynamic> json) =>
      _$UserFollowedGroupsFromJson(json);
  Map<String, dynamic> toJson() => _$UserFollowedGroupsToJson(this);
}

///@nodoc
@JsonSerializable()
class UserFollowedGroupsData {
  final String? id;
  final String? type;
  final UserFollowedGroupsAttributes? attributes;
  final List<Relationship>? relationships;
  UserFollowedGroupsData(this.id, this.type, this.attributes, this.relationships);
  factory UserFollowedGroupsData.fromJson(Map<String, dynamic> json) => _$UserFollowedGroupsDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserFollowedGroupsDataToJson(this);
}

///@nodoc
@JsonSerializable()
class UserFollowedGroupsAttributes {
  final String? name;
  final String? website;
  final String? ircServer;
  final String? ircChannel;
  final String? discord;
  final String? contactEmail;
  final String? description;
  final bool? locked;
  final bool? official;
  final int? version;
  final String? createdAt;
  final String? updatedAt;
  UserFollowedGroupsAttributes(
    this.name,
    this.website,
    this.ircServer,
    this.ircChannel,
    this.discord,
    this.contactEmail,
    this.description,
    this.locked,
    this.official,
    this.version,
    this.createdAt,
    this.updatedAt,
  );
  factory UserFollowedGroupsAttributes.fromJson(Map<String, dynamic> json) =>
      _$UserFollowedGroupsAttributesFromJson(json);
  Map<String, dynamic> toJson() => _$UserFollowedGroupsAttributesToJson(this);
}
