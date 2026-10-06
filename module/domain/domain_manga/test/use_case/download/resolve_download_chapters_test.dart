// Tests for resolveDownloadChapterIds (issue #119, Task 3). The resolver is a
// pure filter over a chapter list, so these cases pin the two scoping choices
// the download button depends on: "All" keeps read chapters but still skips
// chapters already queued (re-queuing would duplicate jobs), and "Unread"
// additionally drops read ones. Chapters without an id cannot be queued —
// the prefetch pipeline is keyed by chapter id — so they are dropped.
//
// Run with: fvm flutter test test/use_case/download/resolve_download_chapters_test.dart
import 'package:domain_manga/src/use_case/download/resolve_download_chapters.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter_test/flutter_test.dart';

Chapter chapter(String id) => Chapter(id: id);

void main() {
  test('all returns every id minus queued', () {
    final result = resolveDownloadChapterIds(
      chapters: [chapter('a'), chapter('b'), chapter('c')],
      readChapterIds: {'a'},
      queuedChapterIds: {'b'},
      unreadOnly: false,
    );
    expect(result, ['a', 'c']);
  });

  test('unreadOnly drops read and queued', () {
    final result = resolveDownloadChapterIds(
      chapters: [chapter('a'), chapter('b'), chapter('c')],
      readChapterIds: {'a'},
      queuedChapterIds: {'b'},
      unreadOnly: true,
    );
    expect(result, ['c']);
  });

  test('all-read unreadOnly returns empty', () {
    final result = resolveDownloadChapterIds(
      chapters: [chapter('a')],
      readChapterIds: {'a'},
      queuedChapterIds: {},
      unreadOnly: true,
    );
    expect(result, isEmpty);
  });

  test('null ids are skipped', () {
    final result = resolveDownloadChapterIds(
      chapters: [const Chapter()],
      readChapterIds: {},
      queuedChapterIds: {},
      unreadOnly: false,
    );
    expect(result, isEmpty);
  });
}