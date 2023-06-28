import 'package:json_annotation/json_annotation.dart';

import 'attributes.dart';
import 'data.dart';
import 'relationships.dart';

part 'single_manga_data.g.dart';

///@nodoc
@JsonSerializable()
class SingleManga {
  final String? result;
  final String? response;
  final SingleMangaData? data;
  SingleManga(this.result, this.response, this.data);
  factory SingleManga.fromJson(Map<String, dynamic> json) =>
      _$SingleMangaFromJson(json);
  Map<String, dynamic> toJson() => _$SingleMangaToJson(this);
}

@JsonSerializable()
class SingleMangaData extends Data {
  final Attributes? attributes;
  final List<Relationship>? relationships;
  SingleMangaData(super.id, super.type, this.attributes, this.relationships);
  factory SingleMangaData.fromJson(Map<String, dynamic> json) =>
      _$SingleMangaDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$SingleMangaDataToJson(this);
}
