// Tests for GetChapterUseCase on scraped sources (issue #114): a chapter
// reader parse that extracts zero images must fail as a parse error at
// scrape time instead of syncing an image-less chapter whose reader then
// renders nothing. The source is a mocked SourceExternal (issue #115); the
// failed validation must also evict the runner's cached script result.
//
// Run with: fvm flutter test test/use_case/chapter/get_chapter_use_case_test.dart
import 'package:core_analytics/core_analytics.dart';
import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/exception/source_moved_exception.dart';
import 'package:domain_manga/src/use_case/chapter/get_chapter_use_case.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/mock_sources.dart';

class MockChapterRepository extends Mock implements ChapterRepository {}

class MockAtHomeRepository extends Mock implements AtHomeRepository {}

class MockChapterDao extends Mock implements ChapterDao {}

class MockMangaDao extends Mock implements MangaDao {}

class MockLogBox extends Mock implements LogBox {}

const _mangaId = 'm-1';
const _chapterId = 'c-1';
const _chapterUrl = 'https://mangakatana.com/manga/one-piece.49/c1';

/// A stored chapter row; [images] are attached as ImageDrift rows keyed to
/// the chapter id, which is what "the chapter was saved" means.
ChapterModel storedChapter({
  String? webUrl,
  List<String> images = const [],
}) {
  return ChapterModel(
    chapter: ChapterDrift(
      id: _chapterId,
      mangaId: _mangaId,
      webUrl: webUrl ?? _chapterUrl,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ),
    images: [
      for (final (index, url) in images.indexed)
        ImageDrift(
          id: 'img-$index',
          chapterId: _chapterId,
          webUrl: url,
          order: index,
          createdAt: DateTime(2026),
          updatedAt: DateTime(2026),
        ),
    ],
  );
}

