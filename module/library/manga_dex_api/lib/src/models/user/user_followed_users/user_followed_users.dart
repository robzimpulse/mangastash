///@nodoc
import 'package:json_annotation/json_annotation.dart';
import '../../common/relationships.dart';
part 'user_followed_users.g.dart';

///@nodoc
@JsonSerializable()
class UserFollowedUsers {
  final List<UserFollowedUsersData>? data;
  final int? limit;
  final int? offset;
  final int? total;
  UserFollowedUsers(this.data, this.limit, this.offset, this.total);
  factory UserFollowedUsers.fromJson(Map<String, dynamic> json) =>
      _$UserFollowedUsersFromJson(json);
  Map<String, dynamic> toJson() => _$UserFollowedUsersToJson(this);
}

///@nodoc
@JsonSerializable()
class UserFollowedUsersData {
  final String? id;
  final String? type;
  final UserFollowedUsersAttributes? attributes;
  final List<Relationship>? relationships;
  UserFollowedUsersData(this.id, this.type, this.attributes, this.relationships);
  factory UserFollowedUsersData.fromJson(Map<String, dynamic> json) => _$UserFollowedUsersDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserFollowedUsersDataToJson(this);
}

///@nodoc
@JsonSerializable()
class UserFollowedUsersAttributes {
  final String? username;
  final Role? roles;
  final int? version;
  UserFollowedUsersAttributes(this.username, this.roles, this.version);
  factory UserFollowedUsersAttributes.fromJson(Map<String, dynamic> json) =>
      _$UserFollowedUsersAttributesFromJson(json);
  Map<String, dynamic> toJson() => _$UserFollowedUsersAttributesToJson(this);
}

///@nodoc
@JsonSerializable()
class Role {
  final List<String>? roles;
  Role(this.roles);
  factory Role.fromJson(Map<String, dynamic> json) => _$RoleFromJson(json);

  Map<String, dynamic> toJson() => _$RoleToJson(this);
}
