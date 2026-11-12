// Widget tests for MangaItemWidget's moved-source badge (issue #206): a
// library-grid tile whose manga is stored on a host its source no longer
// serves shows the `source-moved-badge` icon; current-host and MangaDex
// manga show none. Sources resolve through the static facade, so each test
// binds a registry double first (same pattern as ui_browse's bindSources).
//
// Usage: run with `fvm flutter test test/src/widget/manga_item_widget_test.dart`
// from module/ui/ui_common.
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/domain_manga.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:entity_manga_external/entity_manga_external.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ui_common/ui_common.dart';

class MockSourceRegistry extends Mock implements SourceRegistry {}

/// A scraped (non built-in) source double, mirroring ui_browse's
/// FakeScrapedSourceExternal (that mock lives in ui_browse's test tree and
/// cannot be imported across packages).
class FakeScrapedSourceExternal implements SourceExternal {
  FakeScrapedSourceExternal({
    this.name = 'Scraped Example',
    this.baseUrl = 'https://scraped.example.com',
    this.hosts = const [],
  });

  @override
  final String baseUrl;

  @override
  String get iconUrl => '$baseUrl/favicon.ico';

  @override
  final String name;

  @override
  final List<String> hosts;

  @override
  bool get builtIn => false;

  @override
  Future<String> searchUrl({required SearchMangaParameter parameter}) async {
    return '$baseUrl/browse';
  }

  @override
  Future<SearchResultScrapped> search({
    required String url,
    String? searchTerm,
    bool useCache = true,
  }) => throw UnimplementedError();

  @override
  Future<MangaScrapped> manga({required String url, bool useCache = true}) =>
      throw UnimplementedError();

  @override
  Future<String> chaptersUrl({required String webUrl}) async => webUrl;

  @override
  Future<List<ChapterScrapped>> chapters({
    required String url,
    bool useCache = true,
  }) => throw UnimplementedError();

  @override
  Future<List<String>> images({required String url, bool useCache = true}) =>
      throw UnimplementedError();

  @override
  Future<String> tagsUrl() async => '$baseUrl/browse';

  @override
  Future<List<TagScrapped>> tags({
    required String url,
    bool useCache = true,
  }) => throw UnimplementedError();
}

class _NullCacheManager extends Mock implements ImagesCacheManager {}

/// Binds a registry double resolving MangaDex plus [sources] to the static
/// `Sources` facade, and unbinds it when the test ends.
void bindSources(List<SourceExternal> sources) {
  final registry = MockSourceRegistry();
  when(
    () => registry.values,
  ).thenReturn([MangaDexSourceExternal(), ...sources]);
  Sources.bind(registry);
  addTearDown(() => Sources.unbind(registry));
}

void main() {
  late _NullCacheManager cacheManager;

  setUp(() {
    // CachedNetworkImage reaches the cache manager before the network; a
    // failing fetch lets the tile fall back to its errorWidget, which keeps
    // the badge testable without any HTTP mocking.
    cacheManager = _NullCacheManager();
    when(
      () => cacheManager.getSingleFile(
        any(),
        key: any(named: 'key'),
        headers: any(named: 'headers'),
      ),
    ).thenAnswer((_) => Future.error(Exception('no cache in widget tests')));
  });

  Future<void> pumpItem(WidgetTester tester, {required Manga manga}) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 300,
            child: MangaItemWidget(manga: manga, cacheManager: cacheManager),
          ),
        ),
      ),
    );
    // One pump past the failed image fetch so the tile settles.
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets('a moved manga shows the source-moved badge', (tester) async {
    final source = FakeScrapedSourceExternal(name: 'Scraped Example');
    bindSources([source]);

    await pumpItem(
      tester,
      manga: const Manga(
        id: 'm-1',
        source: 'Scraped Example',
        title: 'T',
        webUrl: 'https://old.example/t',
      ),
    );

    expect(find.byKey(const Key('source-moved-badge')), findsOneWidget);
  });

  testWidgets('a manga on a current host shows no badge', (tester) async {
    final source = FakeScrapedSourceExternal(name: 'Scraped Example');
    bindSources([source]);

    await pumpItem(
      tester,
      manga: const Manga(
        id: 'm-1',
        source: 'Scraped Example',
        title: 'T',
        webUrl: 'https://scraped.example.com/t',
      ),
    );

    expect(find.byKey(const Key('source-moved-badge')), findsNothing);
  });

  testWidgets('a MangaDex manga shows no badge', (tester) async {
    // No registry bound beyond the fallback: MangaDex resolves built-in and
    // is never moved.
    await pumpItem(
      tester,
      manga: const Manga(
        id: 'm-1',
        source: 'Manga Dex',
        title: 'T',
        webUrl: 'https://elsewhere.org/t',
      ),
    );

    expect(find.byKey(const Key('source-moved-badge')), findsNothing);
  });
}
