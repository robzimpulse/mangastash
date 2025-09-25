import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'enum/source_enum.dart';

part 'source_search_manga_parameter.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SourceSearchMangaParameter extends Equatable {
  final SourceEnum source;

  final SearchMangaParameter parameter;

  const SourceSearchMangaParameter({
    required this.source,
    required this.parameter,
  });

  @override
  List<Object?> get props => [source, parameter];

  factory SourceSearchMangaParameter.fromJson(Map<String, dynamic> json) {
    return _$SourceSearchMangaParameterFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SourceSearchMangaParameterToJson(this);

  String toJsonString() => json.encode(toJson());

  static SourceSearchMangaParameter? fromJsonString(String value) {
    try {
      return SourceSearchMangaParameter.fromJson(
        json.decode(value) as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }
}