void main() {
  late MockChapterDao chapterDao;
  late MockMangaDao mangaDao;
  late MockRunSourceScriptUseCase runner;
  late MockSourceExternal source;
  late MockSourceRegistry registry;
  late GetChapterUseCase useCase;

  setUpAll(() {
    registerFallbackValue(const Duration(seconds: 1));
    registerFallbackValue(const <ChapterTablesCompanion, List<String>>{});
  });

  setUp(() {
    chapterDao = MockChapterDao();
    mangaDao = MockMangaDao();
    runner = mockRunner();
    // Issue #206: the mocked source's baseUrl must match the stored
    // chapter's host, or the moved-source gate would freeze every fixture.
    source = mockScrapedSource(
      name: 'Manga Katana',
      baseUrl: 'https://mangakatana.com',
    );
    registry = mockRegistry([source]);
    // LogBox.log is an extension method, so mocktail cannot intercept it —
    // the real body runs and needs a real Storage behind the mock's field
    // (see CLAUDE.md's LogBox entry).
    final logBox = MockLogBox();
    when(
      () => logBox.storage,
    ).thenReturn(analytics.Storage(liveDataStorage: analytics.MemoryStorage()));
    useCase = GetChapterUseCase(
      chapterRepository: MockChapterRepository(),
      atHomeRepository: MockAtHomeRepository(),
      runner: runner,
      registry: registry,
      chapterDao: chapterDao,
      mangaDao: mangaDao,
      logBox: logBox,
    );

    when(
      () => chapterDao.search(ids: any(named: 'ids')),
    ).thenAnswer(
      (_) async => [
        ChapterModel(
          chapter: ChapterDrift(
            id: _chapterId,
            webUrl: _chapterUrl,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ),
      ],
    );
    // The stored manga lives on the source's own host (not moved).
    when(
      () => mangaDao.search(ids: any(named: 'ids')),
    ).thenAnswer(
      (_) async => [
        MangaModel(
          manga: MangaDrift(
            id: _mangaId,
            webUrl: 'https://mangakatana.com/manga/one-piece.49',
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ),
      ],
    );
    when(
      () => chapterDao.adds(values: any(named: 'values')),
    ).thenAnswer((_) async => []);
  });

  test(
    'an empty image parse fails as a parse error instead of a blank reader (#114)',
    () async {
      when(
        () => source.images(url: _chapterUrl, useCache: any(named: 'useCache')),
      ).thenAnswer((_) async => []);

      final result = await useCase.execute(
        source: source,
        mangaId: _mangaId,
        chapterId: _chapterId,
      );

      expect(result, isA<Error<Chapter>>());
      final error = (result as Error<Chapter>).error;
      expect(error, isA<FailedParsingHtmlException>());
      expect((error as FailedParsingHtmlException).url, _chapterUrl);
      expect(error.source, 'Manga Katana');
      expect(error.parser, 'images');
      expect(error.missingFields, ['image urls']);
      // The image-less chapter never reaches the DB sync, and the cached
      // script result behind it is dropped.
      verifyNever(() => chapterDao.adds(values: any(named: 'values')));
      verify(() => runner.evict(url: _chapterUrl)).called(1);
    },
  );

  test('runs the code saved after the reader captured its source', () async {
    // The reader resolved `source` before the user saved a fix; the registry
    // now holds an adapter with the new code under the same name.
    final edited = mockScrapedSource(
      name: 'Manga Katana',
      baseUrl: 'https://mangakatana.com',
    );
    when(() => registry.fromName('Manga Katana')).thenReturn(edited);
    when(
      () => edited.images(url: _chapterUrl, useCache: any(named: 'useCache')),
    ).thenAnswer((_) async => ['https://img/1.jpg']);

    await useCase.execute(
      source: source,
      mangaId: _mangaId,
      chapterId: _chapterId,
      useCache: false,
    );

    verify(
      () => edited.images(url: _chapterUrl, useCache: any(named: 'useCache')),
    ).called(1);
    verifyNever(
      () => source.images(url: any(named: 'url'), useCache: any(named: 'useCache')),
    );
  });

  // Issue #206: a moved manga (or a chapter still stored on the dead host of
  // a half-merged row) is never scraped — a saved chapter serves its stored
  // images, an unsaved one fails as SourceMovedException.
  group('moved source', () {
    late MockSourceExternal newSource;

    setUp(() {
      // The user edited the script: the source now serves another domain.
      newSource = mockScrapedSource(
        name: 'Manga Katana',
        baseUrl: 'https://new.example',
      );
      when(() => registry.fromName('Manga Katana')).thenReturn(newSource);
    });

    void stubStoredManga(String? webUrl) {
      when(
        () => mangaDao.search(ids: any(named: 'ids')),
      ).thenAnswer(
        (_) async => [
          if (webUrl != null)
            MangaModel(
              manga: MangaDrift(
                id: _mangaId,
                webUrl: webUrl,
                createdAt: DateTime(2026),
                updatedAt: DateTime(2026),
              ),
            ),
        ],
      );
    }

    void stubStoredChapter({
      String? webUrl,
      List<String> images = const [],
    }) {
      when(
        () => chapterDao.search(ids: any(named: 'ids')),
      ).thenAnswer((_) async => [storedChapter(webUrl: webUrl, images: images)]);
    }

    test(
      'manga moved, chapter has stored images → returns stored chapter',
      () async {
        stubStoredManga('https://old.example/t');
        stubStoredChapter(images: ['https://img/1.jpg', 'https://img/2.jpg']);

        final result = await useCase.execute(
          source: source,
          mangaId: _mangaId,
          chapterId: _chapterId,
          useCache: false,
        );

        expect(result, isA<Success<Chapter>>());
        expect(
          (result as Success<Chapter>).data.images,
          ['https://img/1.jpg', 'https://img/2.jpg'],
        );
        verifyNever(
          () => newSource.images(
            url: any(named: 'url'),
            useCache: any(named: 'useCache'),
          ),
        );
      },
    );

    test('manga moved, chapter without images → SourceMovedException',
        () async {
      stubStoredManga('https://old.example/t');
      // The chapter was never saved (no stored images): nothing to serve.
      stubStoredChapter();

      final result = await useCase.execute(
        source: source,
        mangaId: _mangaId,
        chapterId: _chapterId,
        useCache: false,
      );

      expect(result, isA<Error<Chapter>>());
      final error = (result as Error<Chapter>).error;
      expect(error, isA<SourceMovedException>());
      expect((error as SourceMovedException).host, 'old.example');
      expect(error.sourceName, 'Manga Katana');
    });

    test(
      'manga on current host, chapter webUrl on old host → treated as moved',
      () async {
        // Half-merged data: the manga row was relinked to the new host by
        // title before this shipped, its old-host chapter left underneath —
        // the chapter's own webUrl decides here, not the manga's.
        stubStoredManga('https://new.example/t');
        stubStoredChapter(
          webUrl: 'https://old.example/t/c1',
          images: ['https://img/1.jpg'],
        );

        final result = await useCase.execute(
          source: source,
          mangaId: _mangaId,
          chapterId: _chapterId,
          useCache: false,
        );

        expect(result, isA<Success<Chapter>>());
        expect((result as Success<Chapter>).data.images, ['https://img/1.jpg']);
        verifyNever(
          () => newSource.images(
            url: any(named: 'url'),
            useCache: any(named: 'useCache'),
          ),
        );
      },
    );

    test(
      'half-merged chapter without images → SourceMovedException from its host',
      () async {
        stubStoredManga('https://new.example/t');
        stubStoredChapter(webUrl: 'https://old.example/t/c1');

        final result = await useCase.execute(
          source: source,
          mangaId: _mangaId,
          chapterId: _chapterId,
          useCache: false,
        );

        expect(result, isA<Error<Chapter>>());
        final error = (result as Error<Chapter>).error;
        expect(error, isA<SourceMovedException>());
        expect((error as SourceMovedException).host, 'old.example');
      },
    );
  });
}
