import 'package:manga_dex_api/manga_dex_api.dart';

import '../tag.dart';

class SearchParameterExtra {
  final SearchMangaParameter? parameter;

  final List<Tag> tags;

  const SearchParameterExtra({this.tags = const [], this.parameter});

  SearchParameterExtra copyWith({
    SearchMangaParameter? parameter,
    List<Tag>? tags,
  }) {
    return SearchParameterExtra(
      parameter: parameter ?? this.parameter,
      tags: tags ?? this.tags,
    );
  }
}
