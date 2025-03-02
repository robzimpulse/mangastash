import 'package:json_annotation/json_annotation.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

import 'base/search_parameter.dart';

part 'search_manga_parameter.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class SearchMangaParameter extends SearchParameter {
  final Map<SearchOrders, OrderDirections>? orders;
  final List<MangaStatus>? status;

  const SearchMangaParameter({
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

  factory SearchMangaParameter.fromJson(Map<String, dynamic> json) {
    return _$SearchMangaParameterFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() => _$SearchMangaParameterToJson(this);

  @override
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
