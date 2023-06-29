import 'package:json_annotation/json_annotation.dart';

import '../common/identifier.dart';
import '../common/pagination.dart';
import '../common/title.dart';

part 'search_response.g.dart';

///@nodoc
@JsonSerializable()
class SearchResponse extends Pagination {
  final String? result;
  final String? response;
  final List<SearchData>? data;
  SearchResponse(
    this.data,
    this.result,
    this.response,
    super.limit,
    super.offset,
    super.total,
  );
  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return _$SearchResponseFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$SearchResponseToJson(this);
}

@JsonSerializable()
class SearchData extends Identifier {
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
class SearchAttributes extends Identifier {
  final Title? title;
  SearchAttributes(super.id, super.type, this.title);
  factory SearchAttributes.fromJson(Map<String, dynamic> json) {
    return _$SearchAttributesFromJson(json);
  }
  @override
  Map<String, dynamic> toJson() => _$SearchAttributesToJson(this);
}

@JsonSerializable()
class SearchRelationship extends Identifier {
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
  Map<String, dynamic> toJson() => _$SearchRelationshipAttributesToJson(this);
}
