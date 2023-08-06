import 'package:json_annotation/json_annotation.dart';

import '../common/attribute.dart';
import '../common/identifier.dart';
import '../common/response.dart';
import '../common/title.dart';

part 'tag_response.g.dart';

@JsonSerializable()
class TagResponse extends Response {
  final List<TagData>? data;
  final int? limit;
  final int? offset;
  final int? total;
  TagResponse(
    super.result,
    super.response,
    this.data,
    this.limit,
    this.offset,
    this.total,
  );
  factory TagResponse.fromJson(Map<String, dynamic> json) {
    return _$TagResponseFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$TagResponseToJson(this);
}

@JsonSerializable()
class TagData extends Identifier {
  final TagAttributes attributes;
  TagData(super.id, super.type, this.attributes);
  factory TagData.fromJson(Map<String, dynamic> json) {
    return _$TagDataFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$TagDataToJson(this);
}

@JsonSerializable()
class TagAttributes extends Attribute {
  final Title? name;
  final String? group;
  TagAttributes(
    this.name,
    this.group,
    super.createdAt,
    super.updatedAt,
    super.version,
  );
  factory TagAttributes.fromJson(Map<String, dynamic> json) {
    return _$TagAttributesFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$TagAttributesToJson(this);
}
