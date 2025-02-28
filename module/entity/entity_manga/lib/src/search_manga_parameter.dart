import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

part 'search_manga_parameter.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SearchMangaParameter extends Equatable {
  final String? title;
  final num? limit;
  final String? offset;
  final String? page;
  final Map<SearchOrders, OrderDirections>? orders;
  final List<MangaStatus>? status;

  const SearchMangaParameter({
    this.title,
    this.limit,
    this.offset,
    this.page,
    this.orders,
    this.status,
  });

  @override
  List<Object?> get props {
    return [
      title,
      limit,
      offset,
      page,
      orders,
      status,
    ];
  }

  factory SearchMangaParameter.fromJson(Map<String, dynamic> json) {
    return _$SearchMangaParameterFromJson(json);
  }

  Map<String, dynamic> toJson() => _$SearchMangaParameterToJson(this);

  SearchMangaParameter copyWith({
    String? title,
    num? limit,
    String? offset,
    String? page,
    Map<SearchOrders, OrderDirections>? orders,
    List<MangaStatus>? status,
  }) {
    return SearchMangaParameter(
      title: title ?? this.title,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      page: page ?? this.page,
      orders: orders ?? this.orders,
      status: status ?? this.status,
    );
  }
}
