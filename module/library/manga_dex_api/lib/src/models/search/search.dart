import 'package:json_annotation/json_annotation.dart';

import '../common/attributes.dart';

part 'search.g.dart';

///@nodoc
@JsonSerializable()
class Search {
  final String? result;
  final String? response;
  final List<SearchData>? data;
  final int? limit;
  final int? offset;
  final int? total;
  Search(
    this.data,
    this.limit,
    this.offset,
    this.total,
    this.result,
    this.response,
  );
  factory Search.fromJson(Map<String, dynamic> json) => _$SearchFromJson(json);
  Map<String, dynamic> toJson() => _$SearchToJson(this);
}

@JsonSerializable()
class SearchData {
  final String? id;
  final String? type;
  final Attributes? attributes;
  final List<SearchRelationship>? relationships;
  SearchData(this.id, this.type, this.attributes, this.relationships);
  factory SearchData.fromJson(Map<String, dynamic> json) =>
      _$SearchDataFromJson(json);
  Map<String, dynamic> toJson() => _$SearchDataToJson(this);
}

@JsonSerializable()
class SearchRelationship {
  final String? id;
  final String? type;
  final SearchAttributes? attributes;
  SearchRelationship(this.id, this.type, this.attributes);
  factory SearchRelationship.fromJson(Map<String, dynamic> json) =>
      _$SearchRelationshipFromJson(json);
  Map<String, dynamic> toJson() => _$SearchRelationshipToJson(this);
}

@JsonSerializable()
class SearchAttributes {
  final String? description;
  final String? volume;
  final String? fileName;
  final String? locale;
  final String? createdAt;
  final String? updatedAt;
  final int? version;
  SearchAttributes(
    this.description,
    this.volume,
    this.fileName,
    this.locale,
    this.createdAt,
    this.updatedAt,
    this.version,
  );
  factory SearchAttributes.fromJson(Map<String, dynamic> json) =>
      _$SearchAttributesFromJson(json);
  Map<String, dynamic> toJson() => _$SearchAttributesToJson(this);
}
