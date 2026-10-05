// Shared mocktail mocks and fixtures for ui_updates tests.
//
// Mocks the domain_manga use cases and stream sources the cubits consume, so
// each cubit test constructs its subject without the real service locator.
// Stream-returning mocks come with `mock*()` factories pre-stubbed to empty
// streams; tests override the one stream they care about.
//
// Keep this file free of test logic — it only declares types, default stubs
// and entity fixtures.
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:mocktail/mocktail.dart';

class MockListenUnreadHistoryUseCase extends Mock
    implements ListenUnreadHistoryUseCase {}

class MockListenReadHistoryUseCase extends Mock
    implements ListenReadHistoryUseCase {}

class MockListenPrefetchUseCase extends Mock implements ListenPrefetchUseCase {}

class MockPrefetchChapterUseCase extends Mock
    implements PrefetchChapterUseCase {}

class MockImagesCacheManager extends Mock implements ImagesCacheManager {}

/// Stubbed [ListenUnreadHistoryUseCase] (empty stream).
MockListenUnreadHistoryUseCase mockListenUnreadHistoryUseCase() {
  final mock = MockListenUnreadHistoryUseCase();
  when(
    () => mock.unreadHistoryStream,
  ).thenAnswer((_) => const Stream.empty());
  return mock;
}

/// Stubbed [ListenReadHistoryUseCase] (empty stream).
MockListenReadHistoryUseCase mockListenReadHistoryUseCase() {
  final mock = MockListenReadHistoryUseCase();
  when(
    () => mock.readHistoryStream,
  ).thenAnswer((_) => const Stream.empty());
  return mock;
}

/// Stubbed [ListenPrefetchUseCase] (empty streams).
MockListenPrefetchUseCase mockListenPrefetchUseCase() {
  final mock = MockListenPrefetchUseCase();
  when(() => mock.mangaIdsStream).thenAnswer((_) => const Stream.empty());
  when(() => mock.chapterIdsStream).thenAnswer((_) => const Stream.empty());
  return mock;
}

/// Minimal [Manga] fixture — no cover url, so tile widgets never touch the
/// cache manager in tests.
Manga seedManga({String? id, String? title}) {
  return Manga(id: id ?? 'manga-1', title: title ?? 'Manga title');
}

/// Minimal [Chapter] fixture.
Chapter seedChapter({String? id, String? title}) {
  return Chapter(
    id: id ?? 'chapter-1',
    title: title ?? 'Chapter title',
    chapter: '1',
  );
}

/// A well-formed [MangaChapter] pair.
MangaChapter seedMangaChapter({String? mangaId, String? chapterId}) {
  return MangaChapter(
    manga: seedManga(id: mangaId),
    chapter: seedChapter(id: chapterId),
  );
}
