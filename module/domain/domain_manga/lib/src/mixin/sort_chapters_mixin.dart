import 'package:collection/collection.dart';
import 'package:core_environment/core_environment.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:manga_dex_api/manga_dex_api.dart';

mixin SortChaptersMixin {
  List<MangaChapter> sortChapters({
    required List<MangaChapter> chapters,
    required SearchChapterParameter parameter,
  }) {
    final option = parameter.orders?.keys.firstOrNull;
    final direction = parameter.orders?[option];

    return switch ((option, direction)) {
      (ChapterOrders.readableAt, OrderDirections.descending) => chapters.sorted(
          (a, b) {
            final aDate = a.readableAt?.asDateTime;
            final bDate = b.readableAt?.asDateTime;
            if (aDate == null || bDate == null) return 0;
            return -aDate.compareTo(bDate);
          },
        ),
      (ChapterOrders.readableAt, OrderDirections.ascending) => chapters.sorted(
          (a, b) {
            final aDate = a.readableAt?.asDateTime;
            final bDate = b.readableAt?.asDateTime;
            if (aDate == null || bDate == null) return 0;
            return aDate.compareTo(bDate);
          },
        ),
      (ChapterOrders.chapter, OrderDirections.descending) => chapters.sorted(
          (a, b) {
            final aChapter = int.tryParse(a.chapter ?? '');
            final bChapter = int.tryParse(b.chapter ?? '');
            if (aChapter == null || bChapter == null) return 0;
            return aChapter.compareTo(bChapter);
          },
        ),
      (ChapterOrders.chapter, OrderDirections.ascending) => chapters.sorted(
          (a, b) {
            final aChapter = int.tryParse(a.chapter ?? '');
            final bChapter = int.tryParse(b.chapter ?? '');
            if (aChapter == null || bChapter == null) return 0;
            return -aChapter.compareTo(bChapter);
          },
        ),
      (_, _) => chapters,
    };
  }
}
