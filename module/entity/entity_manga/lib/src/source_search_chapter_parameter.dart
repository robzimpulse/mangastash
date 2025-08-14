import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'enum/source_enum.dart';

part 'source_search_chapter_parameter.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SourceSearchChapterParameter extends Equatable {
  final SourceEnum source;

  final String mangaId;

  final SearchChapterParameter parameter;

  const SourceSearchChapterParameter({
    required this.source,
    required this.parameter,
    required this.mangaId,
  });

  @override
  List<Object?> get props => [source, parameter, mangaId];

  factory SourceSearchChapterParameter.fromJson(Map<String, dynamic> json) {
    return _$SourceSearchChapterParameterFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SourceSearchChapterParameterToJson(this);

  String toJsonString() => json.encode(toJson());

  static SourceSearchChapterParameter? fromJsonString(String value) {
    try {
      return SourceSearchChapterParameter.fromJson(
        json.decode(value) as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }
}
