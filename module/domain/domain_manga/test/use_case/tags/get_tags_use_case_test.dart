// Tests for GetTagsUseCase on scraped sources: the page it opens must be
// the one the genre list actually lives on — WeebCentral's checkboxes are
// only on /search, while its searchMangaUseCase.url() points at the
// /search/data htmx fragment with zero checkboxes (issue #163).
//
// Run with: fvm flutter test test/use_case/tags/get_tags_use_case_test.dart
import 'package:core_analytics/core_analytics.dart';
import 'package:core_analytics/core_analytics.dart' as analytics;
import 'package:core_network/core_network.dart';
import 'package:core_storage/core_storage.dart';
import 'package:domain_manga/src/sources/weeb_central_source_external.dart';
import 'package:domain_manga/src/use_case/tags/get_tags_use_case.dart';
import 'package:entity_manga/entity_manga.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:manga_dex_api/manga_dex_api.dart';
import 'package:mocktail/mocktail.dart';

class MockMangaService extends Mock implements MangaService {}

class MockHeadlessWebviewUseCase extends Mock implements HeadlessWebviewUseCase {}

class MockTagDao extends Mock implements TagDao {}

class MockLogBox extends Mock implements LogBox {}

void main() {
  late MockHeadlessWebviewUseCase webview;
  late MockTagDao tagDao;
  late GetTagsUseCase useCase;

  setUpAll(() {
    registerFallbackValue(const <TagTablesCompanion>[]);
  });

  setUp(() {
    webview = MockHeadlessWebviewUseCase();
    tagDao = MockTagDao();
    // LogBox.log is an extension method, so mocktail cannot intercept it —
    // the real body runs and needs a real Storage behind the mock's field.
    final logBox = MockLogBox();
    when(
      () => logBox.storage,
    ).thenReturn(analytics.Storage(liveDataStorage: analytics.MemoryStorage()));
    useCase = GetTagsUseCase(
      webview: webview,
      mangaService: MockMangaService(),
      tagDao: tagDao,
      logBox: logBox,
    );

    when(
      () => tagDao.search(sources: any(named: 'sources')),
    ).thenAnswer((_) async => []);
    when(
      () => tagDao.adds(values: any(named: 'values')),
    ).thenAnswer((_) async => []);
  });

  test('fetches the dedicated tags page for WeebCentral (#163)', () async {
    final openedUrls = <String>[];
    when(
      () => webview.open(
        any(),
        scripts: any(named: 'scripts'),
        readyWhenSelectors: any(named: 'readyWhenSelectors'),
        useCache: any(named: 'useCache'),
        timeout: any(named: 'timeout'),
      ),
    ).thenAnswer((invocation) async {
      openedUrls.add(invocation.positionalArguments.first as String);
      return html_parser.parse('<html></html>');
    });

    final result = await useCase.execute(source: WeebCentralSourceExternal());

    expect(result, isA<Success<List<Tag>>>());
    expect(openedUrls, ['https://weebcentral.com/search']);
  });
}
