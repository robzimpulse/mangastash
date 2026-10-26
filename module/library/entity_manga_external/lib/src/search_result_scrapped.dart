import 'package:equatable/equatable.dart';

import 'json_fields.dart';
import 'manga_scrapped.dart';

/// One page of search/browse results returned by a scripted source.
///
/// Build it from the JSON a source script returns with
/// `SearchResultScrapped.fromJson(map)`; [items] is required (may be empty),
/// [hasNextPage] is null when the source does not know. Unknown keys are
/// ignored; a wrong type throws a [FormatException] naming the field.
class SearchResultScrapped extends Equatable {
  final List<MangaScrapped> items;
  final bool? hasNextPage;

  const SearchResultScrapped({this.items = const [], this.hasNextPage});

  factory SearchResultScrapped.fromJson(Map<String, dynamic> json) {
    final items = optionalObjectList(json, 'items');
    return SearchResultScrapped(
      items: [for (final item in items ?? []) MangaScrapped.fromJson(item)],
      hasNextPage: optionalBool(json, 'hasNextPage'),
    );
  }

  @override
  List<Object?> get props => [items, hasNextPage];
}
