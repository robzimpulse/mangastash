import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'search_manga_parameter.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SearchMangaParameter extends Equatable {
  final String? title;
  final int? limit;
  final String? offset;

  const SearchMangaParameter({
    this.title,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props {
    return [
      title,
      limit,
      offset,
    ];
  }

  factory SearchMangaParameter.fromJson(Map<String, dynamic> json) {
    return _$SearchMangaParameterFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SearchMangaParameterToJson(this);

  SearchMangaParameter copyWith({
    String? title,
    int? limit,
    String? offset,
  }) {
    return SearchMangaParameter(
      title: title ?? this.title,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }
}
