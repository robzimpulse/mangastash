// Shared filter for malformed [MangaChapter] pairs (null manga or null
// chapter, e.g. a history row whose manga was deleted): a null-returning
// ListView itemBuilder would truncate the list at such a row (issue #125),
// so both cubits keep them out of their state entirely — stream emissions
// AND constructor-provided initial states.
import 'package:entity_manga/entity_manga.dart';

List<MangaChapter> onlyCompleteMangaChapters(List<MangaChapter> values) {
  return values
      .where((value) => value.manga != null && value.chapter != null)
      .toList();
}
