// Decides which chapter ids a download action should enqueue, so the UI layer
// (MangaDetailScreenCubit.download / downloadManga) only has to collect the
// inputs and make the enqueue call — it never has to re-derive the "All" vs
// "Unread" scoping rules.
//
// The flow runs caller → resolver → caller again: this function returns the
// ids and nothing else (no queue handle, no JobManager reference, no enqueue
// of its own), so the cubit stays the single owner of queueing. Pure by
// design — no use cases, locator, or database — so the scoping rules are
// unit-testable.
import 'package:entity_manga/entity_manga.dart';

/// Returns the ids of [chapters] to queue, preserving the incoming order.
///
/// Already-queued ids are always skipped, in both scopes: the prefetch pipeline
/// is keyed by chapter id, so re-queueing one would enqueue a duplicate job.
/// [readChapterIds] is only consulted when [unreadOnly] is true — "All" means
/// every chapter, read or not. Chapters without an id cannot be queued (the
/// pipeline is keyed by id), so they are dropped.
List<String> resolveDownloadChapterIds({
  required List<Chapter> chapters,
  required Set<String> readChapterIds,
  required Set<String> queuedChapterIds,
  required bool unreadOnly,
}) {
  final ids = <String>[];
  for (final chapter in chapters) {
    final id = chapter.id;
    if (id == null) continue;
    if (unreadOnly && readChapterIds.contains(id)) continue;
    if (queuedChapterIds.contains(id)) continue;
    ids.add(id);
  }
  return ids;
}
