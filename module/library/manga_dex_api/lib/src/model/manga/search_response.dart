import 'package:json_annotation/json_annotation.dart';

import '../common/attributes.dart';
import '../common/data.dart';
import '../common/relationship.dart';
import '../common/title.dart';

part 'search_response.g.dart';

///@nodoc
@JsonSerializable()
class SearchResponse {
  final String? result;
  final String? response;
  final List<SearchData>? data;
  final int? limit;
  final int? offset;
  final int? total;
  SearchResponse(
    this.data,
    this.limit,
    this.offset,
    this.total,
    this.result,
    this.response,
  );
  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return _$SearchResponseFromJson(json);
  }
  Map<String, dynamic> toJson() => _$SearchResponseToJson(this);
}

@JsonSerializable()
class SearchData extends Data {
  final SearchAttributes? attributes;
  final List<SearchRelationship>? relationships;
  SearchData(super.id, super.type, this.attributes, this.relationships);
  factory SearchData.fromJson(Map<String, dynamic> json) {
    return _$SearchDataFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$SearchDataToJson(this);
}

@JsonSerializable()
class SearchAttributes extends Attributes {
  final Title? title;
  SearchAttributes(this.title);
  factory SearchAttributes.fromJson(Map<String, dynamic> json) {
    return _$SearchAttributesFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$SearchAttributesToJson(this);
}

@JsonSerializable()
class SearchRelationship extends Relationship {
  final SearchRelationshipAttributes? attributes;
  SearchRelationship(super.id, super.type, this.attributes);
  factory SearchRelationship.fromJson(Map<String, dynamic> json) {
    return _$SearchRelationshipFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$SearchRelationshipToJson(this);
}

@JsonSerializable()
class SearchRelationshipAttributes {
  final String? description;
  final String? volume;
  final String? fileName;
  final String? locale;
  final String? createdAt;
  final String? updatedAt;
  final int? version;
  SearchRelationshipAttributes(
    this.description,
    this.volume,
    this.fileName,
    this.locale,
    this.createdAt,
    this.updatedAt,
    this.version,
  );
  factory SearchRelationshipAttributes.fromJson(Map<String, dynamic> json) {
    return _$SearchRelationshipAttributesFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$SearchRelationshipAttributesToJson(this);
}
