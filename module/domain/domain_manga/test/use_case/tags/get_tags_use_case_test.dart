// Tests for GetTagsUseCase on scraped sources: the tag list is fetched from
// the page the source's tagsUrl() resolves to (WeebCentral's checkboxes live
// only on /search, issue #163; the searchUrl(page: 1) fallback for scripts
// without tagsUrl is pinned in script_source_external_test.dart), and a
// cached genre list (rows with tag ids) is served without scraping. The
// source is a mocked SourceExternal (issue #115).
//
// Run with: fvm flutter test test/use_case/tags/get_tags_use_case_test.dart
import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/use_case/tags/get_tags_use_case.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/mock_sources.dart';

class MockMangaService extends Mock implements MangaService {}

class MockTagDao extends Mock implements TagDao {}

class MockLogBox extends Mock implements analytics.LogBox {}

const _tagsUrl = 'https://weebcentral.com/search';

void main() {
  late MockSourceExternal source;
  late MockSourceRegistry registry;
  late MockTagDao tagDao;
  late GetTagsUseCase useCase;

  setUpAll(() {
    registerFallbackValue(const <TagTablesCompanion>[]);
  });

  setUp(() {
    source = mockScrapedSource(name: 'Weeb Central');
    registry = mockRegistry([source]);
    tagDao = MockTagDao();
    // LogBox.log is an extension method, so mocktail cannot intercept it —
    // the real body runs and needs a real Storage behind the mock's field.
    final logBox = MockLogBox();
    when(
      () => logBox.storage,
    ).thenReturn(analytics.Storage(liveDataStorage: analytics.MemoryStorage()));
    useCase = GetTagsUseCase(
      mangaService: MockMangaService(),
      tagDao: tagDao,
      logBox: logBox,
      registry: registry,
    );

    when(() => source.tagsUrl()).thenAnswer((_) async => _tagsUrl);
    when(
      () => source.tags(
        url: any(named: 'url'),
        useCache: any(named: 'useCache'),
      ),
    ).thenAnswer((_) async => const [TagScrapped(id: 'action', name: 'Action')]);
    when(
      () => tagDao.search(sources: any(named: 'sources')),
    ).thenAnswer((_) async => []);
    when(
      () => tagDao.adds(values: any(named: 'values')),
    ).thenAnswer((_) async => []);
  });

  test('fetches the tags from the page tagsUrl resolves to (#163)', () async {
    final result = await useCase.execute(source: source, useCache: false);

    expect(result, isA<Success<List<Tag>>>());
    verify(() => source.tags(url: _tagsUrl, useCache: false)).called(1);
    verify(() => tagDao.adds(values: any(named: 'values'))).called(1);
  });

  test('fetches with the code saved after the screen captured its source',
      () async {
    final edited = mockScrapedSource(name: 'Weeb Central');
    when(() => registry.fromName('Weeb Central')).thenReturn(edited);
    when(() => edited.tagsUrl()).thenAnswer((_) async => _tagsUrl);
    when(
      () => edited.tags(
        url: any(named: 'url'),
        useCache: any(named: 'useCache'),
      ),
    ).thenAnswer((_) async => const [TagScrapped(id: 'new', name: 'New')]);

    await useCase.execute(source: source, useCache: false);

    verify(() => edited.tags(url: _tagsUrl, useCache: false)).called(1);
    verifyNever(
      () => source.tags(
        url: any(named: 'url'),
        useCache: any(named: 'useCache'),
      ),
    );
  });

  group('cache', () {
    TagDrift row({String? tagId}) {
      return TagDrift(
        createdAt: DateTime.utc(2026),
        updatedAt: DateTime.utc(2026),
        id: 1,
        tagId: tagId,
        name: 'Action',
        source: 'Weeb Central',
      );
    }

    test('returns cached genre list without scraping', () async {
      when(
        () => tagDao.search(sources: any(named: 'sources')),
      ).thenAnswer((_) async => [row(tagId: 'action')]);

      final result = await useCase.execute(source: source);

      expect((result as Success<List<Tag>>).data.single.id, 'action');
      verifyNever(() => source.tagsUrl());
      verifyNever(
        () => source.tags(
          url: any(named: 'url'),
          useCache: any(named: 'useCache'),
        ),
      );
    });

    // Name-only rows come from manga detail syncs (TagDao.reattach) or the
    // schema v6 repair — they are not a genre list, so scrape one.
    test('scrapes when cached tags have no tag ids', () async {
      when(
        () => tagDao.search(sources: any(named: 'sources')),
      ).thenAnswer((_) async => [row()]);

      final result = await useCase.execute(source: source);

      expect(result, isA<Success<List<Tag>>>());
      verify(() => source.tags(url: _tagsUrl, useCache: true)).called(1);
    });
  });
}
