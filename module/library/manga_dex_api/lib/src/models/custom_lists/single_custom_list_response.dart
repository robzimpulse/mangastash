import 'package:json_annotation/json_annotation.dart';
part 'single_custom_list_response.g.dart';

///@nodoc
@JsonSerializable()
class SingleCustomListResponse {
  final String? result;
  final String? response;
  final SingleCustomListResponseData? data;
  SingleCustomListResponse(this.result, this.response, this.data);
  factory SingleCustomListResponse.fromJson(Map<String, dynamic> json) =>
      _$SingleCustomListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$SingleCustomListResponseToJson(this);
}

@JsonSerializable()
class SingleCustomListResponseData {
  final String? id;
  final String? type;
  final SingleCustomListResponseAttributes? attributes;
  final List<SingleCustomListResponseRelationship>? relationships;
  SingleCustomListResponseData(this.id, this.type, this.attributes, this.relationships);
  factory SingleCustomListResponseData.fromJson(Map<String, dynamic> json) => _$SingleCustomListResponseDataFromJson(json);
  Map<String, dynamic> toJson() => _$SingleCustomListResponseDataToJson(this);
}

@JsonSerializable()
class SingleCustomListResponseAttributes {
  final String? name;
  final String? visibility;
  final int? version;
  SingleCustomListResponseAttributes(this.name, this.visibility, this.version);
  factory SingleCustomListResponseAttributes.fromJson(Map<String, dynamic> json) =>
      _$SingleCustomListResponseAttributesFromJson(json);
  Map<String, dynamic> toJson() => _$SingleCustomListResponseAttributesToJson(this);
}

///@nodoc
@JsonSerializable()
class SingleCustomListResponseRelationship {
  final String? id;
  final String? type;
  SingleCustomListResponseRelationship(this.id, this.type);
  factory SingleCustomListResponseRelationship.fromJson(Map<String, dynamic> json) =>
      _$SingleCustomListResponseRelationshipFromJson(json);
  Map<String, dynamic> toJson() => _$SingleCustomListResponseRelationshipToJson(this);
}
