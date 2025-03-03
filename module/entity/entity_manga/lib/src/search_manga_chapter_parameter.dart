import 'package:json_annotation/json_annotation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

part 'search_manga_chapter_parameter.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SearchMangaChapterParameter extends SearchParameter {
  final Map<ChapterOrders, OrderDirections>? orders;
  final List<MangaStatus>? status;

  const SearchMangaChapterParameter({
    super.title,
    super.limit,
    super.offset,
    super.page,
    this.orders,
    this.status,
  });

  @override
  List<Object?> get props {
    return [...super.props, orders, status];
  }

  factory SearchMangaChapterParameter.fromJson(Map<String, dynamic> json) {
    return _$SearchMangaChapterParameterFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$SearchMangaChapterParameterToJson(this);

  @override
  SearchMangaChapterParameter copyWith({
    String? title,
    num? limit,
    String? offset,
    String? page,
    Map<ChapterOrders, OrderDirections>? orders,
    List<MangaStatus>? status,
  }) {
    return SearchMangaChapterParameter(
      title: title ?? this.title,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      page: page ?? this.page,
      orders: orders ?? this.orders,
      status: status ?? this.status,
    );
  }
}