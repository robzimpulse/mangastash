import 'package:collection/collection.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

mixin FilterChaptersMixin {
  List<Chapter> filterChapters({
    required List<Chapter> chapters,
    required SearchChapterParameter parameter,
  }) {
    final pages = chapters.slices(parameter.limit);
    if (parameter.page > pages.length) return [];
    return pages.elementAt(parameter.page - 1);
  }
}